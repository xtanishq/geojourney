import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../google_ads_material/app_lifecycle_reactor.dart';
import '../google_ads_material/app_open_ad_manager.dart';

class AdService {
  final AppOpenAdManager appOpenAdManager = AppOpenAdManager();
  late AppLifecycleReactor _appLifecycleReactor;

  AdService() {
    _appLifecycleReactor = AppLifecycleReactor(appOpenAdManager: appOpenAdManager);
    _appLifecycleReactor.listenToAppStateChanges();
  }

  Future<void> gdprAvailable() async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    ConsentInformation.instance.requestConsentInfoUpdate(
      ConsentRequestParameters(),
          () async {
        if (await ConsentInformation.instance.isConsentFormAvailable()) {
          await preferences.setString('keyvalue', "1");
        } else {
          await preferences.setString('keyvalue', "0");
        }
      }, (error) {
        if (kDebugMode) {
        }
      },
    );
  }

  Future<String> getData() async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    return preferences.getString('keyvalue') ?? '';
  }
}
