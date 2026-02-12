import 'dart:convert';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:snap_journey/google_ads_material/ads_variable.dart';

import 'firebase_options.dart';

Future<void> firebaseConfigure() async {
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    final remoteConfig = FirebaseRemoteConfig.instance;
    await remoteConfig.setConfigSettings(
      RemoteConfigSettings(
        fetchTimeout: const Duration(minutes: 1),
        minimumFetchInterval: const Duration(minutes: 5),
      ),
    );
    await remoteConfig.fetchAndActivate();

    Map<String, dynamic> mapValues = jsonDecode(
      remoteConfig.getValue("snap_journey").asString(),
    );
    // print("facebookId-------- $mapValues");

    // AdsVariable.username = mapValues["username"] ?? 'admin';
    // AdsVariable.password = mapValues["password"] ?? '1234';

    AdsVariable.nativeBGColor = mapValues["nativeBGColor"] ?? "F0F0F0";
    AdsVariable.headerTextColor = mapValues["headerTextColor"] ?? "000000";
    AdsVariable.bodyTextColor = mapValues["bodyTextColor"] ?? "828282";
    AdsVariable.btnBgStartColor = mapValues["btnBgStartColor"] ?? "4381FF";
    AdsVariable.btnBgEndColor = mapValues["btnBgEndColor"] ?? "2B67FE";
    AdsVariable.btnTextColor = mapValues["btnTextColor"] ?? "FFFFFF";
    AdsVariable.btnAdBgColor = mapValues["btnAdBgColor"] ?? "3775FF";
    AdsVariable.btnAdTextColor = mapValues["btnAdTextColor"] ?? "FFFFFF";

    AdsVariable.facebookId = mapValues["facebookId"] ?? '11';
    AdsVariable.facebookToken = mapValues["facebookToken"] ?? '11';

    AdsVariable.googleApiKey = mapValues['googleApiKey'] ?? '';

    AdsVariable.show_week_price = mapValues['show_week_price'] ?? '1';
    AdsVariable.show_close_delay = mapValues['show_close_delay'] ?? '0';
    AdsVariable.show_rate_intro = mapValues['show_rate_intro'] ?? '0';

    AdsVariable.fullscreen_on_in_splash_screen =
        mapValues['fullscreen_on_in_splash_screen'] ?? '1';

    AdsVariable.in_app_screen_ad_continue_ads_online =
        mapValues['in_app_screen_ad_continue_ads_online'] ?? '1';
    AdsVariable.map_screen_ad_continue_ads_online =
        mapValues['map_screen_ad_continue_ads_online'] ?? '1';
    AdsVariable.timeline_config_screen_ad_continue_ads_online =
        mapValues['timeline_config_screen_ad_continue_ads_online'] ?? '1';
    AdsVariable.memories_screen_ad_continue_ads_online =
        mapValues['memories_screen_ad_continue_ads_online'] ?? '1';
    AdsVariable.edit_screen_ad_continue_ads_online =
        mapValues['edit_screen_ad_continue_ads_online'] ?? '1';
    AdsVariable.tagStyle_screen_ad_continue_ads_online =
        mapValues['tagStyle_screen_ad_continue_ads_online'] ?? '1';

    AdsVariable.fullscreen_preload_high =
        mapValues['fullscreen_preload_high'] ?? '11';
    AdsVariable.fullscreen_preload_normal =
        mapValues['fullscreen_preload_normal'] ?? '11';
    AdsVariable.fullscreen_splash_screen_high =
        mapValues['fullscreen_splash_screen_high'] ?? '11';
    AdsVariable.fullscreen_splash_screen_normal =
        mapValues['fullscreen_splash_screen_normal'] ?? '11';
    AdsVariable.fullscreen_in_app_screen =
        mapValues['fullscreen_in_app_screen'] ?? '11';
    AdsVariable.fullscreen_map_screen =
        mapValues['fullscreen_map_screen'] ?? '11';
    AdsVariable.fullscreen_edit_screen =
        mapValues['fullscreen_edit_screen'] ?? '11';
    AdsVariable.fullscreen_memories_screen =
        mapValues['fullscreen_memories_screen'] ?? '11';
    AdsVariable.fullscreen_timeline_screen =
        mapValues['fullscreen_timeline_screen'] ?? '11';
    AdsVariable.fullscreen_tagStyle_screen =
        mapValues['fullscreen_tagStyle_screen'] ?? '11';

    AdsVariable.banner_map_screen = mapValues['banner_map_screen'] ?? '11';
    AdsVariable.banner_memories_screen =
        mapValues['banner_memories_screen'] ?? '11';
    AdsVariable.banner_img_preview_screen =
        mapValues['banner_img_preview_screen'] ?? '11';
    AdsVariable.banner_vid_preview_screen =
        mapValues['banner_vid_preview_screen'] ?? '11';
    AdsVariable.banner_tagStyle_screen =
        mapValues['banner_tagStyle_screen'] ?? '11';

    AdsVariable.big_native_intro_screen =
        mapValues['big_native_intro_screen'] ?? '11';

    AdsVariable.appopen = mapValues['appopen'] ?? '11';

    AdsVariable.morningPrompts = _parsePromptList(
      mapValues["morningPrompts"],
      defaultList: AdsVariable.morningPrompts,
    );
    AdsVariable.middayPrompts = _parsePromptList(
      mapValues["middayPrompts"],
      defaultList: AdsVariable.middayPrompts,
    );
    AdsVariable.eveningPrompts = _parsePromptList(
      mapValues["eveningPrompts"],
      defaultList: AdsVariable.eveningPrompts,
    );
    AdsVariable.memoryTemplate = _parseMemoryTemplate(
      mapValues["memoryTemplate"],
    );

    // // ✅ Debug check
    // debugPrint(
    //   "🌅 Morning Prompts Loaded: ${AdsVariable.morningPrompts.length}",
    // );
    // debugPrint("🌞 Midday Prompts Loaded: ${AdsVariable.middayPrompts.length}");
    // debugPrint(
    //   "🌙 Evening Prompts Loaded: ${AdsVariable.eveningPrompts.length}",
    // );
    // debugPrint("🧠 Memory Template: ${AdsVariable.memoryTemplate}");

    setupFbAdsId();

    FlutterError.onError = (errorDetails) {
      FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
    };
    PlatformDispatcher.instance.onError = (error, stack) {
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      return true;
    };
  } on Exception catch (e) {
    return;
  }
}

