import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:geocoding/geocoding.dart';
import 'package:snap_journey/configuration/FirebaseAnalyticsService.dart';
import 'package:snap_journey/controller/Cameracontroller.dart';
import 'package:snap_journey/controller/MomentsController.dart';
import 'package:snap_journey/model/moment.dart';
import 'package:snap_journey/screen/common_screen/constant.dart';
import 'package:snap_journey/service/possessing_dialog.dart';
import 'package:snap_journey/service/press_unpress.dart';
import 'package:snap_journey/service/StorageService.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'package:auto_size_text/auto_size_text.dart';

class EditMomentScreen extends StatefulWidget {
  final Moment moment;

  const EditMomentScreen({super.key, required this.moment});

  @override
  State<EditMomentScreen> createState() => _EditMomentScreenState();
}

class _EditMomentScreenState extends State<EditMomentScreen> {
  late TextEditingController titleController;
  late TextEditingController noteController;
  late TextEditingController captionController;

  late bool hasLocation;
  late double lat, lng;

  bool _hasFetchedLocation = false;
  String? _locationAddress; // Human-readable address

  final FocusNode titleFocusNode = FocusNode();
  final FocusNode noteFocusNode = FocusNode();
  final FocusNode captionFocusNode = FocusNode();

  final MomentsController momentsController = Get.find();
  final Cameracontroller cameraController = Get.find();

  // Video thumbnail
  Uint8List? _videoThumbnailBytes;

  @override
  void initState() {
    super.initState();
    FirebaseAnalyticsService.logEvent(
      eventName: "Snap_Journey_Edit_Moment_Screen",
    );
    titleController = TextEditingController(text: widget.moment.title ?? '');
    noteController = TextEditingController(text: widget.moment.note);
    captionController = TextEditingController(
      text: widget.moment.caption ?? '',
    );

    hasLocation = widget.moment.hasLocation;
    lat = widget.moment.lat;
    lng = widget.moment.lng;

    if (hasLocation && lat != 0.0 && lng != 0.0) {
      _fetchAddressFromLatLng(); // Load saved address
    }

    _generateVideoThumbnail();
  }

  // Generate thumbnail for first video
  Future<void> _generateVideoThumbnail() async {
    if (widget.moment.videoPaths.isEmpty) return;

    try {
      final videoPath = widget.moment.videoPaths.first;
      final fullPath = await StorageService.getFullPath(videoPath);
      final file = File(fullPath);

      if (await file.exists()) {
        final uint8list = await VideoThumbnail.thumbnailData(
          video: fullPath,
          imageFormat: ImageFormat.JPEG,
          maxWidth: 600,
          quality: 80,
        );

        if (mounted && uint8list != null) {
          setState(() => _videoThumbnailBytes = uint8list);
        }
      }
    } catch (e) {
      debugPrint('Thumbnail error: $e');
    }
  }

