import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:snap_journey/model/moment.dart';
import 'package:snap_journey/service/DatabaseService.dart';
import 'package:snap_journey/service/LocationService.dart';
import 'package:snap_journey/service/permission.dart';

class HomeController extends GetxController {
  var moments = <Moment>[].obs;
  GoogleMapController? mapController;
  var isLoading = true.obs;
  var error = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadMoments();
  }

  Future<void> loadMoments() async {
    try {
      isLoading(true);
      error.value = '';
      moments.value = await DatabaseService.getMoments();
      moments.sort((a, b) => b.date.compareTo(a.date));
      if (mapController != null && moments.isNotEmpty) {
        final bounds = calculateBounds();
        await mapController!.animateCamera(
          CameraUpdate.newLatLngBounds(bounds, 50),
        );
      }
    } catch (e) {
      error.value = e.toString();
      // Get.snackbar(
      //   'Error',
      //   'Failed to load moments: ${error.value}',
      //   snackPosition: SnackPosition.TOP,
      // );
      print(error.value);
    } finally {
      isLoading(false);
    }
  }

  LatLngBounds calculateBounds() {
    if (moments.isEmpty) {
      return LatLngBounds(southwest: LatLng(0, 0), northeast: LatLng(0, 0));
    }
    double minLat = moments.first.lat, maxLat = moments.first.lat;
    double minLng = moments.first.lng, maxLng = moments.first.lng;
    for (final m in moments) {
      minLat = minLat < m.lat ? minLat : m.lat;
      maxLat = maxLat > m.lat ? maxLat : m.lat;
      minLng = minLng < m.lng ? minLng : m.lng;
      maxLng = maxLng > m.lng ? maxLng : m.lng;
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
      if (mapController != null) {
        await mapController!.animateCamera(
          CameraUpdate.newLatLng(LatLng(moment.lat, moment.lng)),
        );
      }
    } catch (e) {
      // Get.snackbar(
      //   'Error',
      //   'Failed to add moment: $e',
      //   snackPosition: SnackPosition.TOP,
      // );
      rethrow;
    }
  }

  String generateSummary() {
    if (moments.isEmpty) return 'No moments captured yet. Start your journey!'.tr;
    final notes = moments
        .map((m) => '${m.date.day}/${m.date.month}: ${m.note}')
        .join('. ');
    return 'Your Journey Summary: $notes. Relive these special moments and create more!'.tr;
  }

  Future<void> refreshLocation() async {
    try {
      final bool granted = await MyPermissionHandler.checkPermission(
        Get.context!,
        'location',
      );
      if (!granted) {
        MyPermissionHandler.showPermissionDialog(Get.context!, 'location');
        return;
      }
      final position = await LocationService.getCurrentLocation();
      if (mapController != null) {
        await mapController!.animateCamera(
          CameraUpdate.newLatLng(LatLng(position!.latitude, position.longitude)),
        );
      }
    } catch (e) {
      // Get.snackbar('Error', 'Failed to get location: $e');
    }
  }
}
