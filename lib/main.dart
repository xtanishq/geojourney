import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:snap_journey/controller/BottomNavController.dart';
import 'package:snap_journey/controller/Cameracontroller.dart';
import 'package:snap_journey/controller/LocationService2.dart';
import 'package:snap_journey/controller/MomentsController.dart';
import 'package:snap_journey/controller/TagStyleController.dart';
import 'package:snap_journey/controller/network_controller.dart';
import 'package:snap_journey/controller/splash_controller.dart';
import 'package:snap_journey/in_app_purchase/store_config.dart';
import 'package:snap_journey/model/NotificationPlan.dart';
import 'package:snap_journey/model/TimelineGroup.dart';
import 'package:snap_journey/model/moment.dart';
import 'package:snap_journey/service/DatabaseService.dart';
import 'package:snap_journey/service/DefaultNotificationService.dart';
import 'package:snap_journey/service/NotificationService.dart';
import 'package:snap_journey/service/Routes.dart';
import 'package:snap_journey/screen/common_screen/constant.dart';

import 'configuration/firebase.dart';
import 'in_app_purchase/constant.dart';
import 'language/language.dart';

void main() async {
  // if (Platform.isIOS || Platform.isMacOS) {
  //   StoreConfig(store: Store.appStore, apiKey: appleApiKey);
  // } else if (Platform.isAndroid) {
  //   const useAmazon = bool.fromEnvironment("amazon");
  //   StoreConfig(
  //     store: useAmazon ? Store.amazon : Store.playStore,
  //     apiKey: useAmazon ? amazonApiKey : googleApiKey,
  //   );
  // }

  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences pref = await SharedPreferences.getInstance();

  // WidgetsBinding.instance.addObserver(AppLifecycleObserver());
  DependencyInjection.init();

  // await _configureSDK();
  // await firebaseConfigure();

  await Hive.initFlutter();
  Hive.registerAdapter(MomentAdapter());
  Hive.registerAdapter(TimelineGroupAdapter());
  await Hive.openBox<Moment>('moments');
  await DatabaseService.init();

  // Hive.registerAdapter(NotificationPlanAdapter());
  // await Hive.openBox<NotificationPlan>('notification_plans');
  //
  // final notificationService = NotificationService();
  // await notificationService.init();
  // Get.put(notificationService);
  // Get.put(NotificationPlanService(), permanent: true);
  //
  // await NotificationPlanService.to.onInit();

  MobileAds.instance.initialize();
  istaped = pref.getBool('istaped') ?? false;
  languagecode = pref.getString('languagecode') ?? 'en';
  countrycode = pref.getString('countrycode') ?? 'US';
// print("$istaped======");
//   print({"$languagecode=========="});
//   print("$countrycode======");
  runApp(const MyApp());
}

Future<void> _configureSDK() async {
  await Purchases.setLogLevel(LogLevel.debug);
  PurchasesConfiguration configuration;
  if (StoreConfig.isForAmazonAppstore()) {
    configuration = AmazonConfiguration(StoreConfig.instance.apiKey);
  } else {
    configuration = PurchasesConfiguration(StoreConfig.instance.apiKey);
  }
  configuration.entitlementVerificationMode =
      EntitlementVerificationMode.informational;
  await Purchases.configure(configuration);
  await Purchases.enableAdServicesAttributionTokenCollection();
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);

    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle.light.copyWith(
        systemNavigationBarColor: appbackgroundColor,
        statusBarColor: appbackgroundColor,
      ),
    );

    return ScreenUtilInit(
      designSize: const Size(1242, 2688),
      minTextAdapt: true,
      splitScreenMode: true,

      builder: (context, child) {
        return GetMaterialApp(
          // showPerformanceOverlay: true,
          title: appName,

          debugShowCheckedModeBanner: false,
          translations: Language(),
          locale: (istaped!)
              ? Locale('en', 'US')
              : Locale(languagecode ?? 'en', countrycode ?? 'US'),
          theme: ThemeData(
            fontFamily: "medium",
            colorScheme: ColorScheme.fromSeed(seedColor: appColor),
            useMaterial3: true,
          ),
          initialBinding: BindingsBuilder(() {
            Get.put(SplashController());
            // Get.lazyPut<Cameracontroller>(() => Cameracontroller());
            Get.put(MomentsController());
            Get.put(TagStyleController());
            Get.put(LocationService2());
          }),
          initialRoute: '/',
          getPages: appRoutes,
        );
      },
    );
  }
}
//
// class AppLifecycleObserver extends WidgetsBindingObserver {
//   @override
//   void didChangeAppLifecycleState(AppLifecycleState state) {
//     if (state == AppLifecycleState.resumed) {
//       if (Get.isRegistered<NotificationPlanService>()) {
//         NotificationPlanService.to.checkAndRefreshCache();
//       }
//     }
//   }
// }