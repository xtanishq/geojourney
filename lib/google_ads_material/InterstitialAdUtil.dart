import 'dart:ui';

import 'package:snap_journey/google_ads_material/ads_variable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svprogresshud/flutter_svprogresshud.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:auto_size_text/auto_size_text.dart';

class InterstitialAdManager {
  static InterstitialAd? interstitialAd;
  static bool isAdShow = true;

  static Future getInterstitial(String highId) async {
    interstitialAd = null;
    InterstitialAd.load(
      adUnitId: highId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (InterstitialAd ad) {
          print('$ad loaded');
          print(
            "highId=====================================================================",
          );
          interstitialAd = ad;
        },
        onAdFailedToLoad: (LoadAdError error) {
          print('InterstitialAd failed to load: $error.');
          interstitialAd = null;
          InterstitialAd.load(
            adUnitId: AdsVariable.fullscreen_preload_normal,
            request: const AdRequest(),
            adLoadCallback: InterstitialAdLoadCallback(
              onAdLoaded: (InterstitialAd ad) {
                print('$ad loaded');
                print(
                  "fullscreen_preload_normal=====================================================================",
                );
                interstitialAd = ad;
              },
              onAdFailedToLoad: (LoadAdError error) {
                print('InterstitialAd failed to load: $error.');
                interstitialAd = null;
              },
            ),
          );
        },
      ),
    );
  }

  static void showInterstitial({
    required VoidCallback onAdDismissed,
    required String id,
    required String isContinue,
    required int flag,
    required BuildContext context,
  }) {
    try {
      if (isContinue == '0') {
        flag = 0;
      }
      if (id != '11' && flag.isEven) {
        if (interstitialAd != null) {
          interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              ad.dispose();
              navigateToScreen(onAdDismissed);
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              ad.dispose();
              navigateToScreen(onAdDismissed);
            },
          );
          interstitialAd!.show();
          interstitialAd == null;
        } else {
          if (Platform.isIOS) {
            showCupertinoDialog(
              context: context,
              builder: (context) {
                return const CupertinoAlertDialog(
                  content: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      CupertinoActivityIndicator(),
                      AutoSizeText('Ad loading'),
                    ],
                  ),
                );
              },
            );
          } else {
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (context) {
                return const AlertDialog(
                  content: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [CircularProgressIndicator(), AutoSizeText('Ad loading')],
                  ),
                );
              },
            );
          }
          interstitialAd = null;
          InterstitialAd.load(
            adUnitId: AdsVariable.fullscreen_preload_high,
            request: const AdRequest(),
            adLoadCallback: InterstitialAdLoadCallback(
              onAdLoaded: (ad) {
                interstitialAd = ad;
                Get.back();
                interstitialAd!.fullScreenContentCallback =
                    FullScreenContentCallback(
                      onAdDismissedFullScreenContent: (ad) {
                        ad.dispose();
                        navigateToScreen(onAdDismissed);
                      },
                      onAdFailedToShowFullScreenContent: (ad, error) {
                        ad.dispose();
                        navigateToScreen(onAdDismissed);
                      },
                    );
                interstitialAd!.show();
                interstitialAd == null;
              },
              onAdFailedToLoad: (error) {
                interstitialAd == null;
                InterstitialAd.load(
                  adUnitId: AdsVariable.fullscreen_preload_normal,
                  request: const AdRequest(),
                  adLoadCallback: InterstitialAdLoadCallback(
                    onAdLoaded: (ad) {
                      interstitialAd = ad;
                      Get.back();
                      interstitialAd!.fullScreenContentCallback =
                          FullScreenContentCallback(
                            onAdDismissedFullScreenContent: (ad) {
                              ad.dispose();
                              navigateToScreen(onAdDismissed);
                            },
                            onAdFailedToShowFullScreenContent: (ad, error) {
                              ad.dispose();
                              navigateToScreen(onAdDismissed);
                            },
                          );
                      interstitialAd!.show();
                      interstitialAd == null;
                    },
                    onAdFailedToLoad: (error) {
                      Get.back();
                      navigateToScreen(onAdDismissed);
                    },
                  ),
                );
              },
            ),
          );
        }
      } else {
        navigateToScreen(onAdDismissed);
      }
    } catch (e) {
      navigateToScreen(onAdDismissed);
    }
  }

  static void navigateToScreen(VoidCallback onAdDismissed) {
    getInterstitial(AdsVariable.fullscreen_preload_high);
    onAdDismissed();
  }
}
