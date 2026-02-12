import 'package:snap_journey/controller/splash_controller.dart';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:snap_journey/screen/common_screen/constant.dart';
import 'package:get/get.dart';
import 'package:auto_size_text/auto_size_text.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  final SplashController splashController = Get.find<SplashController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: Container(
        width: 1242.w,
        height: 2688.h,
        decoration: const BoxDecoration(
          color: Color(0xffF8FAFC)
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(),
            Image.asset(
              "assets/splash_screen/img.png",
              width: 670.w,
              height: 670.h,
            ),
            40.verticalSpace,
            AutoSizeText(
              appName.tr,
              style: TextStyle(
                color: Colors.grey,
                fontSize: 50.sp,
                fontFamily: fontFamilyBold,
              ),
            ),
            const Spacer(),
            Image.asset(
              'assets/splash_screen/gif.gif',
              width: 200.w,
              height: 200.h,
            ),
            20.verticalSpace,
            AutoSizeText(
              'This action can contain ads...'.tr,
              style: TextStyle(
                color: Colors.grey,
                fontSize: 55.sp,
                fontFamily: fontFamilyRegular,
              ),
            ),
            100.verticalSpace,
          ],
        ),
      ),
    );
  }
}
