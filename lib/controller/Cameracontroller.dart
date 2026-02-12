import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:auto_size_text/auto_size_text.dart';

import 'package:ffmpeg_kit_flutter_new/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter_new/return_code.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geocoding/geocoding.dart';
import 'package:get/get.dart';
import 'package:camera/camera.dart';
import 'package:geolocator/geolocator.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:permission_handler/permission_handler.dart';
import 'package:snap_journey/controller/TagStyleController.dart';
import 'package:snap_journey/screen/TagStyleScreen.dart';
import 'package:snap_journey/screen/common_screen/constant.dart';
import 'package:snap_journey/service/permission.dart';
import 'package:snap_journey/service/LocationService.dart';
import 'package:snap_journey/model/moment.dart';
import 'package:snap_journey/service/DatabaseService.dart';
import 'package:snap_journey/controller/MomentsController.dart';
import 'package:snap_journey/service/possessing_dialog.dart';
import 'package:flutter/rendering.dart';
import 'package:snap_journey/service/press_unpress.dart';

import 'LocationService2.dart';

class Cameracontroller extends GetxController
    with GetSingleTickerProviderStateMixin {

  CameraController? _cameraController;

  CameraController? get cameraController => _cameraController;
  var _allPermissionsGranted = false.obs;

  bool get allPermissionsGranted => _allPermissionsGranted.value;
  var isRecording = false.obs;
  var flashMode = FlashMode.off.obs;
  var isFrontCamera = false.obs;
  // var currentPosition = Rxn<Position>();
  var isCameraInitialized = false.obs;
  var showLocationTag = true.obs;
  var recordingDuration = 0.obs;
  var tagPosition = Rx<Offset>( Offset(50, 1500.h));
  var isDragging = false.obs;
  GlobalKey previewKey = GlobalKey();
  GlobalKey tagKey = GlobalKey();
  var captureMode = 'photo'.obs;
  final List<double> timersec = [0, 3, 5, 7, 10]; // 0 added for 'Off' state
  RxInt timerIndex = 0.obs; // Default to 'Off'
  RxInt countdownValue = 0.obs;
  RxBool isCountingDown = false.obs;

  final List<double> aspectRatios = [1.0, 0.75, 0.5625, 1.7778, 0.0];
  final List<String> aspectLabels = [
    '1:1',
    '3:4',
    '9:16',
    '16:9',
    'Fullscreen',
  ];
  var currentAspectIndex = 4.obs;

  double get aspectRatio {
    if (currentAspectIndex.value == 4)
    {
      return MediaQuery.of(Get.context!).size.aspectRatio;
    }
    return aspectRatios[currentAspectIndex.value];
  }

  late AnimationController menuAnimationController;
  Animation<double>? menuAnimation;
  var isMenuOpen = false.obs;
  var timeropen = false.obs;
  Timer? _locationTimer;
  Timer? _recordingTimer;
  final LocationService2 _locationService = Get.find<LocationService2>();

  // Use a getter to point to the service's variable
  // This makes it act like a local variable in your controller
  Rxn<Position> get currentPosition => _locationService.currentPosition;
  // var locationText = 'Fetching location...'.obs;

  RxString get locationText => _locationService.locationText;
  @override
  void onInit() {
    super.onInit();
    menuAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    menuAnimation = CurvedAnimation(
      parent: menuAnimationController,
      curve: Curves.easeInOut,
    );

    // if(frommaps){
    //   _initCamera();
    // }


    if (currentPosition.value == null) {
      _locationService.updateLocation();
      // getCurrentLocation();
    }
  }





  Widget get permissionBlocker => Center(
    child: Container(
      padding: EdgeInsets.all(60.w),
      margin: EdgeInsets.symmetric(horizontal: 80.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          20.verticalSpace,
          Icon(Icons.camera_alt_outlined, size: 150.w, color: Colors.blue),
          30.verticalSpace,
          AutoSizeText(
            "Camera & Microphone Access Needed",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 60.sp,
              fontFamily: fontFamilyBold,
              color: Colors.black87,
            ),
          ),
          20.verticalSpace,
          AutoSizeText(
            "We need access to your camera and microphone to let you capture photos and record videos with audio. This allows you to create and preserve your precious memories.",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 45.sp,
              color: Colors.black54,
              fontFamily: fontFamilyMedium,
            ),
          ),
          40.verticalSpace,

          PressUnpress(
            width: 750.w,
            height: 180.h,
            onTap: () async {
              // await _requestAllPermissions();
            },
            pressLinearGradient: pressLinearGradiant,
            unPressLinearGradient: unPressLinearGradiant,
            child: Center(
              child: AutoSizeText(
                "Allow Camera & Microphone",
                style: TextStyle(
                  fontSize: 45.sp,
                  color: Colors.white,
                  fontFamily: fontFamilySemiBold,
                ),
              ),
            ),
          ),

          40.verticalSpace,
        ],
      ),
    ),
  );

  // Future<void> _requestAllPermissions() async {
  //   ProgressDialog.show2("Please wait...");
  //
  //   final cameraStatus = await Permission.camera.request();
  //   final micStatus = await Permission.microphone.request();
  //
  //   await Permission.locationWhenInUse.request();
  //
  //   ProgressDialog.dismiss2();
  //
  //   final camGranted = cameraStatus.isGranted || cameraStatus.isLimited;
  //   final micGranted = micStatus.isGranted || micStatus.isLimited;
  //
  //   final allGranted = camGranted && micGranted;
  //
  //   _allPermissionsGranted.value = allGranted;
  //
  //   if (allGranted) {
  //     await _initCamera();
  //   } else {
  //     if (cameraStatus.isPermanentlyDenied || micStatus.isPermanentlyDenied) {
  //       MyPermissionHandler.showPermissionDialog(Get.context!, 'camera');
  //     }
  //   }
  // }

  // void retryPermission() => _requestAllPermissions();

  String formattedDate = '';
  String formattedTime = '';

  Future<void> _buildLocationText(Position position) async {
    try {
      final places = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );
      if (places.isNotEmpty) {
        final place = places.first;
        locationText.value =
            '${place.name ?? ''}, ${place.subLocality ?? ''}, ${place.locality ?? ''}, ${place.postalCode ?? ''}, ${place.administrativeArea ?? ''}, ${place.country ?? ''}\nDate: $formattedDate Latitude:${position.latitude.toStringAsFixed(4)}\n$formattedTime Longitude:${position.longitude.toStringAsFixed(4)}';
      } else {
        locationText.value = 'Location not available';
      }
    } catch (e) {
      locationText.value = 'Location not available';
    }
  }

  Future<void> initCamera() async {
    ProgressDialog.show2("Setting up camera...".tr);


    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        Get.snackbar(
          'Error',
          'No cameras available',
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      _cameraController?.dispose();
      final index = isFrontCamera.value ? cameras.length - 1 : 0;

      _cameraController = CameraController(
        cameras[index],
        ResolutionPreset.veryHigh,
        enableAudio: true,
        imageFormatGroup: ImageFormatGroup.jpeg,
      );

      await _cameraController!.initialize();

      isCameraInitialized.value = true;
      // await getCurrentLocation();
      update();
    } catch (e) {
      Get.snackbar(
        'Error',
        'Camera initialization failed: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
      print(e);
      isCameraInitialized.value = false;
    } finally {
      ProgressDialog.dismiss2();
    }
  }


  Future<void> getCurrentLocation() async {
    ProgressDialog.show2("Getting location...".tr);
    try {
      final granted = await MyPermissionHandler.checkPermission(
        Get.context!,
        'location',
      );
      if (!granted) {
        MyPermissionHandler.showPermissionDialog(Get.context!, 'location');
        locationText.value = 'Location not available'.tr;
        return;
      }
      final pos = await LocationService.getCurrentLocation();
      if (pos != null) {
        currentPosition.value = pos;
        await _buildLocationText(pos);
      } else {
        locationText.value = 'Location not available'.tr;
      }
    } catch (e) {
      locationText.value = 'Location not available'.tr;
    } finally {

      print(locationText+"=========");
      ProgressDialog.dismiss2();
      update();
    }
  }

  Offset? computeRelativeTagPosition() {
    if (previewKey.currentContext == null) return null;
    final box = previewKey.currentContext!.findRenderObject() as RenderBox;
    final previewSize = box.size;
    final previewOffset = box.localToGlobal(Offset.zero);

    double relativeX =
        ((tagPosition.value.dx - previewOffset.dx) / previewSize.width).clamp(
          0.0,
          1.0,
        );
    double relativeY =
        ((tagPosition.value.dy - previewOffset.dy) / previewSize.height).clamp(
          0.0,
          1.0,
        );

    if (isFrontCamera.value) relativeX = 1 - relativeX;

    return Offset(relativeX, relativeY);
  }

  Future<void> startVideoSafe() async {
    try {
      if (_cameraController == null ||
          !_cameraController!.value.isInitialized ||
          isRecording.value ||
          !isCameraInitialized.value) {
        Get.snackbar(
          'Error',
          'Camera not ready for recording',
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      if (_cameraController!.value.isRecordingVideo) {
        Get.snackbar(
          'Error',
          'Camera is already recording',
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      // await getCurrentLocation();
      await _cameraController!.startVideoRecording();
      isRecording.value = true;
      _startRecordingTimer();
      print('✅ Video recording started safely');
    } catch (e) {
      print('❌ Safe video start failed: $e');
      isRecording.value = false;
      Get.snackbar(
        'Error',
        'Failed to start recording: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // Future<void> startVideo() async {
  //   if (_cameraController == null ||
  //       !_cameraController!.value.isInitialized ||
  //       isRecording.value ||
  //       !isCameraInitialized.value) {
  //     Get.snackbar(
  //       'Error',
  //       'Camera not ready',
  //       snackPosition: SnackPosition.BOTTOM,
  //     );
  //     return;
  //   }
  //   try {
  //     // await getCurrentLocation();
  //     await _cameraController!.startVideoRecording();
  //     isRecording.value = true;
  //     _startRecordingTimer();
  //   } catch (e) {
  //     Get.snackbar(
  //       'Error',
  //       'Video start failed: $e',
  //       snackPosition: SnackPosition.BOTTOM,
  //     );
  //   }
  // }

  void _startRecordingTimer() {
    recordingDuration.value = 0;
    _recordingTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (isRecording.value) {
        recordingDuration.value++;
      } else {
        timer.cancel();
      }
    });
  }

  Future<String?> _processVideoWithFixedOverlay(String videoPath) async {
    ProgressDialog.show2("Processing video...".tr);
    try {
      Uint8List? tagPngBytes;
      if (showLocationTag.value) {
        tagPngBytes = await _captureFixedTagForVideoOverlay();
        if (tagPngBytes == null) {
          print('⚠️ Could not capture tag for overlay, proceeding without tag');
        }
      }

      String finalVideoPath = videoPath;

      if (showLocationTag.value && tagPngBytes != null) {
        final overlayPath = await _saveTagToTempFile(tagPngBytes);
        if (overlayPath != null) {
          final processedPath = await _addFixedBottomOverlay(
            videoPath,
            overlayPath,
          );
          if (processedPath != null) {
            finalVideoPath = processedPath;
            File(
              overlayPath,
            ).delete().catchError((e) => print('Cleanup error: $e'));
          }
        }
      }

      return finalVideoPath;
    } catch (e) {
      print('❌ Video processing error: $e');
      return videoPath;
    } finally {
      ProgressDialog.dismiss2();
    }
  }

  Future<Uint8List?> _captureFixedTagForVideoOverlay() async {
    if (tagKey.currentContext == null) {
      print('❌ Tag key not available for video overlay');
      return null;
    }

    try {
      final boundary =
          tagKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      final uiImage = await boundary.toImage(pixelRatio: 2.0);
      final byteData = await uiImage.toByteData(format: ui.ImageByteFormat.png);
      uiImage.dispose();

      return byteData?.buffer.asUint8List();
    } catch (e) {
      print('❌ Tag capture failed: $e');
      return null;
    }
  }

  Future<String?> _saveTagToTempFile(Uint8List pngBytes) async {
    try {
      final dir = await getTemporaryDirectory();
      final tempPath = path.join(
        dir.path,
        'video_tag_${DateTime.now().millisecondsSinceEpoch}.png',
      );
      await File(tempPath).writeAsBytes(pngBytes);
      return tempPath;
    } catch (e) {
      print('❌ Failed to save tag file: $e');
      return null;
    }
  }

  Future<String?> _addFixedBottomOverlay(
    String videoPath,
    String overlayPath,
  ) async {
    ProgressDialog.show2("Adding location overlay...".tr);
    try {
      final dir = await getTemporaryDirectory();
      final outputPath = path.join(
        dir.path,
        'overlayed_${DateTime.now().millisecondsSinceEpoch}.mp4',
      );

      String filterComplex = '[0:v][1:v]overlay=(W-w)/2:H-h-25';

      if (isFrontCamera.value) {
        filterComplex =
            '[0:v]hflip[flipped];[flipped][1:v]overlay=(W-w)/2:H-h-25';
      }

      final command = [
        '-i',
        videoPath,
        '-i',
        overlayPath,
        '-filter_complex',
        filterComplex,
        '-c:v',
        'libx264',
        '-preset',
        'ultrafast',
        '-crf',
        '23',
        '-c:a',
        'copy',
        '-movflags',
        '+faststart',
        '-y',
        outputPath,
      ].join(' ');

      final session = await FFmpegKit.execute(command);
      final returnCode = await session.getReturnCode();

      if (ReturnCode.isSuccess(returnCode)) {
        final outputFile = File(outputPath);
        if (await outputFile.exists() && await outputFile.length() > 1000) {
          print('✅ Video overlay processed: $outputPath');
          return outputPath;
        }
      }
      return null;
    } catch (e) {
      print('❌ Overlay processing failed: $e');
      return null;
    } finally {
      ProgressDialog.dismiss2();
    }
  }

  Future<void> stopVideo() async {
    if (_cameraController == null || !isRecording.value) return;

    ProgressDialog.show2("Stopping recording...".tr);
    try {
      final rawVideoFile = await _cameraController!.stopVideoRecording();
      isRecording.value = false;
      _recordingTimer?.cancel();
      // await getCurrentLocation();
      String finalVideoPath = rawVideoFile.path;

      if (captureMode.value == 'video' && showLocationTag.value) {
        print('🎬 Processing video with fixed tag overlay...');
        final processedPath = await _processVideoWithFixedOverlay(
          finalVideoPath,
        );
        if (processedPath != null) {
          finalVideoPath = processedPath;
        }
      }

      Get.toNamed(
        '/preview',
        arguments: {
          'path': finalVideoPath,
          'type': 'video',
          'lat': currentPosition.value?.latitude ?? 0.0,
          'lng': currentPosition.value?.longitude ?? 0.0,
          'locationText': locationText.value,
          'showTag': showLocationTag.value,
          'aspectRatio': aspectRatio,
          'isFrontCamera': isFrontCamera.value,
        },
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to stop recording: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      ProgressDialog.dismiss2();
    }
  }

  void updateTagPosition(DragUpdateDetails details) {
    if (previewKey.currentContext == null) return;

    final box = previewKey.currentContext!.findRenderObject() as RenderBox;
    final previewSize = box.size;
    final previewOffset = box.localToGlobal(Offset.zero);

    double cardWidth = 200.0;
    double cardHeight = 100.0;
    if (tagKey.currentContext != null) {
      final tagBox = tagKey.currentContext!.findRenderObject() as RenderBox;
      cardWidth = tagBox.size.width;
      cardHeight = tagBox.size.height;
    }

    var newPosition = tagPosition.value + details.delta;
    newPosition = Offset(
      newPosition.dx.clamp(
        previewOffset.dx,
        previewOffset.dx + previewSize.width - cardWidth,
      ),
      newPosition.dy.clamp(
        previewOffset.dy,
        previewOffset.dy + previewSize.height - cardHeight,
      ),
    );

    tagPosition.value = newPosition;
    update();
  }

  void toggleLocationTag() {
    final tagController = Get.find<TagStyleController>();
    if (!showLocationTag.value && tagController.selectedStyle.value == null) {
      Get.to(() => const TagStyleScreen());
      return;
    }
    showLocationTag.value = !showLocationTag.value;

    if (showLocationTag.value) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (previewKey.currentContext == null || tagKey.currentContext == null)
          return;

        // final previewBox =
        //     previewKey.currentContext!.findRenderObject() as RenderBox;
        // final previewSize = previewBox.size;
        // final tagBox = tagKey.currentContext!.findRenderObject() as RenderBox;
        // final tagSize = tagBox.size;

        // tagPosition.value = Offset(
        //   (previewSize.width - tagSize.width) / 2,
        //   (previewSize.height - tagSize.height) / 2,
        // );
      });
    }
  }

  Future<void> toggleCamera() async {
    if (_cameraController == null) return;

    try {
      // 1. Stop recording if active (important to release resources cleanly)
      if (isRecording.value) {
        await _cameraController!.stopVideoRecording().catchError((_) {});
        isRecording.value = false;
      }

      // 2. Remember current state before disposal
      final wantFrontCamera = !isFrontCamera.value;

      // 3. Clean up current controller
      await _cameraController!.dispose();
      _cameraController = null;
      isCameraInitialized.value = false;
      update(); // optional: early UI feedback

      // 4. Small breathing room (usually not needed >100–200ms, but helps stability)
      await Future.delayed(const Duration(milliseconds: 150));

      // 5. Select desired lens direction
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        Get.snackbar('Error', 'No cameras available');
        return;
      }

      final desiredDirection = wantFrontCamera
          ? CameraLensDirection.front
          : CameraLensDirection.back;

      final camera = cameras.firstWhere(
            (c) => c.lensDirection == desiredDirection,
        orElse: () => cameras.first, // fallback to any available camera
      );

      // 6. Create & initialize new controller
      _cameraController = CameraController(
        camera,
        ResolutionPreset.veryHigh,
        enableAudio: true,
        imageFormatGroup: ImageFormatGroup.jpeg,
      );

      await _cameraController!.initialize();

      // 7. Finalize state
      isFrontCamera.value = wantFrontCamera;
      if (isFrontCamera.value) {
        flashMode.value = FlashMode.off; // front cameras usually don't support flash
      }

      isCameraInitialized.value = true;
      update();

      print('Camera switched → ${isFrontCamera.value ? "front" : "back"}');
    } catch (e, stack) {
      print('Camera switch failed: $e');
      // Optional: only show snackbar for serious errors
      Get.snackbar(
        'Camera Error',
        'Failed to switch camera${e.toString().contains("Permission") ? " – check permissions" : ""}',
      );
    }
  }
  Future<void> toggleFlash() async {
    final newMode = flashMode.value == FlashMode.off
        ? FlashMode.torch
        : FlashMode.off;

    flashMode.value = newMode;
    await _cameraController?.setFlashMode(newMode);
  }

  void toggleMoreOptions() {
    isMenuOpen.value = !isMenuOpen.value;
    timeropen.value=false;
    if (isMenuOpen.value) {
      menuAnimationController.forward();
    } else {
      menuAnimationController.reverse();
    }
  }

  void selectAspectRatio(int index) {
    currentAspectIndex.value = index;
    update();
  }
void selecttimer(int index) {
    timerIndex.value = index;
    update();
  }

  Future<void> saveMoment(Moment moment) async {
    ProgressDialog.show2("Saving moment...".tr);
    try {
      await DatabaseService.addMoment(moment);
      final momentsController = Get.find<MomentsController>();
      await momentsController.loadMoments();
      Get.back();
      showToast(msg: "Moment saved successfully!".tr);
      // Get.snackbar(
      //   'Success',
      //   'Moment saved successfully!',
      //   snackPosition: SnackPosition.BOTTOM,
      // );
    } catch (e) {
      showToast(msg: "Failed to save moment".tr);

      // Get.snackbar(
      //   'Error',
      //   'Failed to save moment: $e',
      //   snackPosition: SnackPosition.BOTTOM,
      // );
    } finally {
      ProgressDialog.dismiss2();
    }
  }

  @override
  void onClose() {
    _cameraController?.dispose();
    _locationTimer?.cancel();
    _recordingTimer?.cancel();
    menuAnimationController.dispose();
    super.onClose();
  }
}
