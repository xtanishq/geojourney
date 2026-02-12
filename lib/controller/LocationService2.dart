import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class LocationService2 extends GetxService {
  final Rxn<Position> currentPosition = Rxn<Position>();
  final RxString locationText = 'Fetching location...'.obs;
  bool isFetching = false;

  Future<void> updateLocation() async {
    // Performance: Don't fetch if already fetching or if we already have data
    if (isFetching || currentPosition.value != null) return;

    isFetching = true;
    try {
      // Use your existing service call
      final pos = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high
      );

      currentPosition.value = pos;
      await _buildLocationText(pos);
    } catch (e) {
      locationText.value = 'Location not available'.tr;
      print("Location Error: $e");
    } finally {
      isFetching = false;
    }
  }

  Future<void> _buildLocationText(Position pos) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(pos.latitude, pos.longitude);
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        // Custom format your text here
        locationText.value = "${place.locality}, ${place.administrativeArea}";
      }
    } catch (e) {
      locationText.value = "Unknown Location";
    }
  }
}