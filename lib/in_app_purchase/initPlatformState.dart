import 'package:snap_journey/in_app_purchase/app.dart';
import 'package:snap_journey/in_app_purchase/constant.dart';
import 'package:snap_journey/screen/common_screen/constant.dart';
import 'package:snap_journey/service/checkConnectivity.dart';
import 'package:snap_journey/service/dialog.dart';
import 'package:snap_journey/service/possessing_dialog.dart';
import 'package:snap_journey/service/press_unpress.dart';
import 'package:snap_journey/service/sharedPreferencesService.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:snap_journey/google_ads_material/ads_variable.dart';
import 'package:auto_size_text/auto_size_text.dart';

class CheckPurchasesStatus {
  static Future<bool> initPlatformState() async {
    try {
      final customerInfo = await Purchases.getCustomerInfo();
      if (customerInfo.entitlements.all[entitlementKey] != null &&
          customerInfo.entitlements.all[entitlementKey]!.isActive == true) {
        if (customerInfo.allPurchasedProductIdentifiers.contains(planOne) ||
            customerInfo.allPurchasedProductIdentifiers.contains(planTwo)) {
          AdsVariable.isPurchase.value = true;

          AdsVariable.fullscreen_preload_high = '11';
          AdsVariable.fullscreen_preload_normal = '11';
          AdsVariable.fullscreen_splash_screen_high = '11';
          AdsVariable.fullscreen_splash_screen_normal = '11';
          AdsVariable.fullscreen_in_app_screen = '11';
          AdsVariable.fullscreen_map_screen = '11';
          AdsVariable.fullscreen_memories_screen = '11';
          AdsVariable.fullscreen_timeline_screen = '11';
          AdsVariable.fullscreen_edit_screen = '11';
          AdsVariable.fullscreen_tagStyle_screen = '11';

          AdsVariable.banner_tagStyle_screen = '11';
          AdsVariable.banner_memories_screen = '11';
          AdsVariable.banner_map_screen = '11';
          AdsVariable.banner_img_preview_screen = '11';

          AdsVariable.big_native_intro_screen = '11';

          AdsVariable.appopen = '11';

          return true;
        } else {
          return false;
        }
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  static void checkPurchaseCredit({
    required VoidCallback onTap,
    required int cutAddCredit,
    required String buyPurchaseText,
    required String buyCreditText,
  }) {
    ConnectivityService.checkConnectivity().then((value) {
      if (value) {
        initPlatformState().then((value) async {
          if (value || AdsVariable.without_subscription == '1') {
            SharedPreferencesService.getCreditValue('Credit').then((value) {
              if (value >= cutAddCredit) {
                onTap();
              } else {
                showBuyCreditDialog(
                  onTap: onTap,
                  cutAddCredit: cutAddCredit,
                  bodyText: buyCreditText,
                );
              }
            });
          } else {
            showBuyPurchaseDialog(
              onTap: onTap,
              cutAddCredit: cutAddCredit,
              bodyText: buyPurchaseText,
            );
          }
        });
      } else {
        DialogService.showCheckConnectivity(Get.context!);
      }
    });
  }

  static void showBuyPurchaseDialog({
    required VoidCallback onTap,
    required int cutAddCredit,
    required String bodyText,
  }) async {
    showDialog(
      context: Get.context!,
      barrierDismissible: false,
      builder: (context) {
        return Dialog.fullscreen(
          backgroundColor: Colors.transparent,
          child: Center(
            child: Container(
              width: 1080.w,
              height: 645.w,
              decoration: BoxDecoration(
                color: Color(0xff1D2031),
                borderRadius: BorderRadius.circular(60.w),
                border: Border.all(color: Color(0xff2F3248)),
              ),
              alignment: Alignment.center,
              padding: EdgeInsets.symmetric(horizontal: 50.w),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  50.verticalSpace,
                  Row(
                    children: [
                      80.horizontalSpace,
                      Expanded(
                        child: AutoSizeText(
                          'Subscribe Plan',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: textColor,
                            fontSize: 60.sp,
                            fontFamily: fontFamilySemiBold,
                          ),
                        ),
                      ),
                      PressUnpress(
                        width: 85.w,
                        height: 85.w,
                        onTap: () {
                          Get.back();
                        },
                        imageAssetUnPress: "assets/inapp/close_unpress.png",
                        imageAssetPress: "assets/inapp/close_press.png",
                      ).marginOnly(bottom: 50.h),
                    ],
                  ),
                  AutoSizeText(
                    bodyText,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(0xff6B6B6B),
                      fontSize: 45.w,
                      decoration: TextDecoration.none,
                      fontFamily: fontFamilyRegular,
                    ),
                  ),
                  60.verticalSpace,
                  PressUnpress(
                    width: 560.w,
                    height: 130.h,
                    onTap: () {
                      Get.back();
                      Get.to(
                        const UpsellScreen(item: true),
                        transition: Transition.fadeIn,
                      )?.then((value) {
                        goWebView(onTap, cutAddCredit);
                      });
                    },
                    pressLinearGradient: pressLinearGradiant,
                    unPressLinearGradient: unPressLinearGradiant,
                    alignment: Alignment.center,
                    child: AutoSizeText(
                      'Subscribe Now',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 50.sp,
                        fontFamily: fontFamilyMedium,
                      ),
                    ),
                  ),
                  100.verticalSpace,
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  static void showBuyCreditDialog({
    required VoidCallback onTap,
    required int cutAddCredit,
    required String bodyText,
  }) {
    showDialog(
      context: Get.context!,
      barrierDismissible: false,
      builder: (context) {
        return Dialog.fullscreen(
          backgroundColor: Colors.transparent,
          child: Center(
            child: Container(
              width: 1080.w,
              height: 675.w,
              decoration: BoxDecoration(
                color: Color(0xff1D2031),
                borderRadius: BorderRadius.circular(60.w),
                border: Border.all(color: Color(0xff2F3248)),
              ),
              alignment: Alignment.center,
              padding: EdgeInsets.symmetric(horizontal: 50.w),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  50.verticalSpace,
                  Row(
                    children: [
                      80.horizontalSpace,
                      Expanded(
                        child: AutoSizeText(
                          'Insufficient Credit',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: textColor,
                            fontSize: 60.sp,
                            fontFamily: fontFamilySemiBold,
                          ),
                        ),
                      ),
                      PressUnpress(
                        width: 85.w,
                        height: 85.w,
                        onTap: () {
                          Get.back();
                        },
                        imageAssetUnPress: "assets/inapp/close_unpress.png",
                        imageAssetPress: "assets/inapp/close_press.png",
                      ).marginOnly(bottom: 50.h),
                    ],
                  ),
                  AutoSizeText(
                    bodyText,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(0xff6B6B6B),
                      fontSize: 45.w,
                      decoration: TextDecoration.none,
                      fontFamily: fontFamilyRegular,
                    ),
                  ),
                  60.verticalSpace,
                  PressUnpress(
                    width: 560.w,
                    height: 130.h,
                    onTap: () {
                      Get.back();
                      Get.to(
                        const UpsellScreen(item: true),
                        transition: Transition.fadeIn,
                      )?.then((value) {
                        goWebView(onTap, cutAddCredit);
                      });
                    },
                    pressLinearGradient: pressLinearGradiant,
                    unPressLinearGradient: unPressLinearGradiant,
                    alignment: Alignment.center,
                    child: AutoSizeText(
                      'Buy Now',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 50.sp,
                        fontFamily: fontFamilySemiBold,
                      ),
                    ),
                  ),
                  100.verticalSpace,
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  static void goWebView(VoidCallback onTap, int cutAddCredit) async {
    ProgressDialog.show2('');
    await Future.delayed(const Duration(seconds: 1));
    ProgressDialog.dismiss2();
    if (AdsVariable.isPurchase.value) {
      SharedPreferencesService.getCreditValue('Credit').then((value) {
        if (value >= cutAddCredit) {
          onTap();
        }
        // else {
        // showPurchasesDialog();
        // }
      });
    }
  }
}
