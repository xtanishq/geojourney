import 'package:snap_journey/configuration/FirebaseAnalyticsService.dart';
import 'package:snap_journey/google_ads_material/InterstitialAdUtil.dart';
import 'package:snap_journey/in_app_purchase/constant.dart';
import 'package:snap_journey/in_app_purchase/initPlatformState.dart';
import 'package:snap_journey/google_ads_material/ads_variable.dart';
import 'package:snap_journey/screen/CameraScreen.dart';
import 'package:snap_journey/screen/common_screen/constant.dart';
import 'package:snap_journey/service/possessing_dialog.dart';
import 'package:snap_journey/service/sharedPreferencesService.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:video_player/video_player.dart';

import '../screen/HomeScreenNew.dart';

class UpsellController extends GetxController {
  final bool item;
  Rx<Offerings?> offerings = Rx<Offerings?>(null);
  RxBool isClose = false.obs;
  RxMap<String, Package> availablePackages = <String, Package>{}.obs;
  Rx<Package?> selectedPackage = Rx<Package?>(null);
  RxBool week = true.obs;
  RxBool month = false.obs;
  RxBool lifetime = false.obs;
  double originalWeekPrice = 0;

  UpsellController(this.item);

  @override
  void onInit() {
    super.onInit();
    // if (item) {
    //   FirebaseAnalyticsService.logEvent(
    //     eventName: 'Snap_Journey_premium_screen_from_feature',
    //   );
    // } else {
    //   FirebaseAnalyticsService.logEvent(
    //     eventName: 'Snap_Journey_premium_screen_from_splash',
    //   );
    // }
    // fetchData();
    // videoController = VideoPlayerController.asset(
    //   'assets/splash_screen/splash.mp4', // Change to your video path
    // )..initialize().then((_) {
    //   // Ensure the first frame is shown after the video is initialized
    //   videoController.setLooping(true); // Set to true if you want loop
    //   videoController.setVolume(0.0); // Mute audio if it's a background
    //   videoController.play();
    // });
    // Future.delayed(const Duration(seconds: 3), () {
    //   isClose.value = true;
    // });
  }

  late VideoPlayerController videoController;

  @override
  void dispose() {
    videoController.dispose();
    super.dispose();
  }

  Future<void> fetchData() async {
    try {
      final offeringsResult = await Purchases.getOfferings();
      print(offeringsResult);
      offerings.value = offeringsResult;
      availablePackages.assignAll({
        for (var package in offeringsResult.current?.availablePackages ?? [])
          package.identifier: package,
      });

      if (availablePackages.length >= 2) {
        selectedPackage.value = availablePackages.entries.elementAt(1).value;
      }
      print(offerings.value);
      print(availablePackages.length);
    } on PlatformException catch (e) {
      if (kDebugMode) {
        print(e);
        showToast(msg: e.toString());
      }
    }
  }

  void backToHome(BuildContext context) async {
    InterstitialAdManager.showInterstitial(
      onAdDismissed: () {
        print(item);
        if (item) {
          Get.back();
        } else {
         SharedPreferencesService.setLang(false);

          // Get.offAll(const CameraScreen(), transition: Transition.fadeIn);
          Get.offAll(const Homescreennew(), transition: Transition.fadeIn);
        }
      },
      id: item ? AdsVariable.fullscreen_in_app_screen : '11',
      isContinue: AdsVariable.in_app_screen_ad_continue_ads_online,
      flag: AdsVariable.inAppFlag,
      context: context,
    );
    if (item) {
      AdsVariable.inAppFlag++;
    }
  }

  Future<void> storeCredit() async {
    int credit = await SharedPreferencesService.getCreditValue('Credit');
    credit += (selectedPackage.value?.storeProduct.identifier == planOne)
        ? AdsVariable.weekCredit
        : AdsVariable.yearCredit;
    SharedPreferencesService.setCreditValue(credit, 'Credit');
    AdsVariable.credits.value = credit;
  }

  Future<void> buySubscription(BuildContext context) async {
    ProgressDialog.show2('');
    try {
      final customerInfo = await Purchases.purchasePackage(
        selectedPackage.value!,
      );
      appData.entitlementIsActive =
          customerInfo.customerInfo.entitlements.all[entitlementKey]!.isActive;
      CheckPurchasesStatus.initPlatformState().then((value) {
        if (value) {
          showToast(msg: 'Your plan subscribe successfully');
          storeCredit();
          if (item) {
            Get.back();
          } else {
            Get.offAll(const Homescreennew(), transition: Transition.fadeIn);
            // Get.offAll(const CameraScreen(), transition: Transition.fadeIn);
          }
        } else {
          showToast(msg: 'Failed');
        }
      });
    } on PlatformException catch (e) {
      if (kDebugMode) {
        print('object++$e');
      }
      final errorCode = PurchasesErrorHelper.getErrorCode(e);
      if (errorCode == PurchasesErrorCode.purchaseCancelledError) {
        if (kDebugMode) {
          print('User cancelled');
        }
      } else if (errorCode == PurchasesErrorCode.purchaseNotAllowedError) {
        if (kDebugMode) {
          print('User not allowed to purchase');
        }
      } else if (errorCode == PurchasesErrorCode.paymentPendingError) {
        if (kDebugMode) {
          print('Payment is pending');
        }
      }
    }
    ProgressDialog.dismiss2();
  }
}

class AppData {
  static final AppData _appData = AppData._internal();

  bool entitlementIsActive = false;
  String appUserID = '';

  factory AppData() {
    return _appData;
  }

  AppData._internal();
}

final appData = AppData();
