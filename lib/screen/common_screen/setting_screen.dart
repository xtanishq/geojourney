import 'package:snap_journey/controller/MomentsController.dart';
import 'package:snap_journey/google_ads_material/requesting_consent.dart';
import 'package:snap_journey/screen/TimelineScreen.dart';
import 'package:snap_journey/screen/common_screen/language_screen.dart';
import 'package:snap_journey/screen/common_screen/privacy_policy.dart';
import 'package:snap_journey/service/checkConnectivity.dart';
import 'package:snap_journey/service/dialog.dart';
import 'package:snap_journey/service/press_unpress.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/widgets.dart';
import 'package:snap_journey/configuration/FirebaseAnalyticsService.dart';
import 'package:snap_journey/google_ads_material/ads_variable.dart';
import 'package:snap_journey/in_app_purchase/app.dart';
import 'package:snap_journey/screen/common_screen/constant.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:snap_journey/service/submitRating.dart';
import 'package:auto_size_text/auto_size_text.dart';

class SettingScreen extends StatelessWidget {
  final String data;

  const SettingScreen({super.key, required this.data});

  void back() {
    AdsVariable.inAppFlag = 0;
    Get.back();
  }

  @override
  Widget build(BuildContext context) {
    FirebaseAnalyticsService.logEvent(eventName: 'Snap_Journey_setting_screen');
    final InitializationHelper initializationHelper = InitializationHelper();

    final controller = Get.find<MomentsController>();
    bool isShare = false;
    return Scaffold(
      backgroundColor: appbackgroundColor,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        forceMaterialTransparency: true,
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        centerTitle: true,
        leading: PressUnpress(
          onTap: () {
            Get.back();
          },
          height: 120.h,
          width: 120.w,
          imageAssetPress: 'assets/home_screen/back_arrow.png',
          imageAssetUnPress: 'assets/home_screen/back_arrow.png',
        ).marginAll(30.w),
        title: AutoSizeText(
          'Setting'.tr,
          style: TextStyle(
            color: Colors.black,
            fontSize: 70.sp,
            fontFamily: fontFamilySemiBold,
          ),
        ),
      ),
      body: WillPopScope(
        onWillPop: () async {
          back();
          return false;
        },
        child: Container(
          width: 1242.w,
          height: 2688.h,
          decoration: const BoxDecoration(
            color: Colors.white
            // image: DecorationImage(
            //   image: AssetImage('assets/splash_screen/bg.png'),
            //   fit: BoxFit.cover,
            // ),
          ),
          child: SafeArea(
            child: Center(
              child: Column(
                children: [
                  if (!AdsVariable.isPurchase.value) 5.verticalSpace,
                  if (!AdsVariable.isPurchase.value)
                    PressUnpress(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                const UpsellScreen(item: true),
                          ),
                        );
                      },
                      height: 980.h,
                      width: 1103.w,
                      imageAssetPress:
                          'assets/premium_screen/proimmage.png',
                      imageAssetUnPress: 'assets/premium_screen/proimmage.png',
                    ),
                  10.verticalSpace,
                  PressUnpress(
                    onTap: () {
                      ConnectivityService.checkConnectivity().then((value) {
                        if (value) {
                          SubmitRating().submitRating(context);
                        } else {
                          DialogService.showCheckConnectivity(context);
                        }
                      });
                    },
                    height: 180.h,
                    width: 1103.w,
                    pressLinearGradient: pressLinearGradiant,
                    unPressLinearGradient: unPressLinearGradiant,
                    child: Center(
                      child: AutoSizeText(
                        "Rate".tr,
                        style: TextStyle(
                          fontSize: 45.sp,
                          fontFamily: "semibold",
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  40.verticalSpace,
                  PressUnpress(
                    onTap: () async{
                     await Get.to(()=>LanguageScreen(isFrom: "home"));
                    },
                    height: 180.h,
                    width: 1103.w,
                    pressLinearGradient: pressLinearGradiant,
                    unPressLinearGradient: unPressLinearGradiant,
                    child: Center(
                      child: AutoSizeText(
                        "Language".tr,
                        style: TextStyle(
                          fontSize: 45.sp,
                          fontFamily: "semibold",
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),

                  40.verticalSpace,

                  PressUnpress(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const PrivacyPolicy(),
                        ),
                      );
                    },
                    height: 180.h,
                    width: 1103.w,
                    pressLinearGradient: pressLinearGradiant,
                    unPressLinearGradient: unPressLinearGradiant,
                    child: Center(
                      child: AutoSizeText(
                        "Privacy Policy".tr,
                        style: TextStyle(
                          fontSize: 45.sp,
                          fontFamily: "semibold",
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),

                  40.verticalSpace,

                  PressUnpress(
                    onTap: () {
                      ConnectivityService.checkConnectivity().then((value) {
                        if (value) {
                          if (!isShare) {
                            isShare = true;
                            SubmitRating().shareContent(context);
                            Future.delayed(const Duration(seconds: 2), () {
                              isShare = false;
                            });
                          }
                        } else {
                          DialogService.showCheckConnectivity(context);
                        }
                      });
                    },
                    height: 180.h,
                    width: 1103.w,
                    pressLinearGradient: pressLinearGradiant,
                    unPressLinearGradient: unPressLinearGradiant,
                    child: Center(
                      child: AutoSizeText(
                        "Share".tr,
                        style: TextStyle(
                          fontSize: 45.sp,
                          fontFamily: "semibold",
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),

                  60.verticalSpace,

                  // if (data == '1')
                    PressUnpress(
                      onTap: () async {
                        final didChangePreferences =
                        await initializationHelper.changePrivacyPreferences();

                        showToast(
                          msg: didChangePreferences
                              ? 'Your privacy choices have been updated'
                              : 'An error occurred while trying to change your privacy choices',
                        );
                      },
                      height: 180.h,
                      width: 1103.w,
                      pressLinearGradient: pressLinearGradiant,
                      unPressLinearGradient: unPressLinearGradiant,
                      child: Center(
                        child: AutoSizeText(
                          "Privacy Choices".tr,
                          style: TextStyle(
                            fontSize: 45.sp,
                            fontFamily: "semibold",
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),

                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
