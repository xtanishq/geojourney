import 'package:snap_journey/google_ads_material/ads_variable.dart';
import 'package:snap_journey/in_app_purchase/upsell_controller.dart';
import 'package:snap_journey/screen/common_screen/constant.dart';
import 'package:snap_journey/screen/common_screen/privacy_policy.dart';
import 'package:snap_journey/screen/common_screen/terms_screen.dart';
import 'package:snap_journey/service/press_unpress.dart';
import 'package:snap_journey/service/dialog.dart';
import 'package:snap_journey/in_app_purchase/constant.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:shimmer/shimmer.dart';
import 'package:zo_animated_border/widget/zo_dotted_border.dart';
import 'package:auto_size_text/auto_size_text.dart';

class UpsellScreen extends StatelessWidget {
  final bool item;
  final bool? isTester;

  const UpsellScreen({super.key, required this.item, this.isTester});

  @override
  Widget build(BuildContext context) {
    UpsellController upsellController = Get.put(UpsellController(item));
    print(upsellController.offerings.value);
    print(upsellController.availablePackages.length);
    print(upsellController.selectedPackage.value);
    return Scaffold(
      extendBodyBehindAppBar: true,

      backgroundColor: appbackgroundColor,
      appBar: AppBar(
        forceMaterialTransparency: true,

        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        actions: [
          Obx(
            () =>
                (upsellController.isClose.value ||
                    AdsVariable.show_close_delay == '0')
                ? Align(
                  alignment: AlignmentGeometry.topRight,
                  child: Padding(
                    padding:  EdgeInsets.only(right: 30.w),
                    child: Container(
                        width: 140.w,
                        height: 140.w,

                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.black.withOpacity(0.5),
                        ),
                        child: IconButton(
                          onPressed: () => upsellController.backToHome(context),
                          icon: Icon(Icons.close, color: Colors.white),
                        ),
                      ),
                  ),
                )
                : const SizedBox.shrink(),
          ),
        ],
      ),
      body: WillPopScope(
        onWillPop: () {
          upsellController.backToHome(context);
          return Future(() => false);
        },
        child: Container(
          width: 1242.w,
          height: 2688.h,
          alignment: Alignment.topCenter,

          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage("assets/premium_screen/bg.png"),
              fit: BoxFit.contain,
            ),
          ),
          child: Stack(
            alignment: Alignment.topCenter,
            children: [
              // Image.asset(
              //   "assets/premium_screen/img.png",
              //   width: 1242.w,
              //   height: 998.h,
              //   fit: BoxFit.fitWidth,
              // ),


              SafeArea(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Image.asset(
                    //   "assets/premium_screen/text.png",
                    //   width: 936.w,
                    //   height: 690.h,
                    // ),

                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        _PremiumTitle(),
                        SizedBox(height: 24),
                        _PremiumFeature(text: 'Unlimited overlays'.tr),
                        _PremiumFeature(text: 'AI descriptions'.tr),
                        _PremiumFeature(text: 'Ad-free experience'.tr),
                        _PremiumFeature(text: 'Custom styles & themes'.tr),
                        _PremiumFeature(text: 'Real-time weather data'.tr),
                      ],
                    ),


                    50.verticalSpace,
                    Obx(
                      () => upsellController.offerings.value != null
                          ? Column(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: upsellController.availablePackages.entries.take(2).map((
                                packageEntry,
                              ) {
                                print(
                                  packageEntry.value.storeProduct.identifier,
                                );
                                String priceValue = '';
                                double percentage = 0;
                                if (packageEntry
                                        .value
                                        .storeProduct
                                        .identifier ==
                                    planOne) {
                                  upsellController.originalWeekPrice =
                                      packageEntry.value.storeProduct.price;
                                  priceValue = packageEntry
                                      .value
                                      .storeProduct
                                      .priceString;
                                } else {
                                  if (AdsVariable.show_week_price == '1') {
                                    double weekPrice =
                                        packageEntry.value.storeProduct.price /
                                        52;
                                    priceValue =
                                        '${packageEntry.value.storeProduct.priceString.replaceAll(RegExp(r'[0-9.,]'), '').trim()} ${weekPrice.toStringAsFixed(2)}';
                                    percentage =
                                        100 -
                                        ((weekPrice * 100) /
                                            upsellController.originalWeekPrice);
                                  } else {
                                    priceValue = packageEntry
                                        .value
                                        .storeProduct
                                        .priceString;
                                  }
                                }
                                return SizedBox(
                                  width: 1110.w,
                                  height: 325.h,
                                  child: Stack(
                                    alignment: Alignment.bottomCenter,
                                    children: [
                                      GestureDetector(
                                        onTap: () {
                                          upsellController
                                                  .selectedPackage
                                                  .value =
                                              packageEntry.value;
                                        },
                                        child: ZoDottedBorder(
                                          borderRadius: 200.w,
                                          dashLength: 3,
                                          gapLength:
                                              upsellController
                                                      .selectedPackage
                                                      .value ==
                                                  packageEntry.value
                                              ? 3
                                              : 0,
                                          strokeWidth: 0.8,
                                          gradient:
                                              upsellController
                                                      .selectedPackage
                                                      .value ==
                                                  packageEntry.value
                                              ? unPressLinearGradiant
                                                    .withOpacity(0.9)
                                              : const LinearGradient(
                                                  colors: [
                                                    Color(0xff171717),
                                                    Color(0xff171717),
                                                  ],
                                                ),
                                          animationSpeed: 0,
                                          borderStyle: BorderStyleType.gradient,
                                          padding: const EdgeInsets.all(0),
                                          child: Container(
                                            width: 1110.w,
                                            height: 280.h,
                                            decoration: BoxDecoration(
                                              color:
                                                  upsellController
                                                          .selectedPackage
                                                          .value ==
                                                      packageEntry.value
                                                  ? null
                                                  : const Color(0xff101010),
                                              gradient:
                                                  upsellController
                                                          .selectedPackage
                                                          .value ==
                                                      packageEntry.value
                                                  ? unPressLinearGradiant
                                                        .withOpacity(0.2)
                                                  : null,
                                              borderRadius:
                                                  BorderRadius.circular(150.w),
                                            ),
                                            padding: EdgeInsets.symmetric(
                                              horizontal: 50.w,
                                            ),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: [
                                                20.horizontalSpace,
                                                CircleAvatar(
                                                  radius:
                                                      upsellController
                                                              .selectedPackage
                                                              .value ==
                                                          packageEntry.value
                                                      ? 9
                                                      : 7,
                                                  backgroundColor:
                                                      upsellController
                                                              .selectedPackage
                                                              .value ==
                                                          packageEntry.value
                                                      ? appColor
                                                      : const Color(0xff414141),
                                                ),
                                                50.horizontalSpace,
                                                Expanded(
                                                  child: Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      AutoSizeText(
                                                        packageEntry
                                                                    .value
                                                                    .storeProduct
                                                                    .identifier ==
                                                                planOne
                                                            ? 'Weekly Plan'
                                                            : 'Yearly Plan',
                                                        style: TextStyle(
                                                          color:
                                                              upsellController
                                                                      .selectedPackage
                                                                      .value ==
                                                                  packageEntry
                                                                      .value
                                                              ? Colors.white
                                                              : const Color(
                                                                  0xff6B6B6B,
                                                                ),
                                                          fontSize: 60.sp,
                                                          fontFamily:
                                                              fontFamilySemiBold,
                                                        ),
                                                      ),
                                                      10.verticalSpace,
                                                      AutoSizeText(
                                                        (packageEntry
                                                                        .value
                                                                        .storeProduct
                                                                        .identifier ==
                                                                    planOne ||
                                                                AdsVariable
                                                                        .show_week_price ==
                                                                    '1')
                                                            ? '$priceValue for a week'
                                                            : '$priceValue for a year',
                                                        style: TextStyle(
                                                          color:
                                                              upsellController
                                                                      .selectedPackage
                                                                      .value ==
                                                                  packageEntry
                                                                      .value
                                                              ? Colors.white
                                                              : const Color(
                                                                  0xff464646,
                                                                ),
                                                          fontSize: 48.sp,
                                                          fontFamily:
                                                              fontFamilyRegular,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                30.horizontalSpace,
                                                Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.end,
                                                  children: [
                                                    AutoSizeText(
                                                      packageEntry
                                                          .value
                                                          .storeProduct
                                                          .priceString,
                                                      style: TextStyle(
                                                        color:
                                                            upsellController
                                                                    .selectedPackage
                                                                    .value ==
                                                                packageEntry
                                                                    .value
                                                            ? Colors.white
                                                            : const Color(
                                                                0xff5F5F5F,
                                                              ),
                                                        fontSize: 60.sp,
                                                        fontFamily:
                                                            fontFamilyBold,
                                                      ),
                                                    ),
                                                    AutoSizeText(
                                                      packageEntry
                                                                  .value
                                                                  .storeProduct
                                                                  .identifier ==
                                                              planOne
                                                          ? 'Per Week'
                                                          : 'Per Year',
                                                      style: TextStyle(
                                                        color:
                                                            upsellController
                                                                    .selectedPackage
                                                                    .value ==
                                                                packageEntry
                                                                    .value
                                                            ? const Color(
                                                                0xff686868,
                                                              )
                                                            : const Color(
                                                                0xff5F5F5F,
                                                              ),
                                                        fontSize: 40.sp,
                                                        fontFamily:
                                                            fontFamilyRegular,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                      if (packageEntry
                                                  .value
                                                  .storeProduct
                                                  .identifier ==
                                              planTwo &&
                                          AdsVariable.show_week_price == '1')
                                        Positioned(
                                          top: 0,
                                          right: 60,
                                          child: Container(
                                            width: 230.w,
                                            height: 90.h,
                                            decoration: BoxDecoration(
                                              gradient: unPressLinearGradiant,
                                              borderRadius:
                                                  BorderRadius.circular(80.w),
                                            ),
                                            alignment: Alignment.center,
                                            child: AutoSizeText(
                                              '${percentage.toStringAsFixed(0)}% off',
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                color: const Color(0xffededed),
                                                fontSize: 40.sp,
                                                fontFamily: fontFamilySemiBold,
                                              ),
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                ).marginOnly(bottom: 30.h);
                              }).toList(),
                            )
                          : buildShimmer(),
                    ),
                    50.verticalSpace,
                    PressUnpress(
                      onTap: () {
                        upsellController.buySubscription(context);
                      },
                      height: 200.h,
                      width: 1100.w,
                      pressColor: pressColor,
                      unPressColor: unPressColor,

                      child: Center(

                        child: AutoSizeText("Continue".tr,style: TextStyle(
                          color: Colors.white,fontSize: 65.sp
                        ),),
                      ),
                      // imageAssetUnPress:
                      //     'assets/premium_screen/continue_btn.png',
                      // imageAssetPress:
                      //     'assets/premium_screen/continue_btn_click.png',
                    ),
                    privacy_Terms_of_us_restore(context),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }



  Widget buildSubtext(String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 32.w,
          height: 32.w,
          decoration: BoxDecoration(
            gradient: unPressLinearGradiant,
            shape: BoxShape.circle,
          ),
        ),
        20.horizontalSpace,
        AutoSizeText(
          text,
          style: TextStyle(
            color: textColor,
            fontSize: 45.sp,
            fontFamily: fontFamilyMedium,
          ),
        ),
      ],
    );
  }

  Row privacy_Terms_of_us_restore(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        20.horizontalSpace,
        TextButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const TermsOfUse()),
            );
          },
          child: AutoSizeText(
            "Terms of use",
            style: TextStyle(
              color: const Color(0xff767676),
              fontFamily: fontFamilyRegular,
              fontSize: 40.sp,
            ),
          ),
        ),
        TextButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const PrivacyPolicy()),
            );
          },
          child: AutoSizeText(
            "Privacy policy",
            style: TextStyle(
              color: const Color(0xff767676),
              fontFamily: fontFamilyRegular,
              fontSize: 40.sp,
            ),
          ),
        ),
        TextButton(
          onPressed: () async {
            DialogService.showLoading(context);
            try {
              final customerInfo = await Purchases.restorePurchases();
              // ignore: use_build_context_synchronously
              Navigator.pop(context);
              bool isActive =
                  customerInfo.entitlements.all[entitlementKey]?.isActive ??
                  false;
              if (kDebugMode) {
                print('isActive: $isActive');
              }
              if (!isActive) {
                // ignore: use_build_context_synchronously
                DialogService.restorePurchasesDialog(context);
              }
            } catch (e) {
              print('Exception during restore: $e');
              Navigator.pop(context);
            }
          },
          child: AutoSizeText(
            "Restore",
            style: TextStyle(
              color: const Color(0xff767676),
              fontFamily: fontFamilyRegular,
              fontSize: 40.sp,
            ),
          ),
        ),
        30.horizontalSpace,
      ],
    );
  }

  Shimmer buildShimmer() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[800]!,
      highlightColor: appColor,
      child: Column(
        children: List.generate(2, (index) {
          return Container(
            width: 1110.w,
            height: 250.h,
            margin: EdgeInsets.only(top: 50.w),
            padding: EdgeInsets.symmetric(horizontal: 50.w),
            decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xff131313)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Fake circle avatar
                Container(
                  width: 50.w,
                  height: 50.w,
                  decoration: const BoxDecoration(
                    color: textColor,
                    shape: BoxShape.circle,
                  ),
                ),

                50.horizontalSpace,
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 500.w,
                      height: 50.h,
                      decoration: BoxDecoration(
                        color: textColor,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      margin: EdgeInsets.only(bottom: 20.h),
                    ),
                    Container(
                      width: 350.w,
                      height: 40.h,
                      decoration: BoxDecoration(
                        color: textColor,
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                Container(
                  width: 200.w,
                  height: 100.h,
                  decoration: BoxDecoration(
                    color: textColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}

class GoPremiumCard extends StatelessWidget {
  const GoPremiumCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF0B1B2B), // deep navy
            Color(0xFF020A13), // near black
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          _PremiumTitle(),
          SizedBox(height: 24),
          _PremiumFeature(text: 'Unlimited overlays'),
          _PremiumFeature(text: 'AI descriptions'),
          _PremiumFeature(text: 'Ad-free experience'),
          _PremiumFeature(text: 'Custom styles & themes'),
          _PremiumFeature(text: 'Real-time weather data'),
        ],
      ),
    );
  }

}
class _PremiumTitle extends StatelessWidget {
  const _PremiumTitle();

  @override
  Widget build(BuildContext context) {
    return AutoSizeText(
      'Go Premium',
      style: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        color: Colors.white,
        shadows: [
          Shadow(
            color: Colors.white.withOpacity(0.4),
            blurRadius: 12,
          ),
        ],
      ),
    );
  }
}
class _PremiumFeature extends StatelessWidget {
  final String text;

  const _PremiumFeature({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:  EdgeInsets.only(left: 65.w,bottom: 30.h),
      child: Row(
        children: [
          Container(
            height: 22,
            width: 22,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: appColor, // teal dark
            ),
            child: const Icon(
              Icons.check,
              size: 14,
              color: Color(0xFFFFFFFF), // mint/teal
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: AutoSizeText(
              text,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.white70,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

