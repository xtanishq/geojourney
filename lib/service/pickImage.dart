import 'package:auto_size_text/auto_size_text.dart';
import 'package:snap_journey/google_ads_material/app_open_ad_manager.dart';
import 'package:snap_journey/screen/common_screen/constant.dart';
import 'package:snap_journey/service/permission.dart';
import 'package:snap_journey/service/press_unpress.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:image_cropper/image_cropper.dart';

import 'package:image_picker/image_picker.dart';


class PickImage {
  Future<String> checkPermissionAndPickImage(BuildContext context,
      String permissionType, ImageSource imageSource, bool isCrop) async {
    bool hasPermission =
    await MyPermissionHandler.checkPermission(context, permissionType);
    if (hasPermission) {
      return await pickImage(imageSource, isCrop);
    } else if (context.mounted) {
      MyPermissionHandler.showPermissionDialog(context, permissionType);
    }
    return '';
  }

  Future<String> pickImage(ImageSource imageSource, bool isCrop) async {
    AppOpenAdManager.shouldShowAd = false;
    final pickedFile = await ImagePicker().pickImage(source: imageSource,preferredCameraDevice: CameraDevice.front);
    AppOpenAdManager.shouldShowAd = true;
    if (pickedFile == null) return '';

    if (isCrop) {
      final croppedFile = await getCropImage(pickedFile.path);
      return croppedFile ?? '';
    }
    return pickedFile.path;
  }

  Future<String?> getCropImage(String imagePath) async {
    CroppedFile? croppedFile = await ImageCropper().cropImage(
      sourcePath: imagePath,
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Crop',
          toolbarColor: appColor,
          statusBarColor: Colors.black,
          toolbarWidgetColor: textColor,
          activeControlsWidgetColor: appColor,
          
          initAspectRatio: CropAspectRatioPreset.original,
          lockAspectRatio: false,
          hideBottomControls: false,
        ),
        IOSUiSettings(
          title: 'Cropper',
        ),
      ],
    );

    return croppedFile?.path;
  }

  Future<String> pickVideoFile(BuildContext context) async {
    bool hasPermission =
    await MyPermissionHandler.checkPermission(context, 'gallery');
    if (hasPermission) {
      AppOpenAdManager.shouldShowAd = false;
      showWaitDialog(context);
      final result = await ImagePicker().pickVideo(source: ImageSource.gallery);
      Get.back();
      AppOpenAdManager.shouldShowAd = true;
      if (result != null) {
        return result.path;
      } else {
        return '';
      }
    } else if (context.mounted) {
      MyPermissionHandler.showPermissionDialog(context, 'gallery');
    }
    return '';
  }

  Future<String> recordVideoFile(BuildContext context) async {
    bool hasPermission =
    await MyPermissionHandler.checkPermission(context, 'camera');
    if (hasPermission) {
      bool hasPermissionMicro =
      await MyPermissionHandler.checkPermission(context, 'microphone');
      if (hasPermissionMicro) {
        AppOpenAdManager.shouldShowAd = false;
        showWaitDialog(context);
        final result =
        await ImagePicker().pickVideo(source: ImageSource.camera,preferredCameraDevice: CameraDevice.front);
        Get.back();
        AppOpenAdManager.shouldShowAd = true;
        if (result != null) {
          return result.path;
        } else {
          return '';
        }
      } else if (context.mounted) {
        MyPermissionHandler.showPermissionDialog(context, 'microphone');
      }
    } else if (context.mounted) {
      MyPermissionHandler.showPermissionDialog(context, 'camera');
    }
    return '';
  }

  // Future<String> pickAudioFile(BuildContext context) async {
  //   bool hasPermission =
  //       await MyPermissionHandler.checkPermission(context, 'gallery');
  //   if (hasPermission) {
  //     // AppOpenAdManager.shouldShowAd = false;
  //     final result = await FilePicker.platform.pickFiles(
  //       type: FileType.custom,
  //       allowedExtensions: ['mp3'],
  //       allowMultiple: false,
  //       withData: true,
  //     );
  //     // AppOpenAdManager.shouldShowAd = true;
  //     if (result != null) {
  //       return result.files.first.path!;
  //     } else {
  //       return '';
  //     }
  //   } else if (context.mounted) {
  //     Get.back();
  //     MyPermissionHandler.showPermissionDialog(context, 'pdf file');
  //   }
  //   return '';
  // }

  void showWaitDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return PopScope(
          canPop: false,
          // onWillPop: () {
          //   return Future(() => false);
          // },
          child: Dialog.fullscreen(
            backgroundColor: Colors.transparent,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CupertinoActivityIndicator(
                  color: appColor,
                ),
                20.verticalSpace,
                AutoSizeText(
                  'Please Wait...',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 50.w,
                    fontFamily: fontFamilyMedium,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void showPickImageDialog(
      BuildContext context, Function(String selectedImage) onTap,
      {bool isCrop = true}) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog.fullscreen(
          backgroundColor: Colors.transparent,
          child: Center(
            child: Container(
              width: 1146.w,
              height: 829.w,
              decoration: BoxDecoration(
               color: textColor,
                borderRadius: BorderRadius.all(Radius.circular(30))
              ),

              alignment: Alignment.center,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  40.verticalSpace,
                  Row(
                    children: [
                      120.horizontalSpace,
                      Expanded(
                        child: AutoSizeText(
                          'Choose Image',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 60.sp,
                            fontFamily: fontFamilySemiBold,
                          ),
                        ),
                      ),
                      PressUnpress(
                        width: 86.w,
                        height: 86.w,
                        onTap: () {
                          Get.back();
                        },
                        imageAssetPress:
                        'assets/detect_select_screen/close_btn_click.png',
                        imageAssetUnPress:
                        'assets/detect_select_screen/close_btn.png',
                      ).marginOnly(top: 20.h, right: 40.w),
                    ],
                  ),
                  20.verticalSpace,
                  Padding(
                    padding:   EdgeInsets.symmetric(horizontal: 60.w),
                    child: Divider(color: Colors.grey,thickness: 2.h,radius: BorderRadius.circular(20),),
                  ),
                  40.verticalSpace,
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      PressUnpress(
                        width: 443.w,
                        height: 443.h,
                        onTap: () async {
                          Get.back();
                          String selectedImage = await PickImage()
                              .checkPermissionAndPickImage(context, 'gallery',
                              ImageSource.gallery, isCrop);
                          if (selectedImage.isNotEmpty) {
                            onTap(selectedImage);
                          }
                        },
                        imageAssetPress:
                        'assets/detect_select_screen/gallery_btn_click.png',
                        imageAssetUnPress:
                        'assets/detect_select_screen/gallery_btn.png',
                      ),
                      PressUnpress(
                        width: 443.w,
                        height: 443.h,
                        onTap: () async {
                          Get.back();
                          String selectedImage = await PickImage()
                              .checkPermissionAndPickImage(context, 'camera',
                              ImageSource.camera, isCrop);
                          if (selectedImage.isNotEmpty) {
                            onTap(selectedImage);
                          }
                        },
                        imageAssetPress:
                        'assets/detect_select_screen/camera_btn_click.png',
                        imageAssetUnPress:
                        'assets/detect_select_screen/camera_btn.png',
                      ),
                    ],
                  ),
                  40.verticalSpace,
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
