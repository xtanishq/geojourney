import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:snap_journey/screen/common_screen/constant.dart';
import 'package:auto_size_text/auto_size_text.dart';

class DialogService {
  static backButtonDialog(BuildContext context) {
    showCupertinoDialog(
      context: context,
      builder: (context) {
        return CupertinoAlertDialog(
          title: AutoSizeText(
            'Are you sure you want to exit?',
            style: TextStyle(color: CupertinoColors.black, fontSize: 45.sp),
          ),
          content: const AutoSizeText(
            "Exiting will stop the current process.\nDo you really want to exit?",
            textAlign: TextAlign.center,
          ),
          actions: [
            CupertinoDialogAction(
              child: AutoSizeText('Exit', style: TextStyle(color: textColor)),
              onPressed: () {
                print("preses");
                // Navigator.pushAndRemoveUntil(
                //   context,
                //   MaterialPageRoute(builder: (BuildContext context) {
                //     return  Home();
                //   }),
                //       (route) => false,
                // );
              },
            ),
            CupertinoDialogAction(
              child: const AutoSizeText(
                'No',
                style: TextStyle(color: CupertinoColors.black),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  static void restorePurchasesDialog(BuildContext context) {
    if (Platform.isIOS) {
      showCupertinoDialog(
        context: context,
        builder: (context) {
          return CupertinoAlertDialog(
            title: const AutoSizeText('No Purchases Found'),
            content: const AutoSizeText(
              "You've no active subscriptions. Kindly purchase any of the given subscriptions.",
            ),
            actions: [
              CupertinoDialogAction(
                child: const AutoSizeText('Ok'),
                onPressed: () {
                  Navigator.of(context).pop();
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
            title: const Center(child: CupertinoActivityIndicator()),
          );
        },
      );
    }
  }

  static void showLoading(BuildContext context) {
    if (Platform.isIOS) {
      showCupertinoDialog(
        useRootNavigator: false,
        context: context,
        builder: (context) {
          return Theme(
            data: ThemeData(
              dialogBackgroundColor: Colors.transparent,
              dialogTheme: const DialogThemeData(
                backgroundColor: Colors.transparent,
              ),
            ),
            child: const CupertinoAlertDialog(
              title: CupertinoActivityIndicator(color: Colors.black),
            ),
          );
        },
      );
    } else {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: textColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: CupertinoActivityIndicator(color: Colors.black),
          );
        },
      );
    }
  }

  static void showCheckConnectivity(BuildContext context) {
    if (Platform.isIOS) {
      showCupertinoDialog(
        context: context,
        builder: (BuildContext context) {
          return CupertinoAlertDialog(
            title: const AutoSizeText('Connection'),
            content: const AutoSizeText('Check your internet connection.'),
            actions: [
              CupertinoDialogAction(
                child: const AutoSizeText('Ok'),
                onPressed: () {
                  Navigator.of(context).pop();
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
            title: const AutoSizeText('Connection'),
            content: const AutoSizeText('Check your internet connection.'),
            actions: [
              TextButton(
                child: const AutoSizeText('Ok'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }
  }

  static void showpermissiondialog(BuildContext context, String item) {
    if (Platform.isIOS) {
      showCupertinoDialog(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext context) {
          return CupertinoAlertDialog(
            content: AutoSizeText('Allow access to $item in the Setting.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  openAppSettings();
                },
                child: const AutoSizeText('Setting'),
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
            content: AutoSizeText('Allow access to $item in the Setting.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  openAppSettings();
                },
                child: const AutoSizeText('Setting'),
              ),
            ],
          );
        },
      );
    }
  }
}
