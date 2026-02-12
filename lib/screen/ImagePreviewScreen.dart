import 'dart:io';
import 'dart:ui';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:geocoding/geocoding.dart';
import 'package:share_plus/share_plus.dart';
import 'package:snap_journey/configuration/FirebaseAnalyticsService.dart';
import 'package:snap_journey/controller/MomentsController.dart';
import 'package:snap_journey/google_ads_material/ads_variable.dart';
import 'package:snap_journey/google_ads_material/banner_widget.dart';
import 'package:snap_journey/model/moment.dart';
import 'package:snap_journey/screen/EditMomentScreen.dart';
import 'package:snap_journey/screen/common_screen/constant.dart';
import 'package:snap_journey/service/StorageService.dart';
import 'package:snap_journey/service/possessing_dialog.dart';
import 'package:snap_journey/service/press_unpress.dart';
import 'package:auto_size_text/auto_size_text.dart';

import '../controller/Cameracontroller.dart';

class ImagePreviewScreen extends StatefulWidget {
  final Moment moment;
  final int imageIndex;

  const ImagePreviewScreen({
    super.key,
    required this.moment,
    this.imageIndex = 0,
  });

  @override
  State<ImagePreviewScreen> createState() => _ImagePreviewScreenState();
}

class _ImagePreviewScreenState extends State<ImagePreviewScreen> {
  final _placeName = RxnString();
  final _isLoadingPlace = false.obs;

  @override
  void initState() {
    super.initState();
    FirebaseAnalyticsService.logEvent(
      eventName: "Snap_Journey_Image_Preview_Screen",
    );
    if (widget.moment.hasLocation) {
      _fetchPlaceName();
    }
  }

