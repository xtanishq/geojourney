import 'package:snap_journey/controller/onboarding_controller.dart';
import 'package:snap_journey/in_app_purchase/app.dart';
import 'package:snap_journey/screen/CameraScreen.dart';
import 'package:snap_journey/in_app_purchase/initPlatformState.dart';
import 'package:snap_journey/screen/common_screen/constant.dart';
import 'package:snap_journey/service/sharedPreferencesService.dart';
import 'package:snap_journey/service/submitRating.dart';
import 'package:flutter/cupertino.dart';
import 'package:auto_size_text/auto_size_text.dart';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../google_ads_material/ads_variable.dart';
import '../../google_ads_material/nativeAdService.dart';
import '../../service/press_unpress.dart';
import 'package:snap_journey/google_ads_material/shimmer.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../HomeScreenNew.dart';

class OnBoardingScreen extends StatefulWidget {
  final bool fromHome;

  const OnBoardingScreen({required this.fromHome, super.key});

  @override
  State<OnBoardingScreen> createState() => _OnBoardingScreenState();
}

class _OnBoardingScreenState extends State<OnBoardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  final OnBoardingController onBoardingController = Get.put(
    OnBoardingController(),
  );

  late SharedPreferences prefs;
  bool swipe = false;

  // List<String> steps = [
  //   "assets/onboarding_screen/step_1.png",
  //   "assets/onboarding_screen/step_2.png",
  //   "assets/onboarding_screen/step_3.png",
  //   "assets/onboarding_screen/step_3.png",
  // ];
  // 6B7280
  List<String> textts = [
    "Capture Every Moment With Location".tr,
    "Relive Where Memories Were Made".tr,
    "Save & Explore Flawlessly".tr,
  ];
  List<String> subtext = [
    "Real-time GPS stamps on photos & videos — proof of where it happened",
    "Tap any photo on the map to see location, story & details",
    "All captures stored in your private gallery with maps, AI stories & instant sharing",
  ];

  @override
  void initState() {
    super.initState();
    _initPrefs();
    // Initialize analytics or other services if needed
    // FirebaseAnalyticsService.logEvent(eventName: "INTRO_SCREEN");
  }

  void _initPrefs() async {
    prefs = await SharedPreferences.getInstance();
    setState(() {});
  }

  @override
  void didChangeDependencies() {
    if (AdsVariable.big_native_intro_screen != '11') {
      onBoardingController.nativeAdService.loadBigAd(
        AdsVariable.big_native_intro_screen,
      );
    }
    super.didChangeDependencies();
  }

  bool _isAdUnitIdValid() {
    return AdsVariable.big_native_intro_screen != '11';
  }

  late final List<Widget> _pages = [
    OnboardingPage(
      imagePath1: 'assets/onboarding_screen/onboard1.png',
      width: 1242.w,
      height: 2688.h,
    ),

    OnboardingPage(
      imagePath1: 'assets/onboarding_screen/onboard3.png',
      width: 1242.w,
      height: 2688.h,
    ),
    OnboardingPage(
      imagePath1: 'assets/onboarding_screen/onboard2.png',
      width: 1242.w,
      height: 2688.h,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Container(
        width: 1242.w,
        height: 2688.h,
        decoration: const BoxDecoration(
          color: Colors.black,
          // image: DecorationImage(
          //   image: AssetImage('assets/onboarding_screen/bg.png'),
          //   fit: BoxFit.cover,
          // ),
        ),
        child: Stack(
          children: [
            PageView.builder(
              controller: _pageController,
              itemCount: _pages.length,
              itemBuilder: (context, index) {
                return _pages[index];
              },
              onPageChanged: (index) async {
                setState(() {
                  _currentPage = index;
                });

                // if (index == 3 && _isAdUnitIdValid() && !isLoaded) {
                //   isLoaded = true;
                //   nativeAdManager
                //       .loadNativeAd(AdsVariable.native_onboarding_small);
                // }

                setState(() {});
                if (index == 1 && !swipe) {
                  await Future.delayed(const Duration(seconds: 3));
                  if (!mounted) return;

                  setState(() {
                    swipe = true;
                  });
                }

                if (index == _pages.length - 1 &&
                    AdsVariable.showSubmitRating == '1') {
                  print("+++++++++++++++++++++++++++");

                  int saveCount = prefs.getInt('onBoard_save_count') ?? 0;
                  saveCount++;
                  await prefs.setInt('onBoard_save_count', saveCount);
                  print("+++++++++++++++++++++++++++$prefs");
                  if (saveCount == 1) {
                    // FirebaseAnalyticsService.logEvent(
                    //     eventName: "OPEN_RATE_DIALOG_SCREEN");
                    SubmitRating().submitRating(context);
                  }
                }
              },
            ),
            SafeArea(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  if (_currentPage != 2)
                    GestureDetector(
                      onTap: () async {
                        SharedPreferencesService.setUser("username");
                        CheckPurchasesStatus.initPlatformState().then((
                            value,
                            ) async {
                          if (value) {
                            Get.offAll(
                              const Homescreennew(),
                              transition: Transition.fadeIn,
                            );

                          } else {
                            Get.offAll(
                              const UpsellScreen(item: false),
                              transition: Transition.fadeIn,
                            );
                          }
                        });
                      },

                      child: Align(
                        alignment: Alignment.topRight,
                        child: Container(
                          height: 100.h,
                          width: 250.w,
                          margin: EdgeInsets.all(25.w),
                          decoration: BoxDecoration(
                            color: Colors.grey.withOpacity(0.4),
                            borderRadius: BorderRadius.circular(25),
                          ),

                          child: Center(
                            child: AutoSizeText(
                              "skip".tr,
                              style: TextStyle(
                                fontSize: 45.sp,
                                fontFamily: "medium",
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  if (_currentPage == 2) SizedBox(height: 120.h, width: 200.w),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 110.w),
                    child: AutoSizeText(
                      textts[_currentPage],
                      style: TextStyle(
                        fontSize: 75.sp,
                        fontFamily: "Bold",
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.start,
                    ),
                  ),
                  Spacer(),
                  Column(
                    children: [
                      if (_currentPage == 2)
                        Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: 110.w,
                            vertical: 65.h,
                          ),
                          child: AutoSizeText(
                            "All captures stored in your private gallery with maps, AI stories & instant sharing"
                                .tr,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white,
                              fontFamily: "medium",
                              fontSize: 55.sp,
                            ),
                          ),
                        ),

                      if (_currentPage == 0)
                        Padding(
                          padding: EdgeInsets.only(right: 20.w),
                          child: AutoSizeText(
                            "Swipe to discover".tr,
                            style: TextStyle(
                              color: Colors.white,
                              fontFamily: "medium",
                              fontSize: 40.sp,
                            ),
                          ),
                        ),

                      if (_currentPage >= 1)
                        PressUnpress(
                          onTap: () async {
                            if (_currentPage < _pages.length - 1) {
                              setState(() {
                                _currentPage++;
                                _pageController.animateToPage(
                                  _currentPage,
                                  duration: const Duration(milliseconds: 500),
                                  curve: Curves.easeInOut,
                                );
                              });
                            } else {
                              SharedPreferencesService.setUser("username");
                              CheckPurchasesStatus.initPlatformState().then((
                                value,
                              ) async {
                                if (value) {
                                 Get.offAll(
                                          const Homescreennew(),
                                          transition: Transition.fadeIn,
                                        );

                                } else {
                                  Get.offAll(
                                          const UpsellScreen(item: false),
                                          transition: Transition.fadeIn,
                                        );
                                }
                              });
                            }
                          },
                          height: 200.h,
                          width: 950.w,
                          pressColor: Color(0xff8deaf3),
                          unPressColor: Color(0xff0fdff2),
                          // pressLinearGradient: pressLinearGradiant,
                          // unPressLinearGradient: unPressLinearGradiant,
                          child: Center(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                AutoSizeText(
                                  _currentPage == 1
                                      ? "Continue".tr
                                      : "Get Started".tr,
                                  style: TextStyle(
                                    fontSize: 67.sp,
                                    fontFamily: "medium",
                                    color: _currentPage == 1
                                        ? Colors.black
                                        : Colors.black,
                                  ),
                                ),
                                15.horizontalSpace,
                                if (_currentPage == 1)
                                  Icon(
                                    Icons.arrow_forward_sharp,
                                    color: Colors.black,
                                  ),
                              ],
                            ),
                          ),
                        ),

                      Align(
                        alignment: Alignment.bottomCenter,
                        child: Padding(
                          padding: EdgeInsets.only(top: 60.h, left: 20.w),
                          child: SmoothPageIndicator(
                            controller: _pageController, // PageController
                            count: 3,

                            effect: ExpandingDotsEffect(
                              dotColor: Colors.grey.withOpacity(0.6),
                              activeDotColor: Color(0xff01B39B),
                              dotHeight: 25.h,
                              dotWidth: 40.w,
                            ), // your preferred effect
                            onDotClicked: (index) {},
                          ),
                        ),
                      ),
                    ],
                  ),
                  180.verticalSpace,
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}

class OnboardingPage extends StatelessWidget {
  final String imagePath1;

  var height;
  var width;

  OnboardingPage({
    super.key,
    required this.imagePath1,
    required this.width,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      imagePath1,
      height: height,
      width: width,
      fit: BoxFit.contain,
      alignment: Alignment.topCenter,
    );
  }
}