List<Map<String, String>> _parsePromptList(
    dynamic data, {
      required List<Map<String, String>> defaultList,
    }) {
  if (data is! List) return defaultList;
  try {
    return data
        .map<Map<String, String>>((item) {
      if (item is Map) {
        return {
          'title': item['title']?.toString() ?? '',
          'body': item['body']?.toString() ?? '',
        };
      }
      return <String, String>{};
    })
        .where((m) => m['title']!.isNotEmpty)
        .toList();
  } catch (e) {
    debugPrint("⚠️ Failed to parse prompt list: $e");
    return defaultList;
  }
}

Map<String, String> _parseMemoryTemplate(dynamic data) {
  if (data is Map) {
    return {
      'title': data['title']?.toString() ?? 'On this day…',
      'body':
      data['body']?.toString() ??
          'On this day {years} year{s} ago, you were in {place} — relive the memory!',
    };
  }
  return AdsVariable.memoryTemplate;
}

setupFbAdsId() {
  const platformMethodChannel = MethodChannel('nativeChannel');
  platformMethodChannel.invokeMethod('setToast', {
    'isPurchase': AdsVariable.isPurchase.value.toString(),
    'facebookId': AdsVariable.facebookId,
    'facebookToken': AdsVariable.facebookToken,
    'nativeBGColor': AdsVariable.nativeBGColor,
    'headerTextColor': AdsVariable.headerTextColor,
    'bodyTextColor': AdsVariable.bodyTextColor,
    'btnBgStartColor': AdsVariable.btnBgStartColor,
    'btnBgEndColor': AdsVariable.btnBgEndColor,
    'btnTextColor': AdsVariable.btnTextColor,
    'btnAdBgColor': AdsVariable.btnAdBgColor,
    'btnAdTextColor': AdsVariable.btnAdTextColor,
  });
}
