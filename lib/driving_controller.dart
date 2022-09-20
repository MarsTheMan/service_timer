import 'dart:async';
import 'dart:ui';
import 'package:custom_marker/marker_icon.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_background_service_android/flutter_background_service_android.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'location_controller.dart';

class DrivingController extends GetxController {
  final _endAddress = "".obs;
  final locationController = Get.put(LocationController());
  // final apiNewController = Get.find<ApiNewController>();
  // final myRentingsController = Get.find<MyRentingsController>();
  // final profileController = Get.find<ProfileController>();
  final hours = 0.obs;
  final minutes = 0.obs;
  final seconds = 0.obs;
  final timePassed = 0.obs;
  final charge = 0.00.obs;
  final latitude = 0.00.obs;
  final longitude = 0.00.obs;
  late StreamSubscription<Position> streamSubscription;
  late Timer timer;
  late GoogleMapController drivingMapController;
  BitmapDescriptor currentLocationIcon = BitmapDescriptor.defaultMarker;

  @override
  void onInit() async {
    super.onInit();
    await setCustomIcons();
    await initializeTimerService();
    await getLiveLocation();
    // await locationController.getLiveLocation();
    // if (apiNewController.isActiveRent.value) {
    //   _startTimer(apiNewController.activeRentTime.value.inSeconds);
    //   // compute(_startTimer, apiNewController.activeRentTime.value.inSeconds);
    // } else {
    //   // compute(_startTimer, 0);
    //   _startTimer(0);
    // }
  }

  // @override
  // void onReady() async {
  //   super.onReady();
  //
  // }

  @override
  void onClose() {
    super.onClose();
    timePassed.value = 0;
  }

  Future<void> getLiveLocation() async {
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
      streamSubscription = Geolocator.getPositionStream(
          locationSettings: const LocationSettings(
              accuracy: LocationAccuracy.bestForNavigation))
          .listen((Position position) {
        latitude.value = position.latitude;
        longitude.value = position.longitude;
        drivingMapController.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
              zoom: 18,
              target: LatLng(position.latitude, position.longitude),
            ),
          ),
        );
        // locationPosition.value = LatLng(latitude.value, longitude.value);
        // getLatLang(position);
        // getAddressFromLatLang(position);
      });
    }
  }

  // void _startTimer(int timePassed) {
  //   if (timePassed == 0 || timePassed == null) {
  //     charge.value = 1.20;
  //     timer = Timer.periodic(const Duration(seconds: 1), (timer) {
  //       seconds.value++;
  //       if (seconds.value == 60) {
  //         seconds.value = 0;
  //         minutes.value++;
  //         charge.value += 0.20;
  //         if (minutes.value == 60) {
  //           minutes.value = 0;
  //           hours.value++;
  //         }
  //       }
  //     });
  //   } else {
  //     seconds.value = timePassed;
  //     charge.value = (((timePassed / 60).ceil()) * 0.2) + 1.0;
  //     if (seconds.value >= 60) {
  //       minutes.value = seconds.value ~/ 60;
  //       seconds.value = 0;
  //       if (minutes >= 60) {
  //         hours.value = minutes.value ~/ 60;
  //         minutes.value = 0;
  //       }
  //     }
  //     timer = Timer.periodic(const Duration(seconds: 1), (timer) {
  //       seconds.value++;
  //       if (seconds.value == 60) {
  //         seconds.value = 0;
  //         minutes.value++;
  //         charge.value += 0.20;
  //         if (minutes.value == 60) {
  //           minutes.value = 0;
  //           hours.value++;
  //         }
  //       }
  //     });
  //   }
  // }

  Future<void> setCustomIcons() async {
    // BitmapDescriptor.fromAssetImage(
    //     ImageConfiguration.empty, 'assets/icons/caroo_pin_4.png').then((icon) {currentLocationIcon = icon;});
    currentLocationIcon = await MarkerIcon.pictureAsset(
        assetPath: 'assets/icons/caroo_pin_4.png',
        width: Get.height * 0.18,
        height: Get.height * 0.18);
  }


  String formattedTime({required int timeInSecond}) {
    int sec = timeInSecond % 60;
    int min = (timeInSecond / 60).floor();
    String minute = min.toString().length <= 1 ? "$min" : "$min";
    String second = sec.toString().length <= 1 ? "0$sec" : "$sec";
    return "$minute:$second";
  }

  String formattedCharge({required double charge}) {
    return charge.toStringAsFixed(1);
  }
}

