import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class LocationController extends GetxController {
  final latitude = 0.00.obs;
  final longitude = 0.00.obs;
  final address = ''.obs;
  final isLoading = false.obs;
  final startLocation = Rxn<LatLng>();
  final endLocation = Rxn<LatLng>();

  late Position currentPosition;
  late StreamSubscription<Position> streamSubscription;

  @override
  void onInit() async {
    super.onInit();
    await _getUserLocation();
    // await getCurrentLocation();
    // getCurrentLocation();
  }

  @override
  void onClose() async {
    super.onClose();
    streamSubscription.cancel();
  }

  Future<void> _getUserLocation() async {
    isLoading.value = true;
    bool serviceEnabled;
    LocationPermission permission;
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await Geolocator.openLocationSettings();
      if (!serviceEnabled) {
        Get.snackbar("Location error", "Location services are closed");
      }
    }
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        Get.snackbar("Error", "Location permissions are denied");
        return Future.error("Location permissions are denied");
      }
    }
    if (permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse) {
      streamSubscription =
          Geolocator.getPositionStream(locationSettings: const LocationSettings(accuracy: LocationAccuracy.best)).listen((Position position) {
            latitude.value = position.latitude;
            longitude.value = position.longitude;
            // locationPosition.value = LatLng(latitude.value, longitude.value);
            // getLatLang(position);
            // getAddressFromLatLang(position);
          });
    }
    isLoading.value = false;
  }

  Future<double> calculateRideDistance(
      LatLng startLocation, LatLng endLocation) async {
    var distanceInMeters = Geolocator.distanceBetween(startLocation.latitude,
        startLocation.longitude, endLocation.latitude, endLocation.longitude);
    return distanceInMeters;
  }
}
