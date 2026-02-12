import 'package:snap_journey/configuration/FirebaseAnalyticsService.dart';
import 'package:snap_journey/google_ads_material/ads_variable.dart';
import 'package:snap_journey/google_ads_material/nativeAdService.dart';
import 'package:snap_journey/in_app_purchase/app.dart';
import 'package:snap_journey/in_app_purchase/initPlatformState.dart';
import 'package:snap_journey/screen/CameraScreen.dart';
import 'package:snap_journey/service/sharedPreferencesService.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class OnBoardingController extends GetxController {
  late PageController pageViewController;
  RxInt currentPageIndex = 0.obs,
      pageLength = AdsVariable.big_native_intro_screen != '11' ? 3.obs : 2.obs;
  NativeAdService nativeAdService = Get.find();

  @override
  void onInit() {
    super.onInit();
    FirebaseAnalyticsService.logEvent(eventName: 'Snap_Journey_onboarding_screen');
    pageViewController = PageController();
    if (AdsVariable.big_native_intro_screen != '11') {
      nativeAdService.loadBigAd(AdsVariable.big_native_intro_screen);
    }
  }

  Future<void> nextScreen() async {
    if (currentPageIndex.value < pageLength.value - 1) {
      currentPageIndex.value++;
      pageViewController.animateToPage(
        currentPageIndex.value,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    } else {
      nextSkipScreen();
    }
  }

  void nextSkipScreen() {
    SharedPreferencesService.setUser('username');
    // SharedPreferencesService.setCreditValue(0, 'Credit');

    CheckPurchasesStatus.initPlatformState().then((value) async {
      if (value) {
        Get.offAll(const CameraScreen(), transition: Transition.fadeIn);
      } else {
        Get.offAll(
          const UpsellScreen(item: false),
          transition: Transition.fadeIn,
        );
      }
    });
  }
}