  Future<void> _fetchPlaceName() async {
    if (!widget.moment.hasLocation) return;

    _isLoadingPlace.value = true;
    _placeName.value = null;

    try {
      final placemarks = await placemarkFromCoordinates(
        widget.moment.lat,
        widget.moment.lng,
      );

      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        final parts = <String>[];

        final subLocality = place.subLocality ?? '';
        final locality = place.locality ?? '';
        final adminArea = place.administrativeArea ?? '';
        final country = place.country ?? '';

        if (subLocality.isNotEmpty && subLocality != locality)
          parts.add(subLocality);
        if (locality.isNotEmpty) parts.add(locality);
        if (adminArea.isNotEmpty && adminArea != locality) parts.add(adminArea);
        if (country.isNotEmpty) parts.add(country);

        _placeName.value = parts.isNotEmpty ? parts.join(', ') : null;
      } else {
        _placeName.value = null;
      }
    } catch (e) {
      debugPrint('Geocoding error: $e');
      _placeName.value = null;
    } finally {
      _isLoadingPlace.value = false;
    }
  }

  bool get _shouldShowInfoContainer {
    final hasTitle = widget.moment.title?.trim().isNotEmpty ?? false;
    final hasNote = widget.moment.note?.trim().isNotEmpty ?? false;
    final hasCaption = widget.moment.caption?.trim().isNotEmpty ?? false;
    final hasValidLocation = _placeName.value != null;
    return hasTitle || hasNote || hasCaption || hasValidLocation;
  }

  Future<void> _shareImage(String relativePath) async {
    ProgressDialog.show2("Please wait...".tr);
    final fullPath = await StorageService.getFullPath(relativePath);
    final file = File(fullPath);

    if (!await file.exists()) {
      ProgressDialog.dismiss2();
      Get.snackbar(
        'Error',
        'Image not found',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    ProgressDialog.dismiss2();

    // FIX: Check if caption is null OR empty
    String? shareText = widget.moment.caption;
    if (shareText == null || shareText.trim().isEmpty) {
      shareText = "Check out this image!"; // Or any non-empty fallback
    }

    await Share.shareXFiles([XFile(fullPath)], text: shareText);
  }

  // Future<void> _shareImage(String relativePath) async {
  //   ProgressDialog.show2("Please wait...".tr);
  //   final fullPath = await StorageService.getFullPath(relativePath);
  //   final file = File(fullPath);
  //
  //   if (!await file.exists()) {
  //     ProgressDialog.dismiss2();
  //     Get.snackbar(
  //       'Error',
  //       'Image not found',
  //       snackPosition: SnackPosition.BOTTOM,
  //     );
  //     return;
  //   }
  //
  //   ProgressDialog.dismiss2();
  //   await Share.shareXFiles([XFile(fullPath)], text: widget.moment.caption??"imgg");
  // }

  Future<void> _confirmDelete() async {
    final confirm =
        await showDialog<bool>(
          context: context,
          builder: (context) => _buildDeleteDialog(),
        ) ??
        false;

    if (confirm) await _deleteMoment();
  }

  Widget _buildDeleteDialog() {
    return AlertDialog(
      backgroundColor: const Color(0xff1F232F),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: AutoSizeText(
        'Delete Item'.tr,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 60.sp,
          fontFamily: fontFamilyBold,
          color: Colors.white,
        ),
      ),
      content: AutoSizeText(
        'Are you sure you want to delete this item?'.tr,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 45.sp,
          fontFamily: fontFamilyMedium,
          color: Colors.white,
        ),
      ),
      actionsAlignment: MainAxisAlignment.spaceEvenly,
      actions: [
        TextButton(

          onPressed: () => Navigator.pop(context, false),

          style: TextButton.styleFrom(

            backgroundColor: Colors.black.withOpacity(0.2),
            // Set your background color here
            foregroundColor: Colors.white,
            // This sets the text/icon color
            padding: EdgeInsets.symmetric(horizontal: 60.w, vertical: 10.h),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(
                40.r,

              ), // Optional: rounded corners
            ),
          ),

          child: AutoSizeText(
            'Cancel'.tr,
            style: TextStyle(color: Colors.white, fontSize: 50.sp),
          ),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, true),
          style: TextButton.styleFrom(

            backgroundColor: Colors.white.withOpacity(0.2),
            // Set your background color here
            foregroundColor: Colors.white,
            // This sets the text/icon color
            padding: EdgeInsets.symmetric(horizontal: 60.w, vertical: 10.h),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(
                40.r,

              ), // Optional: rounded corners
            ),
          ),
          child: AutoSizeText(
            'Delete',
            style: TextStyle(color: Colors.red, fontSize: 50.sp),
          ),
        ),
        // PressUnpress(
        //   onTap: () => Navigator.pop(context, false),
        //   width: 400.w,
        //   height: 140.h,
        //   pressLinearGradient: pressLinearGradiant,
        //   unPressLinearGradient: unPressLinearGradiant,
        //   child: Center(
        //     child: AutoSizeText(
        //       "Cancel",
        //       style: TextStyle(
        //         color: textColor,
        //         fontSize: 50.sp,
        //         fontFamily: fontFamilyMedium,
        //       ),
        //     ),
        //   ),
        // ),
        // PressUnpress(
        //   onTap: () => Navigator.pop(context, true),
        //   width: 400.w,
        //   height: 140.h,
        //   pressLinearGradient: pressLinearGradiant,
        //   unPressLinearGradient: unPressLinearGradiant,
        //   child: Center(
        //     child: AutoSizeText(
        //       'Delete',
        //       style: TextStyle(
        //         color: textColor,
        //         fontSize: 50.sp,
        //         fontFamily: fontFamilyMedium,
        //       ),
        //     ),
        //   ),
        // ),
      ],
    );
  }

  Future<void> _deleteMoment() async {
    try {
      await widget.moment.delete();

      final momentsController = Get.find<MomentsController>();
      await momentsController.loadMoments();

      Get.back();
      Get.snackbar(
        'Deleted',
        'This moment has been deleted successfully',
        backgroundColor: Colors.black87,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to delete: $e',
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final imagePath = widget.moment.photoPaths.isNotEmpty
        ? widget.moment.photoPaths[widget.imageIndex.clamp(
            0,
            widget.moment.photoPaths.length - 1,
          )]
        : '';

    return Scaffold(
      backgroundColor: appbackgroundColor,
      extendBodyBehindAppBar: true,
      appBar: buildAppBar(imagePath),
      body: _buildBody(imagePath),
    );
  }

  PreferredSizeWidget buildAppBar(String imagePath) {
    return AppBar(
      forceMaterialTransparency: true,
      backgroundColor: Colors.transparent,
      centerTitle: true,
      leading: Padding(
        padding: const EdgeInsets.all(8.0),
        child: CircleAvatar(
          backgroundColor: Colors.black.withOpacity(0.4),
          child: Padding(
            padding: EdgeInsets.only(left: 10.w),
            child: Center(
              child: IconButton(
                onPressed: () {
                  Get.back();
                },
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
        'Preview',
        style: TextStyle(
          color: Colors.black,
          fontSize: 70.sp,
          fontFamily: fontFamilySemiBold,
        ),
      ),
      actions: [
        DropdownButtonHideUnderline(
          child: DropdownButton2<String>(
            customButton: Container(
              width: 120.w,
              height: 120.h,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.1),
              ),
              child: Icon(Icons.more_vert, color: Colors.black, size: 30),
            ),
            items: [
              DropdownMenuItem<String>(
                value: 'edit',
                child: Row(
                  children: [
                    Image.asset(
                      'assets/home_screen/edit_btn.png',
                      width: 80.w,
                      height: 80.h,
                    ),
                    SizedBox(width: 20.w),
                    AutoSizeText(
                      'Edit',
                      style: TextStyle(
                        fontSize: 45.sp,
                        fontFamily: fontFamilyMedium,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              DropdownMenuItem<String>(
                value: 'share',
                child: Row(
                  children: [
                    Center(
                      child: Icon(Icons.share, color: Colors.white, size: 20),
                    ),

                    // Image.asset(
                    //   'assets/preview_screen/share_btn.png',
                    //   width: 80.w,
                    //   height: 80.h,
                    // ),
                    SizedBox(width: 20.w),
                    SizedBox(
                      width: 230.w,
                      child: AutoSizeText(
                        'Share'.tr,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 45.sp,
                          fontFamily: fontFamilyMedium,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              DropdownMenuItem<String>(
                value: 'delete',
                child: Row(
                  children: [
                    // Image.asset(
                    //   'assets/preview_screen/delete_btn.png',
                    //   width: 80.w,
                    //   height: 80.h,
                    // ),
                    Center(
                      child: Icon(Icons.delete, color: Colors.white, size: 20),
                    ),
                    SizedBox(width: 20.w),
                    AutoSizeText(
                      'Delete'.tr,
                      style: TextStyle(
                        fontSize: 45.sp,
                        fontFamily: fontFamilyMedium,
                        color: Colors.red,
                      ),
                    ),
                  ],
                ),
              ),
            ],
            onChanged: (String? value) async {
              switch (value) {
                case 'edit':
                  Get.lazyPut<Cameracontroller>(
                    () => Cameracontroller(),
                    fenix: true,
                  );

                  await Get.to(() => EditMomentScreen(moment: widget.moment));
                  if (mounted) {
                    setState(() {
                      if (widget.moment.hasLocation) {
                        _fetchPlaceName();
                      }
                    });
                  }
                  break;
                case 'share':
                  _shareImage(imagePath);
                  break;
                case 'delete':
                  _confirmDelete();
                  break;
              }
            },
            dropdownStyleData: DropdownStyleData(
              width: 400.w,
              padding: EdgeInsets.symmetric(vertical: 20.h),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: const Color(0xff1F232F),
                border: Border.all(color: const Color(0xff535353)),
              ),
              offset: Offset(-20.w, 0),
            ),
            menuItemStyleData: MenuItemStyleData(
              height: 120.h,
              padding: EdgeInsets.symmetric(horizontal: 30.w),
            ),
          ),
        ).marginOnly(right: 40.w),
      ],
    );
  }

  Widget _buildBody(String imagePath) {
    return Container(
      width: 1242.w,
      height: 2688.h,
      decoration: const BoxDecoration(
        color: Colors.white,
        // image: DecorationImage(
        //   image: AssetImage('assets/setting_screen/bg.png'),
        //   fit: BoxFit.cover,
        // ),
      ),
      child: SafeArea(
        child: imagePath.isEmpty
            ? Center(
                child: AutoSizeText(
                  'No image available'.tr,
                  style: TextStyle(color: Colors.black),
                ),
              )
            : Column(
                children: [
                  Expanded(child: _buildImage(imagePath)),

                  Obx(() {
                    // Performance: Return early if nothing to show
                    if (!_shouldShowInfoContainer)
                      return const SizedBox.shrink();

                    return Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 25.w,
                        vertical: 20.h,
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(24.r),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                          // Modern Glass effect
                          child: Container(
                            width: double.infinity,
                            padding: EdgeInsets.all(24.w),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.85),
                              // Clean white frost
                              borderRadius: BorderRadius.circular(24.r),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.5),
                                width: 1.5,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 20,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // Title with modern bold styling
                                if (widget.moment.title?.trim().isNotEmpty ??
                                    false)
                                  AutoSizeText(
                                    widget.moment.title!.toUpperCase(),
                                    style: TextStyle(
                                      color: Colors.black87,
                                      fontSize: 48.sp,
                                      letterSpacing: 0.5,
                                      fontFamily: fontFamilyBold,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),

                                // Note with slightly softer color
                                if (widget.moment.note?.trim().isNotEmpty ??
                                    false) ...[
                                  SizedBox(height: 8.h),
                                  AutoSizeText(
                                    widget.moment.note!,
                                    style: TextStyle(
                                      color: Colors.black54,
                                      fontSize: 40.sp,
                                      height: 1.3,
                                      fontFamily: fontFamilyMedium,
                                    ),
                                    maxLines: 3,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],

                                // Caption - Styled as a highlight tag
                                if (widget.moment.caption?.trim().isNotEmpty ??
                                    false) ...[
                                  SizedBox(height: 12.h),
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 12.w,
                                      vertical: 4.h,
                                    ),
                                    decoration: BoxDecoration(
                                      color: appColor.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8.r),
                                    ),
                                    child: AutoSizeText(
                                      "# ${widget.moment.caption!}",
                                      style: TextStyle(
                                        color: appColor,
                                        fontSize: 36.sp,
                                        fontFamily: fontFamilyMedium,
                                        fontStyle: FontStyle.italic,
                                      ),
                                    ),
                                  ),
                                ],

                                // Modern Location Pill
                                if (_placeName.value != null ||
                                    _isLoadingPlace.value) ...[
                                  Padding(
                                    padding: EdgeInsets.only(top: 16.h),
                                    child: Divider(
                                      color: Colors.black12,
                                      thickness: 1,
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.only(top: 8.h),
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.location_on_rounded,
                                          color: appColor,
                                          size: 45.sp,
                                        ),
                                        SizedBox(width: 12.w),
                                        _isLoadingPlace.value
                                            ? SizedBox(
                                                width: 15.w,
                                                height: 15.w,
                                                child: CircularProgressIndicator(
                                                  strokeWidth: 2,
                                                  valueColor:
                                                      AlwaysStoppedAnimation<
                                                        Color
                                                      >(appColor),
                                                ),
                                              )
                                            : Expanded(
                                                child: AutoSizeText(
                                                  _placeName.value!,
                                                  style: TextStyle(
                                                    color: Colors.black87,
                                                    fontSize: 36.sp,
                                                    fontFamily:
                                                        fontFamilyMedium,
                                                  ),
                                                ),
                                              ),
                                      ],
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  }),

                  // Obx(
                  //   () => AdsVariable.isPurchase.isFalse
                  //       ? BannerTemplate(
                  //           bannerId: AdsVariable.banner_img_preview_screen,
                  //         ).marginOnly(top: 20.h)
                  //       : const SizedBox.shrink(),
                  // ),
                ],
              ),
      ),
    );
  }

  Widget _buildImage(String imagePath) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Center(
        child: ClipRRect(
          borderRadius: const BorderRadius.all(Radius.circular(20)),
          child: Hero(
            tag: 'image_${widget.moment.key}_x',
            child: FutureBuilder<String>(
              future: StorageService.getFullPath(imagePath),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(
                    child: CircularProgressIndicator(color: Colors.black),
                  );
                }

                final file = File(snapshot.data!);
                if (!file.existsSync()) {
                  return const Center(
                    child: Icon(
                      Icons.broken_image,
                      color: Colors.black,
                      size: 80,
                    ),
                  );
                }

                return Image.file(
                  file,
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => const Center(
                    child: Icon(
                      Icons.image_not_supported,
                      color: Colors.black,
                      size: 64,
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
