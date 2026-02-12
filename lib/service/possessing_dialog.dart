import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svprogresshud/flutter_svprogresshud.dart';
import 'package:snap_journey/screen/common_screen/constant.dart';
import 'package:auto_size_text/auto_size_text.dart';

class ProgressDialog {
  static void show(BuildContext context, {String? imagePath, String? text}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.grey[900],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          contentPadding: const EdgeInsets.all(16),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (imagePath != null)
                Image.asset(
                  imagePath,
                  width: 100,
                  height: 100,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return const AutoSizeText(
                      'Failed to load image',
                      style: TextStyle(color: textColor),
                    );
                  },
                ),
              if (imagePath != null && text != null) const SizedBox(height: 16),
              if (text != null)
                AutoSizeText(
                  text,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 50.sp,
                    fontFamily: 'Medium',
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  static void dismiss(BuildContext context) {
    Navigator.of(context, rootNavigator: true).pop();
  }

  static void show2(String text) {
    SVProgressHUD.setDefaultStyle(SVProgressHUDStyle.dark);
    SVProgressHUD.setDefaultMaskType(SVProgressHUDMaskType.black);
    if (text.isEmpty) {
      SVProgressHUD.show();
    } else {
      SVProgressHUD.show(status: text);
    }
  }

  static void dismiss2() {
    SVProgressHUD.dismiss();
  }

  static void showAudioProcessingDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30.r),
          ),
          child: Padding(
            padding: EdgeInsets.all(80.r),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                40.verticalSpace,
                SizedBox(
                  width: 437.w,
                  height: 400.h,
                  child: Image.asset("assets/process_screen/gif.gif"),
                ),
                40.verticalSpace,
                AutoSizeText(
                  "Processing audio files,",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 50.sp,
                    color: Colors.black,
                    fontFamily: fontFamilySemiBold,
                  ),
                ),
                20.verticalSpace,
                AutoSizeText(
                  "Please wait while we work on it...",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 45.sp,
                    color: Colors.black87,
                    fontFamily: fontFamilyMedium,
                  ),
                ),
                60.verticalSpace,
              ],
            ),
          ),
        );
      },
    );
  }

  static void hideDialog(BuildContext context) {
    Navigator.of(context, rootNavigator: true).pop();
  }
}
