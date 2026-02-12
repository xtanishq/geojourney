import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:snap_journey/screen/common_screen/constant.dart';
import 'package:auto_size_text/auto_size_text.dart';

class MyPermissionHandler {
  static Future<bool> checkPermission(
      BuildContext context,
      String permissionName,
      ) async {
    if (Platform.isAndroid) {
      final androidInfo = await DeviceInfoPlugin().androidInfo;
      final sdkInt = androidInfo.version.sdkInt;
      if (sdkInt < 33 &&
          (permissionName == 'gallery' || permissionName == 'audio')) {
        final statues = await [Permission.storage].request();
        final status = statues[Permission.storage];
        if (status == PermissionStatus.granted) return true;
        if (status == PermissionStatus.permanentlyDenied) {
          // Don't auto-show dialog
          return false;
        }
        return false;
      }
    }

    FocusScope.of(context).requestFocus(FocusNode());
    Permission permission;

    switch (permissionName) {
      case 'camera':
        permission = Permission.camera;
        break;
      case 'gallery':
        permission = Permission.photos;
        break;
      case 'audio':
        permission = Permission.audio;
        break;
      case 'microphone':
        permission = Permission.microphone;
        break;
      case 'video':
        permission = Permission.videos;
        break;
      case 'location':
        permission = Permission.location;
        break;
      default:
        return false;
    }

    final status = await permission.request();
    if (status == PermissionStatus.granted) return true;

    return false;
  }

  static void showPermissionDialog(BuildContext context, String item) {
    String message = _getPermissionMessage(item);

    if (Platform.isIOS) {
      showCupertinoDialog(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext context) {
          return CupertinoAlertDialog(
            title: AutoSizeText(
              'Permission Required',
              style: TextStyle(fontSize: 50.sp, fontFamily: fontFamilyBold),
            ),
            content: Padding(
              padding: EdgeInsets.only(top: 20.h),
              child: AutoSizeText(
                message,
                style: TextStyle(
                  fontSize: 42.sp,
                  fontFamily: fontFamilyRegular,
                ),
              ),
            ),
            actions: [
              CupertinoDialogAction(
                child: AutoSizeText(
                  'Not Now',
                  style: TextStyle(
                    color: CupertinoColors.black,
                    fontSize: 50.sp,
                    fontFamily: fontFamilySemiBold,
                  ),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              CupertinoDialogAction(
                isDefaultAction: true,
                child: AutoSizeText(
                  'Continue',
                  style: TextStyle(
                    color: appColor,
                    fontSize: 50.sp,
                    fontFamily: fontFamilySemiBold,
                  ),
                ),
                onPressed: () async {
                  Navigator.of(context).pop();
                  await openAppSettings();
                },
              ),
            ],
          );
        },
      );
    } else {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25),
            ),
            title: AutoSizeText(
              'Permission Required',
              style: TextStyle(fontSize: 50.sp, fontFamily: fontFamilyBold),
            ),
            content: AutoSizeText(
              message,
              style: TextStyle(fontSize: 42.sp, fontFamily: fontFamilyRegular),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: AutoSizeText(
                  'Not Now',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 50.sp,
                    fontFamily: fontFamilySemiBold,
                  ),
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  openAppSettings();
                },
                child: AutoSizeText(
                  'Continue',
                  style: TextStyle(
                    color: appColor,
                    fontSize: 50.sp,
                    fontFamily: fontFamilySemiBold,
                  ),
                ),
              ),
            ],
          );
        },
      );
    }
  }

  static String _getPermissionMessage(String permissionType) {
    switch (permissionType) {
      case 'camera':
        return 'Camera access is needed to capture photos and videos. For example, when you tap the capture button, we use your camera to take pictures of your special moments.';
      case 'microphone':
        return 'Microphone access is needed to record audio with your videos. For example, when you record a video, we capture sound to make your memories complete.';
      case 'location':
        return 'Location access helps tag your photos and videos with the place where they were captured. For example, when you take a photo at the beach, we can show "Miami Beach" on your memory. You can also view all your memories on the map.';
      case 'gallery':
      case 'photos':
        return 'Photo library access is needed to save and retrieve your captured memories. For example, we save your edited photos to your gallery and load them in the memories section.';
      default:
        return 'This permission is needed for the app to function properly.';
    }
  }
}