void timerStart(ServiceInstance service) async {
  // Only available for flutter 3.0.0 and later
  DartPluginRegistrant.ensureInitialized();
  // final apiNewController = Get.put(ApiNewController());
  await GetStorage.init();
  var activeRentTime = GetStorage().read<int>("activeRentTime");
  // Timer timer;
  // For flutter prior to version 3.0.0
  // We have to register the plugin manually

  // SharedPreferences preferences = await SharedPreferences.getInstance();
  // await preferences.setString("hello", "world");

  if (service is AndroidServiceInstance) {
    service.on('setAsForeground').listen((event) {
      service.setAsForegroundService();
    });

    service.on('setAsBackground').listen((event) {
      service.setAsBackgroundService();
    });
  }

  service.on('stopService').listen((event) {
    service.stopSelf();
    if (kDebugMode) {
      print('service stopped');
    }
  });

  double charge = 0;
  int seconds = 0;
  int minutes = 0;
  int hours = 0;

  if (activeRentTime != null) {
    if (activeRentTime > 0) {
      // if (kDebugMode) {
      //   print(apiNewController.isActiveRent.value.toString());
      // }
      // var timePassed = apiNewController.activeRentTime.value.inSeconds;
      seconds = activeRentTime;
      charge = (((activeRentTime / 60).ceil()) * 0.2) + 1.0;
      if (seconds >= 60) {
        minutes = seconds ~/ 60;
        seconds = 0;
        if (minutes >= 60) {
          hours = minutes ~/ 60;
          minutes = 0;
        }
      }
    }
  } else {
    seconds = 0;
    minutes = 0;
    hours = 0;
    charge = 1.2;
  }

  Timer.periodic(const Duration(seconds: 1), (timer) {
    seconds++;
    if (seconds == 60) {
      seconds = 0;
      minutes++;
      charge += 0.20;
      if (minutes == 60) {
        minutes = 0;
        hours++;
      }
    }
    service.invoke(
      'update',
      {
        "seconds": seconds,
        "minutes": minutes,
        "hours": hours,
        "charge": charge,
      },
    );
  });
  // bring to foreground
  // Timer.periodic(const Duration(seconds: 1), (timer) async {
  //   final hello = preferences.getString("hello");
  //   print(hello);
  //
  //   if (service is AndroidServiceInstance) {
  //     service.setForegroundNotificationInfo(
  //       title: "My App Service",
  //       content: "Updated at ${DateTime.now()}",
  //     );
  //   }
  //
  //   /// you can see this log in logcat
  //   print('FLUTTER BACKGROUND SERVICE: ${DateTime.now()}');
  //
  //   // test using external plugin
  //   final deviceInfo = DeviceInfoPlugin();
  //   String? device;
  //   if (Platform.isAndroid) {
  //     final androidInfo = await deviceInfo.androidInfo;
  //     device = androidInfo.model;
  //   }
  //
  //   if (Platform.isIOS) {
  //     final iosInfo = await deviceInfo.iosInfo;
  //     device = iosInfo.model;
  //   }
  //

  // });
}

Future<void> initializeTimerService() async {
  final service = FlutterBackgroundService();
  await service.configure(
    androidConfiguration: AndroidConfiguration(
      // this will be executed when app is in foreground or background in separated isolate
      onStart: timerStart,

      // auto start service
      autoStart: true,
      isForegroundMode: true,
    ),
    iosConfiguration: IosConfiguration(
      // auto start service
      autoStart: true,

      // this will be executed when app is in foreground in separated isolate
      onForeground: timerStart,

      // you have to enable background fetch capability on xcode project
      onBackground: onIosBackground,
    ),
  );
  await service.startService();
}

// to ensure this is executed
// run app from xcode, then from xcode menu, select Simulate Background Fetch
bool onIosBackground(ServiceInstance service) {
  WidgetsFlutterBinding.ensureInitialized();
  print('FLUTTER BACKGROUND FETCH');
  return true;
}
