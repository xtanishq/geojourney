import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:hive/hive.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:snap_journey/google_ads_material/ads_variable.dart';
import 'package:snap_journey/model/TimelineGroup.dart';
import 'package:snap_journey/model/moment.dart';
import 'package:snap_journey/service/DatabaseService.dart';
import 'package:snap_journey/service/LocationService.dart';
import 'package:snap_journey/service/permission.dart';

class MomentsController extends GetxController {
  var moments = <Moment>[].obs;
  GoogleMapController? mapController;
  var isLoading = true.obs;
  var error = ''.obs;

  final Rxn<Position> currentPosition = Rxn<Position>();
  final Rxn<LatLng> pendingCenter = Rxn<LatLng>();

  var mapType = MapType.normal.obs;
  var selectedColorIndex = 0.obs;

  var filteredMoments = <Moment>[].obs;
  var groups = <TimelineGroup>[].obs;
  var displayedGroups = <TimelineGroup>[].obs;
  var currentPage = 0.obs;
  static const int _pageSize = 20;
  var dateFilter = Rxn<DateTime>();
  var filterMode = 'all'.obs;
  var fromDate = Rxn<DateTime>();
  var toDate = Rxn<DateTime>();

  Box? _summaryBox;
  Box? _placeBox;

  final Map<String, String> _placeCache = {};
  final Map<String, String> _summaryCache = {};
  final Set<String> pendingSummaries = {};

  var hasLocationPermission = false.obs;

  @override
  void onInit() {
    super.onInit();
    _initBoxes();
    checkLocationPermission();
    _initLocationAndMoments();
  }

  Future<void> checkLocationPermission() async {
    print('🔍 Checking location permission...');

    final status = await Permission.location.status;

    final granted =
        status == PermissionStatus.granted ||
        status == PermissionStatus.limited;

    hasLocationPermission.value = granted;

    print("📍 Permission status updated → $granted ($status)");
  }

  Future<bool> requestLocationPermission(BuildContext context) async {
    print('Requesting location permission...');
    final status = await Permission.location.request();

    if (status.isGranted || status.isLimited) {
      hasLocationPermission.value = true;
      print('Permission granted');
      await fetchCurrentLocation(context: context);
      return true;
    }

    hasLocationPermission.value = false;
    print('Permission denied: $status');

    MyPermissionHandler.showPermissionDialog(context, "location");
    return false;
  }

