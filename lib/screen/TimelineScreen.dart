import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:snap_journey/configuration/FirebaseAnalyticsService.dart';
import 'package:snap_journey/controller/MomentsController.dart';
import 'package:snap_journey/google_ads_material/InterstitialAdUtil.dart';
import 'package:snap_journey/google_ads_material/ads_variable.dart';
import 'package:snap_journey/screen/CustomTimelineTile.dart';
import 'package:snap_journey/screen/common_screen/constant.dart';
import 'package:snap_journey/service/press_unpress.dart';
import 'package:auto_size_text/auto_size_text.dart';

class TimelineScreen extends StatefulWidget {
  const TimelineScreen({super.key});

  @override
  State<TimelineScreen> createState() => _TimelineScreenState();
}

class _TimelineScreenState extends State<TimelineScreen>
    with WidgetsBindingObserver {
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    FirebaseAnalyticsService.logEvent(
      eventName: "Snap_Journey_Timeline_Screen",
    );
    WidgetsBinding.instance.addObserver(this);
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);

    final controller = Get.find<MomentsController>();
    controller.loadMoments();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      final controller = Get.find<MomentsController>();
      controller.loadMoments();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);

    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      Get.find<MomentsController>().loadMoreGroups();
    }
  }

  void _showThemePopup(
      BuildContext context,
      MomentsController controller,
      Offset position,
      ) {
    final overlay = Overlay.of(context).context.findRenderObject() as RenderBox;

    final screenWidth = overlay.size.width;
    final double popupWidth = 750.w;

    final double rightOffset = screenWidth - position.dx - 120.w;
    final double topOffset = position.dy + 10;

    final RelativeRect positionRect = RelativeRect.fromLTRB(
      screenWidth - popupWidth - rightOffset,
      topOffset,
      rightOffset,
      0,
    );

    showMenu(
      context: context,
      position: positionRect,
      color: const Color(0xff1F232F),
      constraints: BoxConstraints(maxWidth: popupWidth),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      items: [
        PopupMenuItem(
          enabled: false,
          padding: EdgeInsets.zero,
          child: Container(
            width: popupWidth,
            padding: EdgeInsets.symmetric(horizontal: 40.w ),
            // margin: EdgeInsets.symmetric(
            //   horizontal:30.w,
            // ),
            decoration: BoxDecoration(
              color: const Color(0xff1F232F),
              borderRadius: BorderRadius.circular(20),
              // border: Border.all(color: const Color(0xff535353), width: 2),
            ),
            child: Obx(() {
              final selectedColor =
              TimelineColors.colors[controller.selectedColorIndex.value];
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AutoSizeText(
                    'Timeline Theme Color'.tr,
                    style: TextStyle(
                      color: Colors.white,
                      fontFamily: fontFamilySemiBold,
                      fontSize: 50.sp,
                    ),
                  ),
                  20.verticalSpace,
                  SizedBox(
                    height: 150.w,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: TimelineColors.colors.length,
                      padding: EdgeInsets.symmetric(horizontal: 12.w),
                      itemBuilder: (context, index) {
                        final color = TimelineColors.colors[index];
                        final isSelected =
                            controller.selectedColorIndex.value == index;
                        return GestureDetector(
                          onTap: () {
                            controller.selectedColorIndex.value = index;
                            Navigator.pop(context);
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            margin: EdgeInsets.symmetric(
                              horizontal: 10.w,
                              vertical: 10.h,
                            ),
                            width: isSelected ? 100.w : 90.w,
                            height: isSelected ? 100.w : 90.w,
                            decoration: BoxDecoration(
                              color: color,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isSelected
                                    ? Colors.white
                                    : Colors.transparent,
                                width: 2.w,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: color.withOpacity(
                                    isSelected ? 0.6 : 0.2,
                                  ),
                                  blurRadius: isSelected ? 10 : 4,
                                  spreadRadius: isSelected ? 2 : 0,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              );
            }),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<MomentsController>();

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.white,
      appBar: AppBar(
        forceMaterialTransparency: true,
        backgroundColor: Colors.transparent,
        automaticallyImplyLeading: false,
        surfaceTintColor: Colors.transparent,
        centerTitle: true,
        leading:  Padding(
          padding: const EdgeInsets.all(8.0),
          child:
          CircleAvatar(
            backgroundColor: Colors.black.withOpacity(0.4),
            child: Padding(
              padding: EdgeInsets.only(left: 10.w),
              child: Center(
                child: IconButton(
                  onPressed: () {
                    back(context);                    },
                  icon: Icon(Icons.arrow_back_ios, color: Colors.white),
                ),
              ),
            ),
          ),
        ),
        // PressUnpress(
        //   onTap: () {
        //
        //   },
        //   height: 100.h,
        //   width: 100.w,
        //   imageAssetPress: 'assets/home_screen/back_arrow_click.png',
        //   imageAssetUnPress: 'assets/home_screen/back_arrow.png',
        // ).marginOnly(left: 40.w, top: 20.h),
        title: AutoSizeText(
          'Timeline'.tr,
          style: TextStyle(
            color: Colors.black,
            fontSize: 70.sp,
            fontFamily: fontFamilySemiBold,
          ),
        ),
        actions: [

          GestureDetector(
            onTapDown: (details) {
              final position = details.globalPosition;
              _showThemePopup(context, controller, position);
            },
            child: Padding(
              padding:  EdgeInsets.only(right: 30.w),
              child: CircleAvatar(
                backgroundColor: Colors.grey.withOpacity(0.4),
                child: Center(
                  child: Obx(

                      () {
                        return Icon(Icons.color_lens,
                            color: TimelineColors.colors[controller
                                .selectedColorIndex.value]);
                      }
                  ))))
            ),
        ],

        bottom: PreferredSize(
          preferredSize: Size.fromHeight(240.h),
          child: Obx(() {
            final selectedColor =
            TimelineColors.colors[controller.selectedColorIndex.value];
            return Padding(
              padding: EdgeInsets.only(bottom: 10.h,left: 20.w,right: 30.w),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.transparent,
                        border: Border.all(
                          width: 1.w,
                          color: const Color(0xff535353),
                        ),
                        borderRadius: BorderRadius.circular(40),

                      ),
                      padding: EdgeInsets.symmetric( horizontal: 30.w,vertical: 15.h),
                      child: Row(
                        children: [
                          _buildSegment(
                            label: "All",
                            value: "all",
                            controller: controller,
                            selectedColor: selectedColor,
                          ),
                          _buildSegment(
                            label: "7 Days",
                            value: "7days",
                            controller: controller,
                            selectedColor: selectedColor,
                          ),
                          _buildSegment(
                            label: "Month",
                            value: "month",
                            controller: controller,
                            selectedColor: selectedColor,
                          ),
                        ],
                      ),
                    ),
                  ),
                  30.horizontalSpace,

                  CircleAvatar(
                    backgroundColor: Colors.grey.withOpacity(0.4),
                    child: Padding(
                      padding: EdgeInsets.only(left: 10.w),
                      child: Center(
                        child: IconButton(
                          onPressed: () {
                            // back(context);
                            _showDatePicker(controller);
                            },
                          icon: Obx(
                            () {
                              return  Icon(Icons.calendar_month, color: TimelineColors.colors[controller
                                  .selectedColorIndex.value],size: 20,);
                            }
                          ),
                        ),
                      ),
                    ),
                  ),
                  // PressUnpress(
                  //   onTap: () => _showDatePicker(controller),
                  //   height: 120.h,
                  //   width: 120.w,
                  //   imageAssetPress:
                  //   'assets/timeline_screen/calender_btn_click.png',
                  //   imageAssetUnPress:
                  //   'assets/timeline_screen/calender_btn.png',
                  // ).marginOnly(right: 40.w),
                ],
              ),
            );
          }),
        ),


      ),
      body: WillPopScope(
        onWillPop: () async {
          back(context);
          return false;
        },
        child: SafeArea(
          child: Obx(() {
            final color =
            TimelineColors.colors[controller.selectedColorIndex.value];
            return Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: const Alignment(-0.5, -0.5),
                  colors: [Colors.white, color.withOpacity(0.05), Colors.white],
                ),
              ),
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  );
                }
                if (controller.groups.isEmpty) {
                  return Center(
                    child: Image.asset(
                      "assets/timeline_screen/img.png",
                      width: 439.w,
                      height: 489.h,
                    ),
                  );
                }

                final displayed = controller.displayedGroups;
                final hasMore = displayed.length < controller.groups.length;

                return ListView.builder(
                  controller: _scrollController,
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.only(top: 20, bottom: 40),
                  itemCount: displayed.length + (hasMore ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index < displayed.length) {
                      final group = displayed[index];
                      final isLeft = index % 2 == 0;
                      return CustomTimelineTile(
                        group: group,
                        isFirst: index == 0,
                        isLast: index == displayed.length - 1 && !hasMore,
                        isLeft: isLeft,
                        index: index,
                        onDelete: () => controller.deleteGroup(group),
                      );
                    }
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 32),
                      child: Center(
                        child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                );
              }),
            );
          }),
        ),
      ),
    );
  }

  void back(BuildContext context) {
    InterstitialAdManager.showInterstitial(
      onAdDismissed: () {
        Get.back();
      },
      id: AdsVariable.fullscreen_timeline_screen,
      isContinue: AdsVariable.timeline_config_screen_ad_continue_ads_online,
      flag: AdsVariable.timelineFlag,
      context: context,
    );

    AdsVariable.timelineFlag++;
  }

  Widget _buildSegment({
    required String label,
    required String value,
    required controller,
    required Color selectedColor,
  }) {
    final bool isSelected = controller.filterMode.value == value;
    return Expanded(
      child: GestureDetector(
        onTap: () => controller.setFilterMode(value),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: EdgeInsets.symmetric(vertical: 40.h),
          decoration: BoxDecoration(
            color: isSelected ? selectedColor : Colors.transparent,
            borderRadius: BorderRadius.circular(40),
          ),
          child: Center(
            child: AutoSizeText(
              label.tr,
              style: TextStyle(
                color: isSelected?Colors.white:Colors.black,
                fontFamily: fontFamilyMedium,
                fontSize: 50.sp,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _showDatePicker(MomentsController controller) async {
    final range = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: DateTimeRange(
        start:
        controller.fromDate.value ??
            DateTime.now().subtract(const Duration(days: 30)),
        end: controller.toDate.value ?? DateTime.now(),
      ),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            dialogBackgroundColor: const Color(0xFF1E222B),
            scaffoldBackgroundColor: Colors.black,
            colorScheme: ColorScheme.dark(
              primary: appColor,
              onPrimary: Colors.white,
              surface: const Color(0xFF1E222B),
              onSurface: Colors.white,
              secondary: appColor,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: appColor,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                textStyle: TextStyle(
                  fontFamily: fontFamilyMedium,
                  fontSize: 40.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            datePickerTheme: const DatePickerThemeData(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(16)),
              ),
              headerBackgroundColor: Color(0xFF2A2E38),
              headerForegroundColor: Colors.white,
              rangeSelectionBackgroundColor: appColor,
            ),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(32),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.white.withOpacity(0.08),
                      Colors.white.withOpacity(0.02),
                    ],
                  ),

                  backgroundBlendMode: BlendMode.overlay,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(32),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                    child: Container(
                      padding: EdgeInsets.all(30.w),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.4),
                        borderRadius: BorderRadius.circular(32),
                      ),
                      child: child!,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
    if (range != null) {
      controller.fromDate.value = range.start;
      controller.toDate.value = range.end;
      controller.setFilterMode('custom');
    }
  }
}

class TimelineColors {
  static const List<Color> colors = [
    Color(0xFF6366F1),
    Color(0xFFEC4899),
    Color(0xFF8B5CF6),
    Color(0xFF10B981),
    Color(0xFFF59E0B),
    Color(0xFFEF4444),
    Color(0xFF3B82F6),
    Color(0xFF14B8A6),
    Color(0xFFF97316),
    Color(0xFF06B6D4),
    Color(0xFFA855F7),
    Color(0xFF84CC16),
    Color(0xFFD946EF),
    Color(0xFF0EA5E9),
    Color(0xFF64748B),
  ];
}
