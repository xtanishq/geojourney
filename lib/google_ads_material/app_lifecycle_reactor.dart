import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'ads_variable.dart';
import 'app_open_ad_manager.dart';

class AppLifecycleReactor {
  final AppOpenAdManager appOpenAdManager;

  AppLifecycleReactor({required this.appOpenAdManager});

  void listenToAppStateChanges() {
    AppStateEventNotifier.startListening();
    AppStateEventNotifier.appStateStream.forEach((state) => _onAppStateChanged(state));
  }

  void _onAppStateChanged(AppState appState) {
    if (appState == AppState.foreground) {
      if(AdsVariable.appopen != '11' && AdsVariable.isPurchase.isFalse){
        appOpenAdManager.showAdIfAvailable();
      }
    }
  }
}