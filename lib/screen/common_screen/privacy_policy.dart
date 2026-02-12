import 'package:snap_journey/configuration/FirebaseAnalyticsService.dart';
import 'package:snap_journey/screen/common_screen/constant.dart';
import 'package:snap_journey/service/press_unpress.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:auto_size_text/auto_size_text.dart';

class PrivacyPolicy extends StatefulWidget {
  const PrivacyPolicy({super.key});

  @override
  State<PrivacyPolicy> createState() => _PrivacyPolicyState();
}

class _PrivacyPolicyState extends State<PrivacyPolicy> {
  late WebViewController controller;

  @override
  void initState() {
    controller = WebViewController()..loadRequest(Uri.parse(privacyPolicyUrl));

    FirebaseAnalyticsService.logEvent(
      eventName: "Snap_Journey_Privacy_Policy_Screen",
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        forceMaterialTransparency: true,
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        centerTitle: true,
        leading: Padding(
          padding: const EdgeInsets.only(top: 10, bottom: 10),
          child: PressUnpress(
            onTap: () {
              Get.back();
            },
            height: 100.h,
            width: 100.w,
            imageAssetPress: 'assets/home_screen/back_arrow_click.png',
            imageAssetUnPress: 'assets/home_screen/back_arrow.png',
          ),
        ),
        title: AutoSizeText(
          'Privacy Policy'.tr,
          style: TextStyle(
            color: Colors.black,
            fontSize: 60.sp,
            fontFamily: fontFamilySemiBold,
          ),
        ),
      ),
      body: SafeArea(
        child: Container(
          height: 2688.h,
          width: 1242.w,
          color: textColor,
          child: WebViewWidget(controller: controller),
        ),
      ),
    );
  }
}
