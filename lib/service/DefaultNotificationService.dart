// service/notification_plan_service.dart
import 'dart:math';
import 'package:geocoding/geocoding.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:snap_journey/google_ads_material/ads_variable.dart';
import 'package:snap_journey/model/NotificationPlan.dart';
import 'package:snap_journey/service/DatabaseService.dart';
import 'package:snap_journey/service/NotificationService.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:snap_journey/model/moment.dart';

class NotificationPlanService extends GetxService {
  static NotificationPlanService get to => Get.find();

  final Random _random = Random();
  late Box<NotificationPlan> _planBox;
  late SharedPreferences _prefs;

  final String _lastRefreshKey = 'notif_last_refresh';
  final String _openedPrefix = 'app_opened_';

  @override
  Future<void> onInit() async {
    _planBox = await Hive.openBox<NotificationPlan>('notification_plans');
    _prefs = await SharedPreferences.getInstance();
    await _refreshCacheIfNeeded(force: false);
    super.onInit();
  }

  Future<void> checkAndRefreshCache() async {
    await _markAppOpenedToday();
    await _refreshCacheIfNeeded(force: false);
  }

  Future<void> _refreshCacheIfNeeded({required bool force}) async {
    final last = _prefs.getInt(_lastRefreshKey) ?? 0;
    final nowMs = DateTime.now().millisecondsSinceEpoch;

    if (force || (nowMs - last) > Duration(days: 7).inMilliseconds) {
      await _buildSevenDayPlan();
      await _prefs.setInt(_lastRefreshKey, nowMs);
    }
    await _scheduleAllPlanned();
  }

  Future<void> _buildSevenDayPlan() async {
    await _planBox.clear();

    final today = DateTime.now();
    final moments = await DatabaseService.getMoments(withLocation: false);
    final momentByDate = <String, List<Moment>>{};

    for (final m in moments) {
      final key = DateFormat('yyyy-MM-dd').format(m.date);
      momentByDate.putIfAbsent(key, () => []).add(m);
    }

    for (int i = 0; i < 7; i++) {
      final date = today.add(Duration(days: i));
      final dateKey = DateFormat('yyyy-MM-dd').format(date);
      final yyyymmdd = int.parse(dateKey.replaceAll('-', ''));

      final pastMoments = _findSameDayMoments(date, momentByDate);
      if (pastMoments.isNotEmpty) {
        final mem = await _buildMemoryPlan(date, yyyymmdd, pastMoments);
        await _planBox.add(mem);
      } else {
        final routine = _buildRoutinePlan(date, yyyymmdd, hour: 7, type: 'morning');
        await _planBox.add(routine);
      }

      await _planBox.add(_buildRoutinePlan(date, yyyymmdd, hour: 15, type: 'midday'));
      await _planBox.add(_buildRoutinePlan(date, yyyymmdd, hour: 21, type: 'evening'));
    }
  }

  List<Moment> _findSameDayMoments(DateTime target, Map<String, List<Moment>> map) {
    final List<Moment> result = [];
    for (int y = 1; y <= 10; y++) {
      final past = DateTime(target.year - y, target.month, target.day);
      final key = DateFormat('yyyy-MM-dd').format(past);
      final list = map[key];
      if (list != null && list.isNotEmpty) {
        result.addAll(list);
        break;
      }
    }
    return result;
  }

  Future<NotificationPlan> _buildMemoryPlan(DateTime date, int yyyymmdd, List<Moment> past) async {
    final years = DateTime.now().year - past.first.date.year;
    final place = await _getPlaceName(past.first);

    final body = AdsVariable.memoryTemplate['body']!
        .replaceAll('{years}', '$years')
        .replaceAll('{s}', years > 1 ? 's' : '')
        .replaceAll('{place}', place);

    final id = 900000 + yyyymmdd;

    return NotificationPlan()
      ..date = DateTime(date.year, date.month, date.day)
      ..notificationId = id
      ..title = AdsVariable.memoryTemplate['title']!
      ..body = body
      ..payload = 'memory'
      ..isMemory = true
      ..hour = 7;
  }

  NotificationPlan _buildRoutinePlan(DateTime date, int yyyymmdd, {required int hour, required String type}) {
    final List<Map<String, String>> pool = type == 'morning'
        ? AdsVariable.morningPrompts
        : type == 'midday'
        ? AdsVariable.middayPrompts
        : AdsVariable.eveningPrompts;

    final msg = pool[_random.nextInt(pool.length)];
    final baseId = hour == 7 ? 100000 : hour == 15 ? 200000 : 300000;
    final id = baseId + yyyymmdd;

    return NotificationPlan()
      ..date = DateTime(date.year, date.month, date.day)
      ..notificationId = id
      ..title = msg['title']!
      ..body = msg['body']!
      ..payload = 'routine_$type'
      ..hour = hour;
  }

  Future<String> _getPlaceName(Moment m) async {
    if (!m.hasLocation) return 'somewhere special';
    try {
      final cacheKey = 'place_${m.lat}_${m.lng}';
      final cached = _prefs.getString(cacheKey);
      if (cached != null) return cached;

      final placemarks = await placemarkFromCoordinates(m.lat, m.lng);
      if (placemarks.isEmpty) return 'a beautiful place';

      final place = placemarks[0];
      final name = [
        place.locality,
        place.subAdministrativeArea,
        place.country,
      ].where((e) => e != null && e.isNotEmpty).join(', ');

      final result = name.isEmpty ? 'a beautiful place' : name;
      await _prefs.setString(cacheKey, result);
      return result;
    } catch (e) {
      return 'a beautiful place';
    }
  }

  Future<void> _scheduleAllPlanned() async {
    final now = tz.TZDateTime.now(tz.local);
    for (final plan in _planBox.values) {
      if (!plan.isMemory) {
        final opened = await _hasUserOpenedAppToday(plan.date);
        if (opened) continue;
      }

      final scheduled = tz.TZDateTime(tz.local, plan.date.year, plan.date.month, plan.date.day, plan.hour, 0);
      if (scheduled.isBefore(now)) continue;

      await NotificationService.to.scheduleNotification(
        id: plan.notificationId,
        title: plan.title,
        body: plan.body,
        scheduledTime: scheduled.toLocal(),
        payload: plan.payload,
      );
    }
  }

  Future<void> _markAppOpenedToday() async {
    final key = '$_openedPrefix${DateFormat('yyyy-MM-dd').format(DateTime.now())}';
    await _prefs.setBool(key, true);
  }

  Future<bool> _hasUserOpenedAppToday(DateTime date) async {
    final key = '$_openedPrefix${DateFormat('yyyy-MM-dd').format(date)}';
    return _prefs.getBool(key) ?? false;
  }

  static Future<void> momentAdded() async {
    final service = Get.find<NotificationPlanService>();
    await service._refreshCacheIfNeeded(force: true);
  }
}