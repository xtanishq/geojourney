import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'ads_variable.dart';

class AppOpenAdManager {
  static AppOpenAd? appOpenAd;
  static bool _isShowingAd = false;
  static bool isLoaded = false;
  static bool dismissed = false;
  static bool shouldShowAd = true;

  void loadAd() {
    print("app open loading:=====================================================================");
    AppOpenAd.load(
      adUnitId: AdsVariable.appopen,
      request: const AdRequest(),
      adLoadCallback: AppOpenAdLoadCallback(
        onAdLoaded: (ad) {
          print("Ad Loaded:=====================================================================");
          appOpenAd = ad;
          isLoaded = true;
        },
        onAdFailedToLoad: (error) {
          print("Ad Not Loaded:=====================================================================");
          print(error);
        },
      ),
    );
  }

  static bool get isAdAvailable {
    return appOpenAd != null;
  }

  bool get isDismissed {
    return dismissed;
  }

  void showAdIfAvailable() {
    print("Called:=====================================================================");
    if (!shouldShowAd) {
      print('Ad show condition not met.');
      return;
    }
    if (appOpenAd == null) {
      print('Tried to show ad before available.');
      dismissed = true;
      loadAd();
      return;
    }
    if (_isShowingAd) {
      print('Tried to show ad while already showing an ad.');
      return;
    }
    appOpenAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (ad) {
        _isShowingAd = true;
        print('Ad showed full screen content');
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        print('$ad onAdFailedToShowFullScreenContent=======:- $error');
        _isShowingAd = false;
        dismissed = true;
        ad.dispose();
        appOpenAd = null;
        loadAd();
      },
      onAdDismissedFullScreenContent: (ad) {
        print('$ad onAdDismissedFullScreenContent========:-');
        _isShowingAd = false;
        ad.dispose();
        appOpenAd = null;
        dismissed = true;
        loadAd();
      },
    );
    appOpenAd!.show();
    appOpenAd = null;
  }
}