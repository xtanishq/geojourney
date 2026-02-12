import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:snap_journey/configuration/FirebaseAnalyticsService.dart';
import 'package:snap_journey/controller/TagStyleController.dart';
import 'package:snap_journey/google_ads_material/InterstitialAdUtil.dart';
import 'package:snap_journey/google_ads_material/ads_variable.dart';
import 'package:snap_journey/google_ads_material/banner_widget.dart';
import 'package:snap_journey/in_app_purchase/app.dart';
import 'package:snap_journey/model/TagStyle.dart';
import 'package:snap_journey/screen/common_screen/constant.dart';
import 'package:snap_journey/service/LocationCardWidget.dart';
import 'package:snap_journey/service/checkConnectivity.dart';
import 'package:snap_journey/service/dialog.dart';
import 'package:snap_journey/service/press_unpress.dart';
import 'package:snap_journey/service/sharedPreferencesService.dart';
import 'package:get/get.dart';
import 'package:auto_size_text/auto_size_text.dart';

class TagStyleScreen extends StatefulWidget {
  const TagStyleScreen({super.key});

  @override
  State<TagStyleScreen> createState() => _TagStyleScreenState();
}

class _TagStyleScreenState extends State<TagStyleScreen> {
  final TagStyleController provider = Get.find<TagStyleController>();

  void back(BuildContext context) {
    Get.back();
    // InterstitialAdManager.showInterstitial(
    //   onAdDismissed: () {
    //     Get.back();
    //   },
    //   id: AdsVariable.fullscreen_tagStyle_screen,
    //   isContinue: AdsVariable.tagStyle_screen_ad_continue_ads_online,
    //   flag: AdsVariable.tagStyleFlag,
    //   context: context,
    // );
    //
    // AdsVariable.tagStyleFlag++;
  }

  @override
  Widget build(BuildContext context) {
    FirebaseAnalyticsService.logEvent(
      eventName: "Snap_Journey_TagStyle_Screen",
    );
    return Scaffold(
      backgroundColor: appbackgroundColor,

      extendBodyBehindAppBar: true,
      appBar: AppBar(
        forceMaterialTransparency: true,
        backgroundColor: Colors.transparent,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: CircleAvatar(
            backgroundColor: Colors.black.withOpacity(0.4),
            child: Padding(
              padding: EdgeInsets.only(left: 10.w),
              child: Center(
                child: IconButton(
                  onPressed: () {
                    back(context);
                  },
                  icon: Icon(Icons.arrow_back_ios, color: Colors.white),
                ),
              ),
            ),
          ),
        ),

        centerTitle: true,
        title: AutoSizeText(
          'Tag Style'.tr,
          style: TextStyle(
            color: Colors.black,
            fontSize: 62.sp,
            fontFamily: "medium",
              fontWeight: FontWeight.w700
          ),
        ),
      ),
      body: WillPopScope(
        onWillPop: () async {
          back(context);
          return false;
        },
        child: Container(
          width: 1242.w,
          height: 2688.h,
          decoration: const BoxDecoration(
            color: Colors.white
            // image: DecorationImage(
            //   image: AssetImage('assets/setting_screen/bg.png'),
            //   fit: BoxFit.cover,
            // ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: GetBuilder<TagStyleController>(
                    init: provider,
                    builder: (tagProvider) => _buildStyleGrid(tagProvider),
                  ),
                ),

                Obx(
                  () => AdsVariable.isPurchase.isFalse
                      ? BannerTemplate(
                          bannerId: AdsVariable.banner_tagStyle_screen,
                        ).marginOnly(top: 40.h)
                      : const SizedBox.shrink(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStyleGrid(TagStyleController tagProvider) {
    final styles = tagProvider.styles;

    return
    GridView.builder(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 40.h,
        crossAxisSpacing: 40.w,

        childAspectRatio:
            1.65, // Height ko width se thoda zyada rakhein (Portrait feel)
      ),
      itemCount: styles.length,
      itemBuilder: (context, index) {
        final style = styles[index];
        return _buildStyleCard(style, tagProvider);
        // final style = controller.styles[index];
        // return TemplateItem(style: style, isSelected: ...);
      },
    );
  }

  Widget _buildStyleCard(TagStyle style, TagStyleController tagProvider) {
    final isSelected = style.id == tagProvider.selectedStyleId.value;

    return GestureDetector(
      onTap: () {
        tagProvider.selectStyle(style.id);
        Get.back();
      },
      child: Container(
        padding: EdgeInsets.all(12.w), // Thoda padding kam kiya for space
        decoration: BoxDecoration(
          color: const Color(0xff1E212A).withOpacity(0.4),
          borderRadius: BorderRadius.circular(20.r),
          border: isSelected
              ? Border.all(color: appColor, width: 8.w)
              : Border.all(color: Colors.white10, width: 1.w),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Header ---
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: AutoSizeText(
                    style.name ?? "Unnamed Style",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 30.sp, // Professional size
                      fontFamily: fontFamilySemiBold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (isSelected)
                  Icon(Icons.check_circle, color: appColor, size: 55.w,weight: 1,),
              ],
            ),
            SizedBox(height: 12.h),

            // --- Card Preview Section ---
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return Center(
                    child: FittedBox(
                      fit: BoxFit.contain,
                      // Content ko scale down karega wrap hone ke bajaye
                      child: SizedBox(
                        // Yahan hum card ki "Ideal" width define karenge
                        // taaki preview asli photo jaisa dikhe
                        width: 300,
                        child: LocationCardWidget(
                          locationText: "Sample Location\nNew York, NY",
                          style: style,
                          weatherInfo: style.showWeather ? "72°F" : null,
                          coordinates: style.showCoordinates
                              ? "40.7128° N, 74.0060° W"
                              : null,
                          timestamp: DateTime.now(),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