  Future<void> _initLocationAndMoments() async {
    try {
      isLoading.value = true;

      if (hasLocationPermission.value) {
        await fetchCurrentLocation();
      }

      await loadMoments();
      _applyFilter();
    } catch (e) {
      error.value = e.toString();
      print('❌ Init error: $e');
      Get.snackbar(
        'Error',
        'Init failed: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchCurrentLocation({BuildContext? context}) async {
    try {
      print('📍 Fetching current location...');

      final status = await Geolocator.checkPermission();
      final granted =
          status == LocationPermission.always ||
          status == LocationPermission.whileInUse;

      hasLocationPermission.value = granted;
      print('📱 Permission status during fetch: $granted');

      if (!granted) {
        print('⚠️ Permission not granted, cannot fetch location');
        return;
      }

      final pos = await LocationService.getCurrentLocation();
      if (pos != null) {
        currentPosition.value = pos;
        print('✅ Location fetched: ${pos.latitude}, ${pos.longitude}');
      } else {
        print('❌ Location service returned null');
      }
    } catch (e) {
      print('❌ Location fetch error: $e');
      hasLocationPermission.value = false;
    }
  }

  Future<void> ensureLocationAvailable(BuildContext context) async {
    await checkLocationPermission();

    if (!hasLocationPermission.value) {
      final granted = await requestLocationPermission(context);
      if (!granted) return;
    }

    if (currentPosition.value == null) {
      await fetchCurrentLocation(context: context);
    }
  }

  Future<void> centerOnCurrentLocation({
    BuildContext? context,
    double zoom = 16,
  }) async {
    print('🎯 Centering on current location...');

    if (!hasLocationPermission.value) {
      print('⚠️ No permission for centering');
      if (context != null) {
        await requestLocationPermission(context);
      }
      return;
    }

    await fetchCurrentLocation(context: context);
    if (currentPosition.value != null && mapController != null) {
      await mapController!.animateCamera(
        CameraUpdate.newLatLngZoom(
          LatLng(
            currentPosition.value!.latitude,
            currentPosition.value!.longitude,
          ),
          zoom,
        ),
      );
      print('✅ Map centered successfully');
    }
  }

  Future<void> _initBoxes() async {
    try {
      _summaryBox = await Hive.openBox('summaries');
      _placeBox = await Hive.openBox('places');
      _loadCaches();
    } catch (e) {
      error.value = e.toString();
    }
  }

  void _loadCaches() {
    if (_placeBox != null) {
      _placeCache.addAll(Map<String, String>.from(_placeBox!.toMap()));
    }
    if (_summaryBox != null) {
      _summaryCache.addAll(Map<String, String>.from(_summaryBox!.toMap()));
    }
  }

  Future<void> loadMoments() async {
    try {
      moments.value = await DatabaseService.getMoments(withLocation: false);
      for (var m in moments) {
        if (m.isNote && m.photoPaths.length > 1) {
          print('🔍 Loaded note paths: ${m.photoPaths}');
          print('🔍 Raw JSON on load: photoPathsJson=${m.photoPathsJson}');
        }
      }
      moments.sort((a, b) => b.date.compareTo(a.date));
      _applyFilter();
      if (moments.isEmpty) {
        await fetchCurrentLocation();
      }
    } catch (e) {
      error.value = e.toString();
      Get.snackbar(
        'Error',
        'Failed to load moments: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  LatLngBounds calculateBounds() {
    // Only consider moments with location for bounds (includes notes with location)
    final locationMoments = moments.where((m) => m.hasLocation).toList();
    if (locationMoments.isEmpty) {
      return LatLngBounds(southwest: LatLng(0, 0), northeast: LatLng(0, 0));
    }
    double minLat = locationMoments.first.lat,
        maxLat = locationMoments.first.lat;
    double minLng = locationMoments.first.lng,
        maxLng = locationMoments.first.lng;
    for (final m in locationMoments) {
      minLat = math.min(minLat, m.lat);
      maxLat = math.max(maxLat, m.lat);
      minLng = math.min(minLng, m.lng);
      maxLng = math.max(maxLng, m.lng);
    }
    return LatLngBounds(
      southwest: LatLng(minLat, minLng),
      northeast: LatLng(maxLat, maxLng),
    );
  }

  Future<void> addMoment(Moment moment) async {
    try {
      await DatabaseService.addMoment(moment);
      moments.add(moment);
      moments.sort((a, b) => b.date.compareTo(a.date));

      // Force summary regeneration for this day
      final dateKey = DateTime(
        moment.date.year,
        moment.date.month,
        moment.date.day,
      ).toIso8601String().split('T')[0];

      _summaryCache.remove(dateKey);
      _placeCache.remove(dateKey);
      await _summaryBox?.delete(dateKey);
      await _placeBox?.delete(dateKey);

      _applyFilter(); // Rebuild groups → trigger async summary
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to add moment: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
      rethrow;
    }
  }

  Future<void> deleteMoment(Moment moment) async {
    try {
      await DatabaseService.deleteMoment(moment);
      moments.removeWhere((m) => m.key == moment.key);
      _applyFilter();
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to delete moment: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> deleteGroup(TimelineGroup group) async {
    try {
      for (var m in group.moments) {
        await deleteMoment(m);
      }
      _applyFilter();
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to delete group: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  List<Moment> get displayedMoments {
    if (dateFilter.value == null) return filteredMoments;
    return filteredMoments
        .where((m) => _isSameDay(m.date, dateFilter.value!))
        .toList();
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  void setFilterMode(String mode) {
    filterMode.value = mode;
    _applyFilter();
  }

  void setDateFilter(DateTime date) {
    dateFilter.value = date;
    _applyFilter();
  }

  void clearDateFilter() {
    dateFilter.value = null;
    _applyFilter();
  }

  void _applyFilter() {
    List<Moment> temp = List.from(moments);
    DateTime now = DateTime.now();
    switch (filterMode.value) {
      case '7days':
        var start = now.subtract(const Duration(days: 7));
        temp = temp.where((m) => m.date.isAfter(start)).toList();
        break;
      case 'month':
        var start = DateTime(now.year, now.month, 1);
        temp = temp
            .where(
              (m) => m.date.isAfter(start.subtract(const Duration(days: 1))),
            )
            .toList();
        break;
    }
    filteredMoments.value = temp..sort((a, b) => b.date.compareTo(a.date));
    _buildGroups();
  }

  Future<void> _buildGroups() async {
    final map = <DateTime, List<Moment>>{};
    for (var m in filteredMoments) {
      final day = DateTime(m.date.year, m.date.month, m.date.day);
      map.putIfAbsent(day, () => <Moment>[]).add(m);
    }

    final newGroups = <TimelineGroup>[];
    for (var entry in map.entries) {
      var groupMoments = entry.value..sort((a, b) => a.date.compareTo(b.date));
      final g = TimelineGroup(date: entry.key, moments: groupMoments);
      final dateKey = entry.key.toIso8601String().split('T')[0];

      g.place = _placeCache[dateKey] ?? '';
      g.summary = _summaryCache[dateKey] ?? 'Generating summary...';

      if (groupMoments.isNotEmpty) {
        final hasAnyLocation = groupMoments.any((m) => m.hasLocation);
        if (g.place!.isEmpty && hasAnyLocation) {
          _fetchPlaceAsync(
            dateKey,
            groupMoments.firstWhere((m) => m.hasLocation),
            g,
          );
        }
        if (g.summary == 'Generating summary...' &&
            !pendingSummaries.contains(dateKey)) {
          _generateSummaryAsync(dateKey, g);
        }
      }

      newGroups.add(g);
    }

    newGroups.sort((a, b) => b.date.compareTo(a.date));
    groups.value = newGroups;
    currentPage.value = 0;
    displayedGroups.clear();
    _loadNextPage();
  }

  void _loadNextPage() {
    final start = currentPage.value * _pageSize;
    if (start >= groups.length) return;
    final end = math.min(start + _pageSize, groups.length);
    displayedGroups.addAll(groups.sublist(start, end));
  }

  void loadMoreGroups() {
    if (currentPage.value * _pageSize < groups.length) {
      currentPage.value++;
      _loadNextPage();
    }
  }

  void _fetchPlaceAsync(String dateKey, Moment moment, TimelineGroup g) async {
    if (!moment.hasLocation || moment.lat == 0) return;

    try {
      final placemarks = await placemarkFromCoordinates(moment.lat, moment.lng);
      if (placemarks.isNotEmpty) {
        final place = placemarks[0];
        final locality = place.locality ?? '';
        final country = place.country ?? '';
        final p = '${locality.isNotEmpty ? '$locality, ' : ''}$country';
        _placeCache[dateKey] = p;
        await _placeBox?.put(dateKey, p);

        final idx = groups.indexWhere((gr) => gr.date == g.date);
        if (idx != -1) {
          groups[idx].place = p;
          groups.refresh();
        }
      }
    } catch (e) {
      print('Place fetch error: $e');
    }
  }

  void _generateSummaryAsync(String dateKey, TimelineGroup g) async {
    pendingSummaries.add(dateKey);
    try {
      final sum = await _generateSummaryForGroup(g);
      _summaryCache[dateKey] = sum;
      _summaryBox?.put(dateKey, sum);
      pendingSummaries.remove(dateKey);
      final idx = groups.indexWhere((gr) => gr.date == g.date);
      if (idx != -1) {
        groups[idx].summary = sum;
        groups.refresh();
      }
    } catch (e) {
      pendingSummaries.remove(dateKey);
    }
  }

  Future<String> _generateSummaryForGroup(TimelineGroup g) async {
    if (g.moments.isEmpty) {
      final location = g.place?.isNotEmpty == true
          ? g.place!
          : 'somewhere quiet';
      return 'A calm day in $location — simple moments that felt quietly meaningful.';
    }

    final captionsAndNotes = g.moments
        .map(
          (m) => '${m.caption ?? ''} ${m.title ?? ''} ${m.note ?? ''}'.trim(),
        )
        .where((s) => s.isNotEmpty)
        .join('. ');

    final locationDesc = g.place?.isNotEmpty == true
        ? g.place!
        : 'various places';
    final dateStr =
        '${g.date.day} ${_getMonthName(g.date.month)}, ${g.date.year}';
    final prompt =
        '''
You are a travel journaling assistant.
Write only a single short reflective passage (4–10 lines) in first person, describing the traveler’s experience on $dateStr in $locationDesc.
Use an emotional, descriptive tone that captures the atmosphere, feelings, and highlights of the day.

Base your writing on these trip details: "$captionsAndNotes".
If details are missing or minimal, imagine a meaningful day of exploration, connection, and self-reflection at $locationDesc.

Output only the diary-style summary — no introductions, explanations, or extra text.
Avoid markdown, emojis, bullet points, or meta commentary.
Write naturally, as if it came directly from a travel diary entry.
''';

    final url = Uri.parse(
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key=${AdsVariable.googleApiKey}',
    );

    try {
      print('Gemini Request: $prompt');

      final response = await http
          .post(
            url,
            headers: {'Content-Type': 'application/json'},
            body: json.encode({
              'contents': [
                {
                  'parts': [
                    {'text': prompt},
                  ],
                },
              ],
              'generationConfig': {'maxOutputTokens': 160, 'temperature': 0.85},
            }),
          )
          .timeout(const Duration(seconds: 20));

      print('Gemini Status: ${response.statusCode}');
      print('Gemini Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final text =
            data['candidates']?[0]?['content']?['parts']?[0]?['text']
                ?.toString()
                .trim() ??
            '';

        if (text.isNotEmpty) {
          final cleaned = text.replaceAll(RegExp(r'\*+'), '').trim();
          return cleaned.length > 800
              ? '${cleaned.substring(0, 800).trim()}…'
              : cleaned;
        }
      }

      print('Gemini failed: ${response.statusCode}');
      return 'A memorable day in $locationDesc — ${g.moments.length} moment${g.moments.length > 1 ? 's' : ''} captured the essence of the journey.';
    } on TimeoutException {
      print('Gemini timeout');
      return 'A peaceful day in $locationDesc, filled with simple joys and quiet reflections.';
    } catch (e) {
      print('Gemini error: $e');
      return 'A meaningful day in $locationDesc, full of experiences that words can barely capture.';
    }
  }

  String _getMonthName(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return months[month - 1];
  }
}
