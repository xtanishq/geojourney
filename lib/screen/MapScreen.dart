import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:snap_journey/configuration/FirebaseAnalyticsService.dart';
import 'package:snap_journey/controller/MomentsController.dart';
import 'package:snap_journey/google_ads_material/InterstitialAdUtil.dart';
import 'package:snap_journey/google_ads_material/ads_variable.dart';
import 'package:snap_journey/google_ads_material/banner_widget.dart';
import 'package:snap_journey/model/moment.dart';
import 'package:snap_journey/screen/ImagePreviewScreen.dart';
import 'package:snap_journey/screen/VideoPreviewScreen.dart';
import 'package:snap_journey/screen/common_screen/constant.dart';
import 'package:snap_journey/service/marker_utils.dart';
import 'package:snap_journey/service/permission.dart';
import 'package:snap_journey/service/press_unpress.dart';

import '../controller/LocationService2.dart';
import 'package:auto_size_text/auto_size_text.dart';


class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  bool isMenuOpen = false;
  late AnimationController _animationController;
  late Animation<double> _animation;
  final RxSet<Marker> _markers = <Marker>{}.obs;
  var isMapReady = false.obs;
  final Map<String, BitmapDescriptor> _markerCache = {};

  @override
  void initState() {
    super.initState();
    FirebaseAnalyticsService.logEvent(eventName: "Snap_Journey_Map_Screen");
    // Add lifecycle observer to detect when app comes back from settings
    WidgetsBinding.instance.addObserver(this);

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );

    final controller = Get.find<MomentsController>();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await controller.ensureLocationAvailable(context);

      // Only proceed if permission granted
      if (controller.hasLocationPermission.value) {
        await _refreshMarkers();

        if (controller.currentPosition.value != null &&
            controller.mapController != null) {
          await controller.mapController!.animateCamera(
            CameraUpdate.newLatLngZoom(
              LatLng(
                controller.currentPosition.value!.latitude,
                controller.currentPosition.value!.longitude,
              ),
              16,
            ),
          );
        }
      }
    });

  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    // When app comes back to foreground (from Settings)
    if (state == AppLifecycleState.resumed) {
      print('🔄 App resumed - checking permission status...');
      final controller = Get.find<MomentsController>();

      Future.delayed(const Duration(milliseconds: 800), () async {
        await controller.checkLocationPermission();
        if (controller.hasLocationPermission.value && mounted) {
          await controller.fetchCurrentLocation(context: context);
          await _refreshMarkers();

          if (controller.currentPosition.value != null &&
              controller.mapController != null) {
            await controller.mapController!.animateCamera(
              CameraUpdate.newLatLngZoom(
                LatLng(
                  controller.currentPosition.value!.latitude,
                  controller.currentPosition.value!.longitude,
                ),
                16,
              ),
            );
          }
        }
      });
    }
  }

  Future<BitmapDescriptor> _getMarker(Moment m) async {
    final key = '${m.key}_${m.previewPath}_${m.caption}';
    if (_markerCache.containsKey(key)) return _markerCache[key]!;

    final isVideo = m.videoPaths.isNotEmpty && m.photoPaths.isEmpty;
    final previewPath = m.previewPath.isNotEmpty ? m.previewPath : null;

    final marker = await MarkerUtils.createCustomMarker(
      previewPath: previewPath,
      caption: m.caption ?? m.note ?? 'Moment',
      isVideo: isVideo,
      width: 180,
    );

    _markerCache[key] = marker;
    return marker;
  }

  Future<void> _refreshMarkers() async {
    final controller = Get.find<MomentsController>();
    final markers = <Marker>{};

    final mediaMoments = controller.moments.where(
      (m) =>
          m.hasLocation && (m.photoPaths.isNotEmpty || m.videoPaths.isNotEmpty),
    );

    final futures = mediaMoments.map((m) async {
      final icon = await _getMarker(m);
      return Marker(
        markerId: MarkerId(m.key.toString()),
        position: LatLng(m.lat, m.lng),
        icon: icon,
        onTap: () {
          if (m.photoPaths.isNotEmpty) {
            Get.to(() => ImagePreviewScreen(moment: m));
          } else if (m.videoPaths.isNotEmpty) {
            Get.to(() => VideoPreviewScreen(moment: m));
          }
        },
      );
    }).toList();

    final markerList = await Future.wait(futures);
    markers.addAll(markerList);

    if (controller.currentPosition.value != null) {
      markers.add(
        Marker(
          markerId: const MarkerId('current'),
          position: LatLng(
            controller.currentPosition.value!.latitude,
            controller.currentPosition.value!.longitude,
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        ),
      );
    }

    _markers.value = markers;
  }

  void toggleMenu() {
    setState(() {
      isMenuOpen = !isMenuOpen;
      isMenuOpen
          ? _animationController.forward()
          : _animationController.reverse();
    });
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<MomentsController>();

    ever(controller.moments, (_) {
      if (controller.hasLocationPermission.value) {
        _refreshMarkers();
      }
    });

    ever(controller.currentPosition, (_) {
      if (controller.hasLocationPermission.value) {
        _refreshMarkers();
      }
    });

    return Scaffold(
      backgroundColor: appbackgroundColor,
      body: WillPopScope(
        onWillPop: () async {
          back();
          return false;
        },
        child: Column(
          children: [
            Expanded(
              child: Obx(() {
                print(
                  '🗺️ Building map UI - hasPermission: ${controller.hasLocationPermission.value}',
                );

                final LocationService2 _locationService = Get.find<LocationService2>();

                // Use a getter to point to the service's variable
                // This makes it act like a local variable in your controller
                // Rxn<Position> get currentPosition => _locationService.currentPosition;
                final position = _locationService.currentPosition.value;
                if (position == null) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CupertinoActivityIndicator(
                          color: appColor,
                          radius: 40.w,
                        ),
                        20.verticalSpace,
                        AutoSizeText(
                          'Getting your location...',
                          style: TextStyle(
                            fontSize: 45.sp,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return Stack(
                  children: [
                    GoogleMap(
                      onMapCreated: (mapCtrl) async {
                        controller.mapController = mapCtrl;
                        if (position != null) {
                          await mapCtrl.animateCamera(
                            CameraUpdate.newLatLngZoom(
                              LatLng(position.latitude, position.longitude),
                              16,
                            ),
                          );
                        }
                      },
                      initialCameraPosition: CameraPosition(
                        target: LatLng(position.latitude, position.longitude),
                        zoom: 16,
                      ),
                      myLocationEnabled: true,
                      myLocationButtonEnabled: false,
                      zoomControlsEnabled: false,
                      mapType: controller.mapType.value,
                      markers: _markers.value,
                    ),
                    _buildUIOverlay(controller),
                  ],
                );
              }),
            ),
            Obx(
              () => AdsVariable.isPurchase.isFalse
                  ? BannerTemplate(
                      bannerId: AdsVariable.banner_map_screen,
                    ).marginOnly(top: 40.h)
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildUIOverlay(MomentsController controller) {
    return Stack(
      children: [
        SafeArea(
          child:
          Align(
            alignment: Alignment.topLeft,
            child: Padding(
              padding:  EdgeInsets.symmetric(horizontal: 30.w),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  PressUnpress(
                    onTap: () {
                      back();
                    },
                    height: 120.h,
                    width: 120.w,
                    imageAssetPress: 'assets/home_screen/back_arrow_click.png',
                    imageAssetUnPress: 'assets/home_screen/back_arrow.png',
                  ).marginAll(30.w),

                  Padding(
                    padding:  EdgeInsets.only(right: 15.w),
                    child: CircleAvatar(
                      backgroundColor: controller.mapType.value == MapType.satellite?Colors.white.withOpacity(0.6):Colors.black.withOpacity(0.2),
                      child: IconButton(onPressed: () => toggleMenu(), icon: Icon(Icons.keyboard_arrow_down,size: 25,)),
                    ),
                  )
                  // PressUnpress(
                  //   onTap: () => toggleMenu(),
                  //   height: 154.h,
                  //   width: 154.w,
                  //   imageAssetPress: 'assets/map_screen/arrow_down_click.png',
                  //   imageAssetUnPress: 'assets/map_screen/arrow_down.png',
                  // ),
                ],
              ),
            ),
          ),
        ),
        Positioned(
          top: 180.h,
          right: 10.w,
          child: SafeArea(
            child: Column(
               // mainAxisAlignment: MainAxisAlignment.end,
              children: [

                SizeTransition(
                  sizeFactor: _animation,
                  axisAlignment: -1.0,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 20.w,
                      vertical: 30.h,
                    ),
                    margin: EdgeInsets.symmetric(horizontal: 18.w),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.4),
                      borderRadius: BorderRadius.all(Radius.circular(30)),
                    ),
                    child: Row(
                      children: [
                        PressUnpress(
                          onTap: () async {
                            await controller.ensureLocationAvailable(context);
                            await controller.centerOnCurrentLocation(
                              context: context,
                            );

                          },
                          height: 127.h,
                          width: 127.w,
                          imageAssetPress:
                              'assets/map_screen/current_location_btn_click.png',
                          imageAssetUnPress:
                              'assets/map_screen/current_location_btn.png',
                        ),
                        30.horizontalSpace,
                        PressUnpress(
                          onTap: () {
                            controller.mapType.value = MapType.normal;

                            isMenuOpen = !isMenuOpen;

                            if (isMenuOpen) {
                              _animationController.forward();
                            } else {
                              _animationController.reverse();
                            }                          },

                          height: 127.h,
                          width: 127.w,
                          imageAssetPress: 'assets/map_screen/map_current.png',
                          imageAssetUnPress:
                              'assets/map_screen/map_current.png',
                        ),
                        30.horizontalSpace,
                        PressUnpress(
                          onTap: () {
                            controller.mapType.value = MapType.satellite;

                            isMenuOpen = !isMenuOpen;
                            if (isMenuOpen) {
                              _animationController.forward();
                            } else {
                              _animationController.reverse();
                            }
                          },
                          height: 127.h,
                          width: 127.w,
                          imageAssetPress:
                              'assets/map_screen/satellite_map.png',
                          imageAssetUnPress:
                              'assets/map_screen/satellite_map.png',
                        ),
                        30.horizontalSpace,
                        PressUnpress(
                          onTap: () {
                            controller.mapType.value = MapType.terrain;

                            isMenuOpen = !isMenuOpen;
                            if (isMenuOpen) {
                              _animationController.forward();
                            } else {
                              _animationController.reverse();
                            }
                          },
                          height: 127.h,
                          width: 127.w,
                          imageAssetPress: 'assets/map_screen/terrain_map.png',
                          imageAssetUnPress:
                              'assets/map_screen/terrain_map.png',
                        ),
                        30.horizontalSpace,
                        // PressUnpress(
                        //   onTap: () => toggleMenu(),
                        //   height: 127.h,
                        //   width: 127.w,
                        //   imageAssetPress:
                        //       'assets/map_screen/arrow_up_click.png',
                        //   imageAssetUnPress: 'assets/map_screen/arrow_up.png',
                        // ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        SafeArea(
          child: Align(
            alignment: Alignment.bottomRight,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  PressUnpress(
                    onTap: () => _zoomIn(),
                    height: 169.h,
                    width: 169.w,
                    imageAssetPress: 'assets/map_screen/zoom_click.png',
                    imageAssetUnPress: 'assets/map_screen/zoom.png',
                  ),
                  30.verticalSpace,
                  PressUnpress(
                    onTap: () => _zoomOut(),
                    height: 169.h,
                    width: 169.w,
                    imageAssetPress: 'assets/map_screen/zoomout_click.png',
                    imageAssetUnPress: 'assets/map_screen/zoom_out.png',
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  void back() {
    InterstitialAdManager.showInterstitial(
      onAdDismissed: () {
        Get.back();
      },
      id: AdsVariable.fullscreen_map_screen,
      isContinue: AdsVariable.map_screen_ad_continue_ads_online,
      flag: AdsVariable.mapFlag,
      context: context,
    );

    AdsVariable.mapFlag++;
  }

  Future<void> _zoomIn() async {
    final zoom =
        await Get.find<MomentsController>().mapController?.getZoomLevel() ?? 16;
    Get.find<MomentsController>().mapController?.animateCamera(
      CameraUpdate.zoomTo(zoom + 1),
    );
  }

  Future<void> _zoomOut() async {
    final zoom =
        await Get.find<MomentsController>().mapController?.getZoomLevel() ?? 16;
    Get.find<MomentsController>().mapController?.animateCamera(
      CameraUpdate.zoomTo(zoom - 1),
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _animationController.dispose();
    super.dispose();
  }
}
