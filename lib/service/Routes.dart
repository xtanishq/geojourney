import 'package:get/get.dart';
import 'package:snap_journey/screen/CameraScreen.dart';
import 'package:snap_journey/screen/MapScreen.dart';
import 'package:snap_journey/screen/MemoriesScreen.dart';
import 'package:snap_journey/screen/NotesScreen.dart';
import 'package:snap_journey/screen/PreviewScreen.dart';
import 'package:snap_journey/screen/TimelineScreen.dart';
import 'package:snap_journey/screen/common_screen/setting_screen.dart';
import 'package:snap_journey/screen/common_screen/splash_screen.dart';

import '../controller/Cameracontroller.dart';
import '../screen/HomeScreenNew.dart';

List<GetPage> appRoutes = [
  GetPage(
    name: '/',
    page: () => const SplashScreen(),
    transition: Transition.fadeIn,
  ),

  GetPage(
    name: '/homescreennew',
    page: () => const Homescreennew(),
    transition: Transition.fadeIn,
  ),
  GetPage(
    name: '/CameraScreen',
    page: () =>  CameraScreen(),
    binding: BindingsBuilder(() {
      // Best Practice: Sirf zaroorat padne par controller load hoga
      Get.lazyPut<Cameracontroller>(() => Cameracontroller(),fenix: true);
    }),
  ),

  GetPage(
    name: '/map',
    page: () => const MapScreen(),
    transition: Transition.fadeIn,
  ),
  GetPage(
    name: '/timeline',
    page: () => const TimelineScreen(),
    transition: Transition.fadeIn,
  ),
  GetPage(
    name: '/memories',
    page: () => MemoriesScreen(),
    transition: Transition.fadeIn,
  ),
  // GetPage(
  //   name: '/notes',
  //   page: () => const NotesScreen(),
  //   transition: Transition.fadeIn,
  // ),
  GetPage(
    name: '/preview',
    page: () => const PreviewScreen(),
    transition: Transition.fadeIn,
  ),
];