  // Fetch address from lat/lng
  Future<void> _fetchAddressFromLatLng() async {
    if (lat == 0.0 || lng == 0.0) return;

    try {
      final placemarks = await placemarkFromCoordinates(lat, lng);
      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        final parts = <String>[];
        if (place.subLocality?.isNotEmpty == true) {
          parts.add(place.subLocality!);
        }
        if (place.locality?.isNotEmpty == true) parts.add(place.locality!);
        if (place.administrativeArea?.isNotEmpty == true &&
            place.administrativeArea != place.locality) {
          parts.add(place.administrativeArea!);
        }
        if (place.country?.isNotEmpty == true) parts.add(place.country!);

        setState(() {
          _locationAddress = parts.isNotEmpty
              ? parts.join(', ')
              : 'Unknown location';
        });
      }
    } catch (e) {
      debugPrint('Geocoding error: $e');
      setState(() => _locationAddress = 'Location not available');
    }
  }

  Future<void> _saveChanges() async {
    ProgressDialog.show2("Saving changes...".tr);
    try {
      widget.moment.title = titleController.text.trim();
      widget.moment.note = noteController.text.trim();
      widget.moment.caption = captionController.text.trim();
      widget.moment.hasLocation = hasLocation;
      widget.moment.lat = hasLocation ? lat : 0.0;
      widget.moment.lng = hasLocation ? lng : 0.0;

      await widget.moment.save();
      await momentsController.loadMoments();

      Get.back();
      Get.snackbar(
        'Success',
        'Moment updated successfully!',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.withOpacity(0.8),
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to update: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.8),
        colorText: Colors.white,
      );
    } finally {
      ProgressDialog.dismiss2();
    }
  }

  Future<void> _fetchLocationOnce() async {
    if (_hasFetchedLocation) return;

    ProgressDialog.show2("Fetching location...".tr);
    try {
      await cameraController.getCurrentLocation();
      final pos = cameraController.currentPosition.value;
      if (pos != null) {
        setState(() {
          lat = pos.latitude;
          lng = pos.longitude;
          hasLocation = true;
          _hasFetchedLocation = true;
        });

        // Fetch address
        await _fetchAddressFromLatLng();

        Get.snackbar(
          'Success',
          'Location captured!',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green.withOpacity(0.7),
          colorText: Colors.white,
        );
      } else {
        Get.snackbar(
          'Error',
          'Enable GPS to get location.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.orange.withOpacity(0.7),
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Location error: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.7),
        colorText: Colors.white,
      );
    } finally {
      ProgressDialog.dismiss2();
    }
  }

  @override
  void dispose() {
    titleController.dispose();
    noteController.dispose();
    captionController.dispose();
    titleFocusNode.dispose();
    noteFocusNode.dispose();
    captionFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        titleFocusNode.unfocus();
        noteFocusNode.unfocus();
        captionFocusNode.unfocus();
      },
      child: Scaffold(
        backgroundColor: appbackgroundColor,
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          forceMaterialTransparency: true,
          automaticallyImplyLeading: false,
          backgroundColor: Colors.transparent,
          centerTitle: true,
          leading: PressUnpress(
            onTap: () => Get.back(),
            height: 120.h,
            width: 120.w,
            imageAssetPress: 'assets/home_screen/back_arrow_click.png',
            imageAssetUnPress: 'assets/home_screen/back_arrow.png',
          ).marginAll(30.w),
          title: AutoSizeText(
            'Edit Moment'.tr,
            style: TextStyle(
              color: Colors.white,
              fontSize: 70.sp,
              fontFamily: fontFamilySemiBold,
            ),
          ),
          actions: [

            CircleAvatar(

                backgroundColor: appColor.withOpacity(0.9),
                child: IconButton(onPressed:  _saveChanges, icon: Icon(Icons.save_alt_outlined,color: Colors.white,))).marginOnly(right: 40.w),

            // PressUnpress(
            //   onTap: _saveChanges,
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
            // image: DecorationImage(
            //   image: AssetImage('assets/setting_screen/bg.png'),
            //   fit: BoxFit.cover,
            // ),
          ),
          child: SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(60.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (widget.moment.hasMedia) _buildMediaPreview(),
                  if (widget.moment.hasMedia) 40.verticalSpace,

                  _buildTextField(
                    controller: titleController,
                    focusNode: titleFocusNode,
                    label: "Title".tr,
                    hint: "Enter title...".tr,
                  ),
                  20.verticalSpace,
                  _buildTextField(
                    controller: noteController,
                    focusNode: noteFocusNode,
                    label: "Note".tr,
                    hint: "Enter note...".tr,
                    maxLines: 4,
                  ),
                  20.verticalSpace,
                  _buildTextField(
                    controller: captionController,
                    focusNode: captionFocusNode,
                    label: "Caption".tr,
                    hint: "Enter caption...".tr,
                  ),
                  40.verticalSpace,

                  AutoSizeText(
                    "Location".tr,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 50.sp,
                      fontFamily: fontFamilyBold,
                    ),
                  ),
                  20.verticalSpace,
                  Container(
                    padding: EdgeInsets.all(30.w),
                    decoration: BoxDecoration(
                      color: const Color(0xff1F232F),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xff535353)),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Checkbox(
                              value: hasLocation,
                              onChanged: (val) {
                                setState(() {
                                  hasLocation = val ?? false;
                                  if (!hasLocation) {
                                    lat = 0.0;
                                    lng = 0.0;
                                    _locationAddress = null;
                                  }
                                });
                                if (hasLocation && !_hasFetchedLocation) {
                                  _fetchLocationOnce();
                                }
                              },
                              activeColor: appColor,
                              checkColor: Colors.white,
                            ),
                            AutoSizeText(
                              'Include location'.tr,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 45.sp,
                                fontFamily: fontFamilyMedium,
                              ),
                            ),
                            const Spacer(),
                            IconButton(onPressed: (){
                              _fetchLocationOnce();
                            } ,icon: Icon(Icons.refresh, color: Colors.blueAccent,)),
                            // PressUnpress(
                            //   onTap: _fetchLocationOnce,
                            //   height: 100.h,
                            //   width: 100.w,
                            //   imageAssetUnPress:
                            //       "assets/memories_screen/refresh_btn.png",
                            //   imageAssetPress:
                            //       "assets/memories_screen/refresh_btn_click.png",
                            // ),
                          ],
                        ),
                        if (hasLocation) ...[
                          20.verticalSpace,
                          Row(
                            children: [

                              Icon(Icons.pin_drop,color: Colors.redAccent,),
                              // Image.asset(
                              //   "assets/timeline_screen/location_ic.png",
                              //   width: 100.w,
                              //   height: 100.h,
                              // ),
                              15.horizontalSpace,
                              Expanded(
                                child: AutoSizeText(
                                  _locationAddress ?? 'Fetching location...',
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 40.sp,
                                    fontFamily: fontFamilyMedium,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
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

  Widget _buildMediaPreview() {
    if (widget.moment.videoPaths.isNotEmpty && _videoThumbnailBytes != null) {
      return _buildVideoThumbnail();
    }
    if (widget.moment.photoPaths.isNotEmpty) {
      return _buildImagePreview();
    }
    return const SizedBox.shrink();
  }

  Widget _buildVideoThumbnail() {
    return Container(
      height: 500.h,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(20),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.memory(_videoThumbnailBytes!, fit: BoxFit.cover),
            Center(
              child: Container(
                padding: EdgeInsets.all(20.w),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.6),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.play_arrow, color: Colors.white, size: 80.sp),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePreview() {
    final previewPath = widget.moment.photoPaths.first;
    return FutureBuilder<String>(
      future: StorageService.getFullPath(previewPath),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Container(
            height: 500.h,
            decoration: BoxDecoration(
              color: Colors.grey[900],
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Center(
              child: CircularProgressIndicator(color: appColor),
            ),
          );
        }

        final file = File(snapshot.data!);
        if (!file.existsSync()) {
          return Container(
            height: 500.h,
            decoration: BoxDecoration(
              color: Colors.grey[900],
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Center(
              child: Icon(Icons.broken_image, color: Colors.white54, size: 80),
            ),
          );
        }

        return ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Image.file(
            file,
            height: 500.h,
            width: double.infinity,
            fit: BoxFit.cover,
          ),
        );
      },
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required FocusNode focusNode,
    required String label,
    required String hint,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AutoSizeText(
          label,
          style: TextStyle(
            color: Colors.white,
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
            color: Colors.white,
            fontSize: 45.sp,
            fontFamily: fontFamilyMedium,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.white54, fontSize: 45.sp),
            filled: true,
            fillColor: const Color(0xff383A42),
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
