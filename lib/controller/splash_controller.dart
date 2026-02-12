import 'dart:async';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:snap_journey/configuration/FirebaseAnalyticsService.dart';
import 'package:snap_journey/google_ads_material/InterstitialAdUtil.dart';
import 'package:snap_journey/google_ads_material/ads_variable.dart';
import 'package:snap_journey/google_ads_material/app_open_ad_manager.dart';
import 'package:snap_journey/google_ads_material/nativeAdService.dart';
import 'package:snap_journey/google_ads_material/requesting_consent.dart';
import 'package:snap_journey/in_app_purchase/app.dart';
import 'package:snap_journey/in_app_purchase/initPlatformState.dart';
import 'package:snap_journey/permission/permission_view.dart';
import 'package:snap_journey/screen/CameraScreen.dart';
import 'package:snap_journey/screen/common_screen/language_screen.dart';
import 'package:snap_journey/screen/common_screen/onboarding_screen.dart';
import 'package:snap_journey/service/checkConnectivity.dart';
import 'package:snap_journey/service/sharedPreferencesService.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../screen/HomeScreenNew.dart';
import '../screen/common_screen/constant.dart';

class SplashController extends GetxController {
  AppOpenAdManager appOpenAdManager = AppOpenAdManager();
  final InitializationHelper _initializationHelper = InitializationHelper();

  // FirebaseAnalytics analytics = FirebaseAnalytics.instance;
  NativeAdService nativeAdService = Get.put(NativeAdService());

  @override
  void onInit() {
    super.onInit();
    getvariable();
    initializeSplash();
  }
  Future<void> getvariable() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    istaped = pref.getBool('istaped') ?? false;
    languagecode = pref.getString('languagecode') ?? 'en';
    countrycode = pref.getString('countrycode') ?? 'US';
    languagename = pref.getString('languagename') ?? 'English';
    isdone = pref.getBool('isdone') ?? false;
    print("++++++++++++++++++++++++++");
    print(isdone);
    print("++++++++++++++++++++++++++");
    var locale = Locale(languagecode ?? 'en', countrycode ?? 'US');
    Get.updateLocale(locale);
  }


  Future<void> initializeSplash() async {
    FirebaseAnalyticsService.logEvent(eventName: 'Snap_Journey_splash_screen');
    // analytics.setAnalyticsCollectionEnabled(true);

    ConnectivityService.checkConnectivity().then((isConnected) async {
      if (isConnected) {
        try {
          // loadNative();
          CheckPurchasesStatus.initPlatformState().then((value) {
            if (value) {
              withoutPurchaseNavigation();
            } else {
              _initialize();
            }
          });
        } catch (e) {
          futureNavigation();
        }
      } else {
        futureNavigation();
      }
    });
    // setScreen();
  }
  Future<void> _initialize() async {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _initializationHelper.initialize();

      if (AdsVariable.fullscreen_on_in_splash_screen == '0' &&
          AdsVariable.appopen != '11') {
        AppOpenAd.load(
          adUnitId: AdsVariable.appopen,
          request: const AdRequest(),
          adLoadCallback: AppOpenAdLoadCallback(
            onAdLoaded: (ad) {
              AppOpenAdManager.appOpenAd = ad;
              AppOpenAdManager.appOpenAd!.fullScreenContentCallback =
                  FullScreenContentCallback(
                    onAdShowedFullScreenContent: (ad) {},
                    onAdFailedToShowFullScreenContent: (ad, error) {
                      withoutTimerNavigateToMainScreen();
                    },
                    onAdDismissedFullScreenContent: (ad) {
                      withoutTimerNavigateToMainScreen();
                    },
                  );
              AppOpenAdManager.appOpenAd!.show();
              AppOpenAdManager.appOpenAd = null;
              appOpenAdManager.loadAd();
            },
            onAdFailedToLoad: (error) {
              AppOpenAdManager.appOpenAd = null;
              appOpenAdManager.loadAd();
              navigateToMainScreen();
            },
          ),
        );
      } else {
        if (AdsVariable.appopen != '11') {
          appOpenAdManager.loadAd();
        }
        if (AdsVariable.fullscreen_splash_screen_high != '11') {
          InterstitialAd.load(
            adUnitId: AdsVariable.fullscreen_splash_screen_high,
            request: const AdRequest(),
            adLoadCallback: InterstitialAdLoadCallback(
              onAdLoaded: (ad) {
                InterstitialAdManager.interstitialAd = ad;
                InterstitialAdManager
                    .interstitialAd!
                    .fullScreenContentCallback = FullScreenContentCallback(
                  onAdDismissedFullScreenContent: (ad) {
                    ad.dispose();
                    withoutTimerNavigateToMainScreen();
                  },
                  onAdFailedToShowFullScreenContent: (ad, error) {
                    ad.dispose();
                    navigateToMainScreen();
                  },
                );
                InterstitialAdManager.interstitialAd!.show();
                InterstitialAdManager.interstitialAd = null;
              },
              onAdFailedToLoad: (error) {
                InterstitialAdManager.interstitialAd = null;
                InterstitialAd.load(
                  adUnitId: AdsVariable.fullscreen_splash_screen_normal,
                  request: const AdRequest(),
                  adLoadCallback: InterstitialAdLoadCallback(
                    onAdLoaded: (ad) {
                      InterstitialAdManager.interstitialAd = ad;
                      InterstitialAdManager
                              .interstitialAd!
                              .fullScreenContentCallback =
                          FullScreenContentCallback(
                            onAdDismissedFullScreenContent: (ad) {
                              ad.dispose();
                              withoutTimerNavigateToMainScreen();
                            },
                            onAdFailedToShowFullScreenContent: (ad, error) {
                              ad.dispose();
                              navigateToMainScreen();
                            },
                          );
                      InterstitialAdManager.interstitialAd!.show();
                      InterstitialAdManager.interstitialAd = null;
                    },
                    onAdFailedToLoad: (error) {
                      navigateToMainScreen();
                    },
                  ),
                );
              },
            ),
          );
        } else {
          navigateToMainScreen();
        }
      }
    });
  }
  Future<void> futureNavigation() async {
    return Future.delayed(const Duration(seconds: 3), () async {
      // Get.offAll(const CameraScreen(), transition: Transition.fadeIn);
      _navigatetoscreen();

      // Get.offAll(const Homescreennew(), transition: Transition.fadeIn);
    });
  }

  Future<void> withoutPurchaseNavigation() async {
    InterstitialAdManager.getInterstitial(AdsVariable.fullscreen_preload_high);
    Timer(const Duration(seconds: 3), () {
      _navigatetoscreen();

    });
  }

  Future<void> navigateToMainScreen() async {
    InterstitialAdManager.getInterstitial(AdsVariable.fullscreen_preload_high);
    Timer(const Duration(seconds: 3), () {
      _navigatetoscreen();

    });
  }

  Future<void> withoutTimerNavigateToMainScreen() async {
    InterstitialAdManager.getInterstitial(AdsVariable.fullscreen_preload_high);
    _navigatetoscreen();
  }
  _navigatetoscreen(){

    SharedPreferencesService.getUser().then((value) {
      Get.offAll(
        value.isNotEmpty
            ? const UpsellScreen(item: false)
            : LanguageScreen(isFrom: "splash"),
        transition: Transition.fadeIn,
      );
    });
  }
}
