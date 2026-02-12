import 'package:snap_journey/configuration/FirebaseAnalyticsService.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:webview_flutter/webview_flutter.dart';

import 'constant.dart';
import '../../service/press_unpress.dart';
import 'package:auto_size_text/auto_size_text.dart';

class TermsOfUse extends StatefulWidget {
  const TermsOfUse({Key? key}) : super(key: key);

  @override
  State<TermsOfUse> createState() => _TermsOfUseState();
}

class _TermsOfUseState extends State<TermsOfUse> {
  late WebViewController controller;

  @override
  void initState() {
    controller = WebViewController()
      ..loadRequest(
        Uri.parse(termsOfUseUrl),
      );

    FirebaseAnalyticsService.logEvent(eventName: "Snap_Journey_Terms_Screen");
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.transparent,
        leading: Padding(
          padding: const EdgeInsets.only(left: 15.0, top: 15.0, bottom: 15.0),
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
          'Terms Of Use',
          style: TextStyle(
            color: Colors.black,
            fontSize: 70.sp,
            fontFamily: 'Regular',
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
