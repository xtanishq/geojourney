import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:camera/camera.dart';
import 'package:screenshot/screenshot.dart';
import 'package:snap_journey/configuration/FirebaseAnalyticsService.dart';
import 'package:snap_journey/controller/Cameracontroller.dart';
import 'package:snap_journey/controller/TagStyleController.dart';
import 'package:snap_journey/google_ads_material/ads_variable.dart';
import 'package:snap_journey/in_app_purchase/app.dart';
import 'package:snap_journey/screen/TagStyleScreen.dart';
import 'package:snap_journey/screen/common_screen/constant.dart';
import 'package:snap_journey/screen/common_screen/setting_screen.dart';
import 'package:snap_journey/service/LocationCardWidget.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:snap_journey/service/checkConnectivity.dart';
import 'package:snap_journey/service/dialog.dart';
import 'package:snap_journey/service/possessing_dialog.dart';
import 'package:snap_journey/service/press_unpress.dart';
import 'package:snap_journey/service/sharedPreferencesService.dart';
import 'package:auto_size_text/auto_size_text.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen>
    with TickerProviderStateMixin {
  late AnimationController _recordController;
  final Cameracontroller cameraController = Get.find<Cameracontroller>();
  final ScreenshotController screenshotController = ScreenshotController();
  final GlobalKey _cameraPreviewKey = GlobalKey();
  final GlobalKey _tagKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    FirebaseAnalyticsService.logEvent(eventName: "Snap_Journey_Camera_Screen");
    _recordController = AnimationController(
      vsync: this,
      duration: const Duration(minutes: 5),
    );
    Get.put(TagStyleController());
    cameraController.previewKey = _cameraPreviewKey;
    cameraController.tagKey = _tagKey;
    cameraController.initCamera();
    print({"${cameraController.currentPosition.value} ==========="});
  }

  Future<void> _capturePhoto() async {

    print("called");
    try {
      ProgressDialog.show2("Capturing...".tr);
      final Uint8List? bytes = await screenshotController.capture();
      if (bytes == null) {
        ProgressDialog.dismiss2();
        await cameraController.getCurrentLocation();
        showToast(msg: "Failed to capture screenshot");
        return;
      }
      final dir = await getTemporaryDirectory();
      final tempPath = path.join(
        dir.path,
        '${DateTime.now().millisecondsSinceEpoch}.png',
      );
      await File(tempPath).writeAsBytes(bytes);
      final relativePosition = cameraController.showLocationTag.value
          ? cameraController.computeRelativeTagPosition()
          : null;

      ProgressDialog.dismiss2();
      // cameraController.p
      await cameraController.cameraController?.pausePreview();
     await  Get.toNamed(
        '/preview',
        arguments: {
          'path': tempPath,
          'type': 'photo',
          'lat': cameraController.currentPosition.value?.latitude ?? 0.0,
          'lng': cameraController.currentPosition.value?.longitude ?? 0.0,
          'locationText': cameraController.locationText.value,
          'showTag': cameraController.showLocationTag.value,
          'aspectRatio': cameraController.aspectRatio,
          'isFrontCamera': cameraController.isFrontCamera.value,
          'tagRelativePosition': relativePosition ?? const Offset(0.1, 0.8),
        },
      );
      cameraController.cameraController?.resumePreview();

    } catch (e) {
      ProgressDialog.dismiss2();
      showToast(msg: "Photo capture failed".tr);
      // Get.snackbar(
      //   'Error',
      //   'Photo capture failed: $e',
      //   snackPosition: SnackPosition.BOTTOM,
      // );
    }
  }

  @override
  void dispose() {
    _recordController.dispose();
    cancelCountdown();
    super.dispose();
  }

  Timer? _countDownTimer; // Isse class level par define karein

  void cancelCountdown() {
    if (cameraController.isCountingDown.value) {
      _countDownTimer?.cancel();
      cameraController.isCountingDown.value = false;
      cameraController.countdownValue.value = 0;
      // User ko feedback dene ke liye
      showToast(msg: "Timer stopped".tr);
      // Get.snackbar(
      //   "Cancelled",
      //   "Timer stopped",
      //   snackPosition: SnackPosition.BOTTOM,
      //   backgroundColor: Colors.black54,
      //   colorText: Colors.white,
      // );
    }
  }

  Widget _circleButton(IconData icon, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: const BoxDecoration(
          color: Colors.black45,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white, size: 24),
      ),
    );
  }

  Widget _buildVideoTimer() {
    return Obx(() {
      if (!cameraController.isRecording.value) return const SizedBox.shrink();
      final duration = Duration(
        seconds: cameraController.recordingDuration.value,
      );
      final minutes = duration.inMinutes.toString().padLeft(2, '0');
      final seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');
      return Positioned(
        top: 500.h,
        left: 0,
        right: 0,
        child: Container(
          alignment: Alignment.center,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 40.w, vertical: 30.h),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.7),
              borderRadius: BorderRadius.circular(25),
              border: Border.all(color: Colors.red, width: 2.w),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.videocam, color: Colors.red, size: 30),
                SizedBox(width: 15.w),
                AutoSizeText(
                  '$minutes:$seconds',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 50.sp,
                    fontWeight: FontWeight.bold,
                    shadows: [
                      Shadow(
                        offset: Offset(1, 1),
                        blurRadius: 3,
                        color: Colors.black,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,

      // backgroundColor: appbackgroundColor,
      appBar: AppBar(
        forceMaterialTransparency: true,
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,

        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: CircleAvatar(
            backgroundColor: Colors.black.withOpacity(0.4),
            child: Padding(
              padding: EdgeInsets.only(left: 10.w),
              child: Center(
                child: IconButton(
                  onPressed: () {

                    print("cleick1");
                    if (cameraController.isCountingDown.value) {
                      print("cleick2");
                      cameraController.isCountingDown.value = false;
                      cancelCountdown();

                      Get.back();

                    } else {
                      print("cleick3");

                      // Agar timer nahi hai, toh normal back navigate karein
                      Get.back();
                    }
                  },
                  icon: Icon(Icons.arrow_back_ios, color: Colors.white),
                ),
              ),
            ),
          ),
        ),
        actions: [
          // if (isCameraReady)
          Padding(
            padding: EdgeInsets.only(right: 20.w),
            child: Row(
              // mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                22.horizontalSpace,
                Obx(
                  () => PressUnpress(
                    width: 127.w,
                    height: 127.h,
                    onTap: cameraController.toggleFlash,
                    imageAssetUnPress:
                        cameraController.flashMode.value == FlashMode.off
                        ? "assets/home_screen/flash_off.png"
                        : "assets/home_screen/flash_on_btn.png",
                    imageAssetPress:
                        cameraController.flashMode.value == FlashMode.off
                        ? "assets/home_screen/flash_off_click.png"
                        : "assets/home_screen/flash_on_btn_click.png",
                  ),
                ),
                22.horizontalSpace,
                Obx(
                  () => PressUnpress(
                    width: 127.w,
                    height: 127.h,
                    onTap: cameraController.toggleLocationTag,
                    imageAssetUnPress: cameraController.showLocationTag.value
                        ? "assets/home_screen/location_btn.png"
                        : "assets/home_screen/location_off.png",
                    imageAssetPress: cameraController.showLocationTag.value
                        ? "assets/home_screen/location_btn_click.png"
                        : "assets/home_screen/location_off_click.png",
                  ),
                ),
                22.horizontalSpace,

                cameraController.showLocationTag.value
                    ? 30.verticalSpace
                    : const SizedBox.shrink(),

                CircleAvatar(
                  backgroundColor: Colors.black.withOpacity(0.4),
                  child: Padding(
                    padding: EdgeInsets.only(left: 1.w),
                    child: Center(
                      child: Obx(() {
                        return IconButton(
                          onPressed: () {
                            // Get.back();
                            if (cameraController.timeropen.value) {
                              cameraController.timeropen.value = false;
                              cameraController.menuAnimationController
                                  .reverse(); // Band karo
                            } else {
                              cameraController.isMenuOpen.value =
                                  false; // Purana menu band
                              cameraController.timeropen.value =
                                  true; // Timer menu active
                              cameraController.menuAnimationController.forward(
                                from: 0,
                              ); // Animation shuru se chalao
                            }
                          },
                          icon: Icon(
                            cameraController.timeropen.value
                                ? Icons.close
                                : Icons.alarm_add_outlined,
                            color: Colors.white,
                          ),
                        );
                      }),
                    ),
                  ),
                ),
                25.horizontalSpace,
                Obx(
                  () => cameraController.captureMode.value != 'video'
                      ? _circleButton(
                          cameraController.isMenuOpen.value
                              ? Icons.close
                              : Icons.add,
                          onTap: cameraController.toggleMoreOptions,
                        )
                      : const SizedBox.shrink(),
                ),
              ],
            ),
          ),
        ],
      ),

      body: PopScope(
        canPop: !cameraController.isCountingDown.value,

        // Jab user back press karta hai aur 'canPop' false hota hai,
        // tab yeh function trigger hota hai.
        onPopInvokedWithResult: (didPop, result) {
          if (didPop) {
            // Agar back successful ho gaya (canPop true tha), toh yahan se return ho jao
            return;
          }

          // Agar back block hua (didPop false), toh apna custom action yahan karo
          if (cameraController.isCountingDown.value) {
            cancelCountdown(); // Timer rok do
            print("Back pressed: Countdown cancelled!");
          }
        },
        child: Obx(() {
          final cam = cameraController.cameraController;
          final isCameraReady =
              cameraController.isCameraInitialized.value &&
              cam != null &&
              cam.value.isInitialized;

          if (cameraController.isRecording.value &&
              !_recordController.isAnimating) {
            _recordController.repeat();
          } else if (!cameraController.isRecording.value &&
              _recordController.isAnimating) {
            _recordController.reset();
          }

          return Stack(
            fit: StackFit.expand,
            children: [
              if (isCameraReady)
                Screenshot(
                  controller: screenshotController,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      const ColoredBox(color: Colors.black),
                      Center(
                        child: AspectRatio(
                          key: _cameraPreviewKey,
                          aspectRatio: cameraController.aspectRatio,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(0),
                            child: FittedBox(
                              fit: BoxFit.contain,
                              child: SizedBox(
                                width: cam!.value.previewSize!.height,
                                height: cam.value.previewSize!.width,
                                child: CameraPreview(cam),
                              ),
                            ),
                          ),
                        ),
                      ),

                      _buildUnifiedLocationCard(),
                    ],
                  ),
                )
              else
                Stack(
                  fit: StackFit.expand,
                  children: [
                    Container(color: Colors.black),

                    if (!cameraController.isCameraInitialized.value)
                      const Center(
                        child: CircularProgressIndicator(color: Colors.white),
                      ),
                  ],
                ),
              if (isCameraReady)
                Positioned(
                  top: 300.h,
                  right: 10,
                  child: Obx(() {
                    if (cameraController.captureMode.value != 'video' &&
                        cameraController.isMenuOpen.value &&
                        !cameraController.timeropen.value) {
                      return SizeTransition(
                        sizeFactor: cameraController.menuAnimation!,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: cameraController.aspectLabels
                              .asMap()
                              .entries
                              .map((entry) {
                                final index = entry.key;
                                final label = entry.value;
                                final isSelected =
                                    cameraController.currentAspectIndex.value ==
                                    index;
                                return GestureDetector(
                                  onTap: () =>
                                      cameraController.selectAspectRatio(index),
                                  child: Container(
                                    padding: const EdgeInsets.all(8),
                                    margin: EdgeInsets.symmetric(
                                      vertical: 15.h,
                                      horizontal: 12.w,
                                    ),
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? Colors.white
                                          : Colors.black45,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: AutoSizeText(
                                      label,
                                      style: TextStyle(
                                        fontSize: 45.sp,
                                        color: isSelected
                                            ? Colors.black
                                            : Colors.white,
                                        fontFamily: isSelected
                                            ? fontFamilyBold
                                            : fontFamilyMedium,
                                      ),
                                    ),
                                  ),
                                );
                              })
                              .toList(),
                        ),
                      );
                    } else if (cameraController.captureMode.value != 'video' &&
                        !cameraController.isMenuOpen.value &&
                        cameraController.timeropen.value) {
                      return SizeTransition(
                        sizeFactor: cameraController.menuAnimation!,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: cameraController.timersec
                              .asMap()
                              .entries
                              .map((entry) {
                                final index = entry.key;
                                final label = entry.value;
                                final isSelected =
                                    cameraController.timerIndex.value == index;
                                return GestureDetector(
                                  onTap: () {
                                    cameraController.timerIndex(index);
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.all(8),
                                    margin: EdgeInsets.symmetric(
                                      vertical: 15.h,
                                      horizontal: 12.w,
                                    ),
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? Colors.white
                                          : Colors.black45,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: AutoSizeText(
                                      "$label",
                                      style: TextStyle(
                                        fontSize: 45.sp,
                                        color: isSelected
                                            ? Colors.black
                                            : Colors.white,
                                        fontFamily: isSelected
                                            ? fontFamilyBold
                                            : fontFamilyMedium,
                                      ),
                                    ),
                                  ),
                                );
                              })
                              .toList(),
                        ),
                      );
                    } else {
                      return SizedBox();
                    }

                    // return Container();
                  }),
                ),

              if (cameraController.isCountingDown.value)
                Container(
                  height: Get.height,
                  width: Get.width,
                  color: Colors.black26, // Subtle dimming effect
                  child: Center(
                    child: TweenAnimationBuilder(
                      key: ValueKey(cameraController.countdownValue.value),
                      tween: Tween<double>(begin: 1.5, end: 1.0),
                      duration: const Duration(milliseconds: 500),
                      builder: (context, double value, child) {
                        return Transform.scale(
                          scale: value,
                          child: AutoSizeText(
                            "${cameraController.countdownValue.value}",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 250.sp,
                              // Big Bold Number
                              fontWeight: FontWeight.bold,
                              fontFamily: fontFamilyBold,
                              shadows: [
                                Shadow(
                                  blurRadius: 20,
                                  color: Colors.black45,
                                  offset: Offset(0, 10),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              _buildVideoTimer(),

              Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: EdgeInsets.only(bottom: 50.h),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (isCameraReady)
                        SafeArea(
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: 24.w,
                              vertical: 20.h,
                            ),
                            // Screen edges se gap
                            child: Align(
                              alignment: Alignment.bottomCenter,
                              child: Container(
                                margin: EdgeInsets.symmetric(horizontal: 70.w),
                                width: double.infinity,
                                // Poori width lega
                                height: 190.h,
                                // Height thodi kam ki hai for sleeker look
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.12),
                                  // Glass effect base
                                  borderRadius: BorderRadius.circular(40.r),
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.2),
                                  ),
                                  // Thin border for premium feel
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      blurRadius: 20,
                                      spreadRadius: 5,
                                    ),
                                  ],
                                ),
                                child: ClipRRect(
                                  // To ensure the blur stays inside
                                  borderRadius: BorderRadius.circular(40.r),
                                  child: Row(
                                    children: [
                                      // --- Photo Mode ---
                                      Expanded(
                                        child: Obx(
                                          () => _buildToggleButton(
                                            title: "Photo",
                                            isSelected:
                                                cameraController
                                                    .captureMode
                                                    .value ==
                                                'photo',
                                            icon: Icons.camera_alt_rounded,
                                            onTap: () async {
                                              if (cameraController
                                                  .isRecording
                                                  .value)
                                                await cameraController
                                                    .stopVideo();
                                              cameraController
                                                      .captureMode
                                                      .value =
                                                  'photo';
                                            },
                                          ),
                                        ),
                                      ),
                                      Center(
                                        child: Container(
                                          width: 4.3,
                                          height: 130.h,
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
                                            color: Colors.white.withOpacity(
                                              0.2,
                                            ), // Matches glass theme
                                          ),
                                        ),
                                      ),
                                      // --- Video Mode ---
                                      Expanded(
                                        child: Obx(
                                          () => _buildToggleButton(
                                            title: "Video",
                                            isSelected:
                                                cameraController
                                                    .captureMode
                                                    .value ==
                                                'video',
                                            icon: Icons.videocam_rounded,
                                            onTap: () async {
                                              cameraController
                                                      .captureMode
                                                      .value =
                                                  'video';
                                            },
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),

                      // Capture button - Only show when camera ready
                      if (isCameraReady)
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            PressUnpress(
                              width: 127.w,
                              height: 127.h,
                              onTap: () => Get.to(() => const TagStyleScreen()),
                              imageAssetUnPress:
                                  "assets/home_screen/tag_btn.png",
                              imageAssetPress:
                                  "assets/home_screen/tag_btn_click.png",
                            ),

                            GestureDetector(
                              onTap: () async {
                                await startCaptureLogic();
                              },
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  Obx(
                                    () => AnimatedContainer(
                                      duration: const Duration(
                                        milliseconds: 300,
                                      ),
                                      width: cameraController.isRecording.value
                                          ? 260.w
                                          : 260.w,
                                      height: cameraController.isRecording.value
                                          ? 260.h
                                          : 260.h,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        gradient: RadialGradient(
                                          colors: [
                                            Colors.white.withOpacity(0.2),
                                            Colors.white.withOpacity(0.05),
                                          ],
                                          center: Alignment.center,
                                          radius: 0.9,
                                        ),
                                        border: Border.all(
                                          color: Colors.white.withOpacity(0.4),
                                          width: 9.w,
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(
                                              0.25,
                                            ),
                                            blurRadius: 25,
                                            offset: const Offset(0, 8),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Obx(
                                    () => AnimatedContainer(
                                      duration: const Duration(
                                        milliseconds: 250,
                                      ),
                                      width: cameraController.isRecording.value
                                          ? 210.w
                                          : 180.w,
                                      height: cameraController.isRecording.value
                                          ? 210.h
                                          : 180.h,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color:
                                            cameraController
                                                    .captureMode
                                                    .value ==
                                                'video'
                                            ? (cameraController
                                                      .isRecording
                                                      .value
                                                  ? Colors.redAccent
                                                  : Colors.red.withOpacity(0.8))
                                            : Colors.white.withOpacity(0.95),
                                      ),
                                      child: cameraController.isRecording.value
                                          ? Icon(
                                              Icons.stop_rounded,
                                              color: Colors.white,
                                              size: 126.w,
                                            )
                                          : null,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            cameraController.isRecording.value
                                ? SizedBox.shrink()
                                : PressUnpress(
                                    width: 127.w,
                                    height: 127.h,
                                    onTap: cameraController.toggleCamera,
                                    imageAssetUnPress:
                                        "assets/home_screen/camera_rotate_btn.png",
                                    imageAssetPress:
                                        "assets/home_screen/camera_rotate_btn_click.png",
                                  ),
                          ],
                        ),
                      50.verticalSpace,
                    ],
                  ),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  Future<void> startCaptureLogic() async {
    double seconds =
        cameraController.timersec[cameraController.timerIndex.value];

    if (seconds == 0) {
      // Immediate Capture
      if(!context.mounted){}
      else{
        await _takeimage();

      }
    } else {
      // Countdown Capture
      cameraController.isCountingDown.value = true;
      cameraController.countdownValue.value = seconds.toInt();

      Timer.periodic(const Duration(seconds: 1), (timer) async {
        if (cameraController.countdownValue.value > 1) {
          cameraController.countdownValue.value--;
          // Elite Touch: Add a small beep sound here
        } else {
          timer.cancel();
          cameraController.isCountingDown.value = false;
          cameraController.countdownValue.value = 0;
          if(!context.mounted){}
          else{
            await _takeimage();

          }        }
      });
    }
  }

  Future _takeimage() async {
    if (cameraController.isRecording.value) {
      await cameraController.stopVideo();
    } else {
      ConnectivityService.checkConnectivity().then((value) async {
        if (value) {
          // if (!AdsVariable.isPurchase.value) {
          //   bool canUse = await SharedPreferencesService.canUseTool(
          //     "cameraFreeTrial",
          //     AdsVariable.cameraFreeTrial,
          //   );
          //   if (canUse) {
          //     await SharedPreferencesService.incrementToolUsage(
          //       "cameraFreeTrial",
          //     );
              if (cameraController.captureMode.value == 'photo') {
                await _capturePhoto();
              }
              else {
                await cameraController.startVideoSafe();
              }
            // }
            // else
            // {
            //   await Navigator.push(
            //     context,
            //     MaterialPageRoute(
            //       builder: (context) => const UpsellScreen(item: true),
            //     ),
            //   );
            //   if (AdsVariable.isPurchase.value && context.mounted) {
            //     if (cameraController.captureMode.value == 'photo') {
            //       await _capturePhoto();
            //     } else {
            //       await cameraController.startVideoSafe();
            //     }
            //   }
            // }
          // }










          // else
          // {
          //   if (cameraController.captureMode.value == 'photo') {
          //     await _capturePhoto();
          //   } else {
          //     await cameraController.startVideoSafe();
          //   }
          // }

        }

        else {
          DialogService.showCheckConnectivity(context);
        }
      });
    }
  }

  Widget _buildToggleButton({
    required String title,
    required bool isSelected,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(

        duration: const Duration(milliseconds: 300),
        margin: EdgeInsets.symmetric(horizontal: 100.w),
        padding: EdgeInsets.all(18.w),
        decoration: BoxDecoration(
          color: isSelected ? appColor : Colors.transparent,
          // Naya Terracotta color
          borderRadius: BorderRadius.circular(35.r),
        ),
        child: Icon(
          icon,
          color: isSelected ? Colors.white : Colors.white70,
          size: 30,
        ),
      ),
    );
  }

  Widget _buildUnifiedLocationCard() {
    return Obx(() {
      // 1. In variables ko yahan access karne se Obx inke changes ko "Listen" karega
      final bool isVisible = cameraController.showLocationTag.value;
      final String currentText =
          cameraController.locationText.value; // YEH ZAROORI HAI
      final bool isVideo = cameraController.captureMode.value == 'video';
      final Offset pos = cameraController.tagPosition.value;

      if (!isVisible) return const SizedBox.shrink();

      return Positioned(
        top: isVideo ? 1500.h : pos.dy,
        // left: isVideo ? 0 : pos.dx,
        child: GestureDetector(
          onPanStart: isVideo
              ? null
              : (_) => cameraController.isDragging.value = true,
          onPanUpdate: isVideo ? null : cameraController.updateTagPosition,
          onPanEnd: isVideo
              ? null
              : (_) => cameraController.isDragging.value = false,
          child: GetBuilder<TagStyleController>(
            builder: (tagController) {
              final style = tagController.selectedStyle.value;
              if (style == null) return const SizedBox();

              return RepaintBoundary(
                key: isVideo ? _tagKey : cameraController.tagKey,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: MediaQuery.sizeOf(context).width,
                  child: LocationCardWidget(
                    // 2. Ab ye text real-time update hoga
                    locationText: currentText,
                    style: style,
                    weatherInfo: style.showWeather ? "12°C" : null,
                    coordinates: style.showCoordinates
                        ? "${cameraController.currentPosition.value?.latitude ?? 0}° N, ${cameraController.currentPosition.value?.longitude ?? 0}° E"
                        : null,
                    timestamp: DateTime.now(),
                  ),
                ),
              );
            },
          ),
        ),
      );
    });
  }
}
