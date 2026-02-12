import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:snap_journey/configuration/FirebaseAnalyticsService.dart';
import 'package:snap_journey/controller/Cameracontroller.dart';
import 'package:snap_journey/service/press_unpress.dart';
import 'package:uuid/uuid.dart';
import 'package:snap_journey/model/moment.dart';
import 'package:snap_journey/service/StorageService.dart';
import 'package:snap_journey/screen/common_screen/constant.dart';
import 'package:snap_journey/service/possessing_dialog.dart';
import 'package:video_player/video_player.dart';
import 'package:auto_size_text/auto_size_text.dart';

class PreviewScreen extends StatefulWidget {
  const PreviewScreen({super.key});

  @override
  State<PreviewScreen> createState() => _PreviewScreenState();
}

class _PreviewScreenState extends State<PreviewScreen>
    with SingleTickerProviderStateMixin {
  String? mediaPath;
  String type = '';
  double lat = 0.0, lng = 0.0;
  double aspectRatioArg = 1.0;
  bool isFrontCameraArg = false;
  bool saveWithLocation = false;

  VideoPlayerController? _videoController;
  bool _isPlaying = false;

  // NEW: Note fields
  final FocusNode titleFocusNode = FocusNode();
  final FocusNode noteFocusNode = FocusNode();
  final TextEditingController titleController = TextEditingController();
  final TextEditingController noteController = TextEditingController();
  final TextEditingController captionController = TextEditingController();

  final Cameracontroller controller = Get.find();
  final Uuid _uuid = const Uuid();

  late final AnimationController _fadeController;
  late final Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    FirebaseAnalyticsService.logEvent(
      eventName: "Snap_Journey_Preview_Screen",
    );
    final args = Get.arguments as Map<String, dynamic>? ?? {};
    mediaPath = args['path'] as String?;
    type = args['type'] as String? ?? '';
    lat = (args['lat'] as num?)?.toDouble() ?? 0.0;
    lng = (args['lng'] as num?)?.toDouble() ?? 0.0;
    aspectRatioArg = (args['aspectRatio'] as num?)?.toDouble() ?? 1.0;
    isFrontCameraArg = args['isFrontCamera'] ?? false;
    saveWithLocation = lat != 0 && lng != 0;

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    );

    if (type == 'video' && mediaPath != null) {
      _initializeVideo();
    }
  }

  void _initializeVideo() {
    if (mediaPath == null) return;
    ProgressDialog.show2("Loading video...".tr);

    final videoFile = File(mediaPath!);
    if (!videoFile.existsSync()) {
      ProgressDialog.dismiss2();
      Get.snackbar(
        'Error',
        'Video file not found',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    _videoController = VideoPlayerController.file(videoFile)
      ..initialize()
          .then((_) {
            ProgressDialog.dismiss2();
            if (mounted && _videoController!.value.isInitialized) {
              setState(() {
                aspectRatioArg = _videoController!.value.aspectRatio;
              });
              _videoController!.setLooping(false);
              _videoController!.play();
              _isPlaying = true;
              _fadeController.forward().then((_) => _fadeController.reverse());
              _videoController!.addListener(_videoListener);
            }
          })
          .catchError((error) {
            ProgressDialog.dismiss2();
            Get.snackbar(
              'Error',
              'Video playback failed',
              snackPosition: SnackPosition.BOTTOM,
            );
          });
  }

  void _saveMoment() async {
    if (mediaPath == null) return;

    ProgressDialog.show2("Saving moment...".tr);
    try {
      final mediaType = type == 'photo' ? 'photo' : 'video';
      final relativePath = await _copyToMomentsDir(mediaPath!, mediaType);
      if (relativePath == null) throw Exception('Copy failed');

      await File(mediaPath!).delete();

      final moment = Moment(
        date: DateTime.now(),
        lat: saveWithLocation ? lat : 0.0,
        lng: saveWithLocation ? lng : 0.0,
        note: noteController.text.trim(),
        title: titleController.text.trim(),
        caption: captionController.text.trim(),
        isNote: false,
        hasLocation: saveWithLocation,
      );

      if (type == 'photo') {
        moment.photoPaths = [relativePath];
      } else {
        moment.videoPaths = [relativePath];
      }

      await controller.saveMoment(moment);

      showToast(msg: "Moment saved!".tr);
      // Get.snackbar(
      //   'Success',
      //   'Moment saved!',
      //   snackPosition: SnackPosition.BOTTOM,
      // );
      // Get.back();
    } catch (e) {
      showToast(msg: "Save failed".tr);

      // Get.snackbar(
      //   'Error',
      //   'Save failed: $e',
      //   snackPosition: SnackPosition.BOTTOM,
      // );
    } finally {
      ProgressDialog.dismiss2();
    }
  }

  void _videoListener() {
    if (_videoController!.value.position >= _videoController!.value.duration &&
        !_videoController!.value.isPlaying) {
      if (mounted) {
        setState(() => _isPlaying = false);
        _fadeController.forward();
      }
    }
  }

  @override
  void dispose() {
    _videoController?.removeListener(_videoListener);
    _videoController?.dispose();
    titleController.dispose();
    noteController.dispose();
    captionController.dispose();
    titleFocusNode.dispose();
    noteFocusNode.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  Future<String?> _copyToMomentsDir(String tempPath, String mediaType) async {
    final uuid = _uuid.v4();
    final prefix = '${uuid}_$mediaType';
    final relativePath = await StorageService.copyToPersistentDir(
      tempPath,
      prefix,
    );
    if (relativePath != null) {
      print('$mediaType saved as: $relativePath');
      return relativePath;
    }
    return null;
  }

  void _togglePlayPause() {
    if (_videoController == null || !_videoController!.value.isInitialized)
      return;

    setState(() {
      if (_videoController!.value.isPlaying) {
        _videoController!.pause();
        _isPlaying = false;
        _fadeController.forward();
      } else {
        _videoController!.play();
        _isPlaying = true;
        _fadeController.forward().then((_) => _fadeController.reverse());
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        titleFocusNode.unfocus();
        noteFocusNode.unfocus();
      },
      child: Scaffold(
        backgroundColor: appbackgroundColor,
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          forceMaterialTransparency: true,
          automaticallyImplyLeading: false,
          backgroundColor: Colors.transparent,
          centerTitle: true,
          leading:
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: CircleAvatar(
              backgroundColor: Colors.black.withOpacity(0.4),
              child: Padding(
                padding: EdgeInsets.only(left: 10.w),
                child: Center(
                  child: IconButton(
                    onPressed: () {
                      Get.back();                    },
                    icon: Icon(Icons.arrow_back_ios, color: Colors.white),
                  ),
                ),
              ),
            ),
          ),
          // PressUnpress(
          //   onTap: () => Get.back(),
          //   height: 120.h,
          //   width: 120.w,
          //   imageAssetPress: 'assets/home_screen/back_arrow_click.png',
          //   imageAssetUnPress: 'assets/home_screen/back_arrow.png',
          // ).marginAll(30.w),
          title: AutoSizeText(
            'Add Details'.tr,
            style: TextStyle(
              color: Colors.black,
              fontSize: 70.sp,
              fontFamily: fontFamilySemiBold,
            ),
          ),
          actions: [
            
            CircleAvatar(
                
                backgroundColor: appColor.withOpacity(0.9),
                child: IconButton(onPressed: ()=>_saveMoment(), icon: Icon(Icons.save_alt_outlined,color: Colors.white,))).marginOnly(right: 40.w),
            // PressUnpress(
            //   onTap: () => _saveMoment(),
            //   height: 120.h,
            //   width: 120.w,
            //   imageAssetPress: 'assets/preview_screen/save_btn_click.png',
            //   imageAssetUnPress: 'assets/preview_screen/save_btn.png',
            // ).marginOnly(right: 40.w),
          ],
        ),
        body: Container(
          width: 1242.w,
          height: 2688.h,
          decoration: const BoxDecoration(
            color: Colors.white
            // image: DecorationImage(
            //   image: AssetImage('assets/setting_screen/bg.png'),
            //   fit: BoxFit.cover,
            // ),
          ),
          child: SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 60.w, vertical: 40.h),
              child: Column(
                children: [
                  Center(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Stack(
                        fit: StackFit.passthrough,
                        children: [
                          if (type == 'photo' && mediaPath != null)
                            SizedBox(
                        height: 1450.h,width: double.infinity,
                                child: Image.file(File(mediaPath!), fit: BoxFit.contain,height: 1450.h,width: double.infinity,))
                          else if (type == 'video' &&
                              _videoController?.value.isInitialized == true)
                            AspectRatio(
                              aspectRatio: aspectRatioArg,
                              child: GestureDetector(
                                onTap: _togglePlayPause,
                                child: Stack(
                                  fit: StackFit.expand,
                                  children: [
                                    VideoPlayer(_videoController!),
                                    if (!_isPlaying)
                                      Center(
                                        child: FadeTransition(
                                          opacity: _fadeAnimation,
                                          child:  Icon(
                                            Icons.play_circle_fill,
                                            color: Colors.black.withOpacity(0.7),
                                            size: 55,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            )
                          else
                            const Center(
                              child: CircularProgressIndicator(
                                color: appColor,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  40.verticalSpace,

                  // Location Toggle
                  Row(
                    children: [
                      Checkbox(
                        value: saveWithLocation,
                        onChanged: (val) {
                          if (mounted)
                            setState(() => saveWithLocation = val ?? false);
                        },
                        activeColor: appColor,

                        checkColor: Colors.white,
                      ),
                      AutoSizeText(
                        'Save with location'.tr,
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 45.sp,
                          fontFamily: fontFamilyMedium,
                        ),
                      ),
                    ],
                  ),
                  20.verticalSpace,

                  // Title Field
                  _buildTextField(
                    controller: titleController,
                    focusNode: titleFocusNode,
                    hint: "Add title...".tr,
                    label: "Title".tr,
                  ),
                  20.verticalSpace,

                  // Note Field
                  _buildTextField(
                    controller: noteController,
                    focusNode: noteFocusNode,
                    hint: "Add note...".tr,
                    label: "Note".tr,
                    maxLines: 3,
                  ),
                  20.verticalSpace,

                  // Caption Field
                  _buildTextField(
                    controller: captionController,
                    focusNode: FocusNode(),
                    hint: "Add caption...".tr,
                    label: "Caption".tr,
                  ),
                  100.verticalSpace,
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required FocusNode focusNode,
    required String hint,
    required String label,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AutoSizeText(
          label.tr,
          style: TextStyle(
            color: Colors.black,
            fontSize: 50.sp,
            fontFamily: fontFamilyBold,
          ),
        ),
        10.verticalSpace,
        TextField(
          controller: controller,
          focusNode: focusNode,
          maxLines: maxLines,
          style: TextStyle(
            color: Colors.black,
            fontSize: 45.sp,
            fontFamily: fontFamilyMedium,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              color: Colors.grey,
              fontSize: 45.sp,
              fontFamily: fontFamilyMedium,
            ),
            filled: true,
            // fillColor: const Color(0xff383A42),
            contentPadding: EdgeInsets.symmetric(
              horizontal: 20.w,
              vertical: 20.h,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: appColor, width: 2.w),
            ),
          ),
        ),
      ],
    );
  }
}
