import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:service_timer/style.dart';
import 'package:intl/intl.dart';
import 'package:slide_to_act/slide_to_act.dart';
import 'driving_controller.dart';
import 'location_controller.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: Driving(),
    );
  }
}

class Driving extends StatelessWidget {
  Driving({super.key});
  // static const _platform = const MethodChannel('gr.caroo.Caroo/native');
  // final api = ApiController();
  // final profileController = Get.find<ProfileController>();
  final drivingController = Get.put(DrivingController());
  final locationController = Get.put(LocationController());
  final formatter = NumberFormat("00");

  @override
  Widget build(BuildContext context) {
    // Size size = MediaQuery.of(context).size;
    final initialData = <String, dynamic>{
      "seconds": 0,
      "minutes": 0,
      "hours": 0,
      "charge": 0.0
    };
    //   if (!locationController.isLoading.value) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        body: Stack(
          children: [
            Obx(() {
              return GoogleMap(
                rotateGesturesEnabled: true,
                // trafficEnabled: true,
                // buildingsEnabled: false,
                compassEnabled: false,
                // minMaxZoomPreference: googleMaps.MinMaxZoomPreference(18, 18),
                mapToolbarEnabled: false,
                onMapCreated: (controller) async {
                  drivingController.drivingMapController = controller;
                  controller.setMapStyle(
                      '[{"featureType": "poi","stylers": [{"visibility": "off"}]}]');
                },
                myLocationEnabled: false,
                myLocationButtonEnabled: false,
                zoomControlsEnabled: false,
                markers: {
                  Marker(
                    markerId: const MarkerId("currentLocation"),
                    position: LatLng(drivingController.latitude.value,
                        drivingController.longitude.value),
                    icon: drivingController.currentLocationIcon,
                  ),
                },
                initialCameraPosition: CameraPosition(
                  target: LatLng(drivingController.latitude.value,
                      drivingController.longitude.value),
                  zoom: 18,
                  // tilt: 80,
                  bearing: 30,
                ),
              );
            }),
            Positioned(
              bottom: 40,
              child:
              // Column(
              //   children: [
              //     const SizedBox(height: 10),
              //     SizedBox(
              //       width: Get.width * 0.7,
              //       child: StreamBuilder<Map<String, dynamic>>(
              //           stream: FlutterBackgroundService().on('update'),
              //           // initialData: initialData,
              //           builder: (context, snapshot) {
              //             if (!snapshot.hasData) {
              //               return const Center(
              //                 child: Text("Live data are not supported", style: TextStyle(color: Color(0xDD000000), fontWeight: FontWeight.w400, fontSize: 18,)),
              //               );
              //             } else {
              //               final data = snapshot.data;
              //               var seconds = data["seconds"];
              //               var minutes = data["minutes"];
              //               var hours = data["hours"];
              //               var charge = data["charge"];
              //               return Row(
              //                 mainAxisAlignment:
              //                 MainAxisAlignment.spaceBetween,
              //                 children: [
              //                   Row(
              //                     mainAxisAlignment: MainAxisAlignment.start,
              //                     crossAxisAlignment:
              //                     CrossAxisAlignment.center,
              //                     children: [
              //                       const Icon(
              //                         Icons.timer,
              //                         size: 25,
              //                       ),
              //                       Text(
              //                           '${formatter.format(hours)}:${formatter.format(minutes)}:${formatter.format(seconds)}',
              //                           style: timerHeadLine),
              //                     ],
              //                   ),
              //                   Row(
              //                     mainAxisAlignment: MainAxisAlignment.start,
              //                     crossAxisAlignment:
              //                     CrossAxisAlignment.center,
              //                     children: [
              //                       const Icon(
              //                         Icons.euro,
              //                         size: 25,
              //                       ),
              //                       Text(charge.toStringAsFixed(2),
              //                           style: timerHeadLine),
              //                     ],
              //                   )
              //                 ],
              //               );
              //             }
              //           }),
              //     ),
              // const SizedBox(height: 4),
              // RoundedButton(
              //   text: 'LOCK',
              //   onPress: () async {
              //     _timer.cancel();
              //     Navigator.of(context).pushNamedAndRemoveUntil('/locking', (route) => false);
              //   },
              // ),
              // SpringButton(
              //   SpringButtonType.OnlyScale,
              //   Container(
              //     width: Get.width * 0.8,
              //     padding: const EdgeInsets.symmetric(
              //         vertical: 16, horizontal: 20),
              //     decoration: const BoxDecoration(
              //         color: PrimaryColor,
              //         borderRadius:
              //             BorderRadius.all(Radius.circular(30))),
              //     child: const Text('LOCK',
              //         textAlign: TextAlign.center,
              //         style: TextStyle(
              //           color: Colors.white,
              //           fontWeight: FontWeight.w500,
              //           fontSize: 16,
              //         )),
              //   ),
              //   onTap: () async {
              //     // var triggerResult = null;
              //     // await showPayment(context);
              //     await Get.defaultDialog(title: "All done?", content: Column(
              //       children: const [
              //         Text("Take a moment and make sure you have all your belongings.")],),
              //       confirmTextColor: Colors.white,
              //       cancelTextColor: ButtonColor,
              //       textConfirm: "Proceed to Checkout",
              //       textCancel: "Let me stay",
              //       onConfirm: () async
              //     {
              //       drivingController.timer.cancel();
              //       await drivingController.endRenting();
              //       await Get.offAndToNamed(RoutesClass.getLockingRoute());
              //       },
              //     );
              //   },
              // ),
              Column(
                children: [
                  SizedBox(
                    width: Get.width * 0.6,
                    height: Get.height * 0.08,
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25.0),
                        ),
                        child: StreamBuilder<Map<String, dynamic>?>(
                            stream: FlutterBackgroundService().on('update'),
                            initialData: initialData,
                            builder: (context, snapshot) {
                              final data = snapshot.data!;
                              var seconds = data["seconds"];
                              var minutes = data["minutes"];
                              var hours = data["hours"];
                              var charge = data["charge"];
                              if (!snapshot.hasData) {
                                return const Center(
                                  child: Text("Live data are not supported",
                                      style: timerHeadLine),
                                );
                              } else {
                                return Row(
                                  mainAxisAlignment:
                                  MainAxisAlignment.spaceEvenly,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text(
                                        '${formatter.format(hours)}:${formatter.format(minutes)}:${formatter.format(seconds)}',
                                        style: timerHeadLine),
                                    const Icon(
                                      Icons.timer,
                                      size: 20,
                                      color: primaryColor,
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                      MainAxisAlignment.start,
                                      crossAxisAlignment:
                                      CrossAxisAlignment.center,
                                      children: [
                                        Text(charge.toStringAsFixed(2),
                                            style: timerHeadLine),
                                        const Icon(
                                          Icons.euro,
                                          size: 20,
                                          color: primaryColor,
                                        ),
                                      ],
                                    )
                                  ],
                                );
                              }
                            }),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: Get.width,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: SlideAction(
                        sliderButtonIcon: const Icon(Icons.lock_open,
                            color: backgroundColor, size: 30),
                        submittedIcon: const Icon(Icons.lock,
                            color: backgroundColor, size: 30),
                        sliderButtonIconPadding: 25,
                        innerColor: Colors.transparent,
                        outerColor: buttonColor,
                        textStyle: const TextStyle(
                            color: backgroundColor,
                            fontWeight: FontWeight.w900,
                            fontSize: 25),
                        elevation: 0,
                        height: Get.height * 0.1,
                        text: "Lock".tr,
                        reversed: true,
                        sliderRotate: false,
                        onSubmit: () async {
                          FlutterBackgroundService().invoke('stopService');
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.arrow_back_ios_new_rounded,
                              color: backgroundColor,
                              size: 20,
                            ),
                            Padding(
                              padding:
                              const EdgeInsets.symmetric(horizontal: 60.0),
                              child: Text(
                                "Slide to lock".tr,
                                style: const TextStyle(
                                    color: backgroundColor,
                                    fontFamily: mainFontMedium,
                                    fontWeight: FontWeight.w800,
                                    fontSize: 20),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

