import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:path/path.dart' as path;
import 'package:snap_journey/configuration/FirebaseAnalyticsService.dart';
import 'package:snap_journey/controller/MomentsController.dart';
import 'package:snap_journey/google_ads_material/InterstitialAdUtil.dart';
import 'package:snap_journey/google_ads_material/ads_variable.dart';
import 'package:snap_journey/google_ads_material/banner_widget.dart';
import 'package:snap_journey/model/moment.dart';
import 'package:snap_journey/screen/ImagePreviewScreen.dart';
import 'package:snap_journey/screen/VideoPreviewScreen.dart';
import 'package:snap_journey/screen/common_screen/constant.dart';
import 'package:snap_journey/service/StorageService.dart';
import 'package:snap_journey/service/press_unpress.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'package:auto_size_text/auto_size_text.dart';

class MemoriesScreen extends StatefulWidget {
  const MemoriesScreen({super.key});

  @override
  State<MemoriesScreen> createState() => _MemoriesScreenState();
}

class _MemoriesScreenState extends State<MemoriesScreen> {
  final controller = Get.find<MomentsController>();

  final Map<String, String> _videoThumbCache = {};

  static String? _thumbDir;

  @override
  void initState() {
    super.initState();
    FirebaseAnalyticsService.logEvent(
      eventName: "Snap_Journey_Memories_Screen",
    );
    _initThumbnailDir();
    _preloadVideoThumbnails();
  }

  Future<void> _initThumbnailDir() async {
    final dir = await StorageService.getMomentsDirectory();
    final thumbDir = Directory(path.join(dir, 'thumbnails'));
    if (!await thumbDir.exists()) {
      await thumbDir.create(recursive: true);
    }
    _thumbDir = thumbDir.path;
  }

  Future<void> _preloadVideoThumbnails() async {
    final videoMoments = controller.displayedMoments
        .where((m) => m.videoPaths.isNotEmpty)
        .toList();

    for (var m in videoMoments) {
      for (var relativePath in m.videoPaths) {
        if (_videoThumbCache.containsKey(relativePath)) continue;

        final thumbPath = await _generateThumbnail(relativePath);
        if (thumbPath != null) {
          _videoThumbCache[relativePath] = thumbPath;
        }
      }
    }

    if (mounted) setState(() {});
  }

  Future<String?> _generateThumbnail(String relativeVideoPath) async {
    try {
      final fullVideoPath = await StorageService.getFullPath(relativeVideoPath);
      final videoFile = File(fullVideoPath);
      if (!await videoFile.exists()) return null;

      final videoFileName = path.basenameWithoutExtension(relativeVideoPath);
      final thumbFileName = '${videoFileName}_thumb.png';
      final thumbPath = path.join(_thumbDir!, thumbFileName);

      if (await File(thumbPath).exists()) return thumbPath;

      final generatedPath = await VideoThumbnail.thumbnailFile(
        video: fullVideoPath,
        thumbnailPath: _thumbDir!,
        imageFormat: ImageFormat.PNG,
        maxHeight: 400,
        quality: 80,
      );

      if (generatedPath != null && await File(generatedPath).exists()) {
        await File(generatedPath).rename(thumbPath);
        return thumbPath;
      }

      return null;
    } catch (e, s) {
      debugPrint('Thumbnail generation failed: $e\n$s');
      return null;
    }
  }

  void back(BuildContext context) {
    InterstitialAdManager.showInterstitial(
      onAdDismissed: () => Get.back(),
      id: AdsVariable.fullscreen_memories_screen,
      isContinue: AdsVariable.memories_screen_ad_continue_ads_online,
      flag: AdsVariable.memoriesFlag,
      context: context,
    );
    AdsVariable.memoriesFlag++;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        forceMaterialTransparency: true,
        backgroundColor: Colors.transparent,
        automaticallyImplyLeading: false,
        centerTitle: true,
        leading:
        //
        // PressUnpress(
        //   onTap: () => back(context),
        //   height: 100.h,
        //   width: 100.w,
        //   imageAssetPress: 'assets/home_screen/back_arrow_click.png',
        //   imageAssetUnPress: 'assets/home_screen/back_arrow.png',
        // ).marginOnly(left: 40.w, top: 20.h),


        Padding(
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

        title: AutoSizeText(
          'Memories'.tr,
          style: TextStyle(
            color: Colors.black,
            fontSize: 70.sp,
            fontFamily: fontFamilySemiBold,
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
          ),
          child: SafeArea(
            child: Column(
              children: [
      Expanded(child: _buildMediaTab(controller)),
                Obx(
                  () => AdsVariable.isPurchase.isFalse
                      ? BannerTemplate(
                          bannerId: AdsVariable.banner_memories_screen,
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

  Widget _tabButton({
    required String label,
    required String selectedIcon,
    required String unselectedIcon,
  }) {
    return Expanded(
      child: Image.asset(
        selectedIcon,
        width: 549.w,
        height: 160.h,
        fit: BoxFit.contain,
      ),
    );
  }

  Widget _buildMediaTab(MomentsController ctrl) {
    return Obx(() {
      final mediaMoments = ctrl.displayedMoments
          .where((m) => m.hasMedia && !m.isNote)
          .toList();

      if (mediaMoments.isEmpty) return _emptyState('No memories yet...');

      final grouped = <DateTime, List<Moment>>{};
      for (var m in mediaMoments) {
        final day = DateTime(m.date.year, m.date.month, m.date.day);
        grouped.putIfAbsent(day, () => []).add(m);
      }
      final sortedDates = grouped.keys.toList()..sort((a, b) => b.compareTo(a));

      return ListView.builder(
        padding: EdgeInsets.all(40.w),
        itemCount: sortedDates.length,
        itemBuilder: (context, i) {
          final date = sortedDates[i];
          final dayMoments = grouped[date]!
            ..sort((a, b) => b.date.compareTo(a.date));
          final dateStr =
              '${date.day} ${_getMonthName(date.month)}, ${date.year}';

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _dateHeader(dateStr, dayMoments.length),
              30.verticalSpace,
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.85,
                  crossAxisSpacing: 30.w,
                  mainAxisSpacing: 30.w,
                ),
                itemCount: dayMoments.length,
                itemBuilder: (_, j) => _buildMediaCard(dayMoments[j]),
              ),
              SizedBox(height: 40.h),
            ],
          );
        },
      );
    });
  }

  Widget _dateHeader(String date, int count) {
    return Center(
      child: Container(
        width: 1140.w,
        height: 170.h,
        padding: EdgeInsets.symmetric(horizontal: 40.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: Color(0xff1F232F),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Color(0xff535353), width: 2.w),
        ),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: appColor.withOpacity(0.4),
              child: Center(
                child: IconButton(
                  onPressed: () {
                    back(context);                    },
                  icon: Icon(Icons.calendar_month, color: Colors.white),
                ),
              ),
            ),
            30.horizontalSpace,
            AutoSizeText(
              date,
              style: TextStyle(
                fontFamily: fontFamilyBold,
                fontSize: 50.sp,
                color: Colors.white,
              ),
            ),
            const Spacer(),
            AutoSizeText(
              '$count Memories',
              style: TextStyle(
                fontSize: 50.sp,
                color: Colors.white,
                fontFamily: fontFamilySemiBold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMediaCard(Moment moment) {
    final isVideo = moment.videoPaths.isNotEmpty;
    final relativePath = isVideo
        ? moment.videoPaths.first
        : moment.photoPaths.first;

    return GestureDetector(
      onTap: () {
        if (isVideo) {
          Get.to(() => VideoPreviewScreen(moment: moment));
        } else {
          Get.to(() => ImagePreviewScreen(moment: moment));
        }
      },
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 20.h, horizontal: 10.w),
        decoration: BoxDecoration(
          color: Colors.grey[900],
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.4),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          fit: StackFit.expand,
          children: [
            _buildMediaContent(relativePath, isVideo),
            if (isVideo)
              Center(
                child: Icon(
                  Icons.play_circle_fill,
                  color: Colors.white.withOpacity(0.9),
                  size: 120.r,
                ),
              ),
            if (moment.caption?.isNotEmpty ?? false)
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  alignment: Alignment.center,
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.transparent, Colors.black87],
                    ),
                  ),
                  child: AutoSizeText(
                    moment.caption!,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 50.sp,
                      fontFamily: fontFamilySemiBold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            if (moment.hasLocation)
              Positioned(
                top: 20.r,
                right: 20.r,
                child: PressUnpress(
                  width: 90.w,
                  height: 90.h,
                  onTap: () {},
                  imageAssetUnPress: "assets/home_screen/location_btn.png",
                  imageAssetPress: "assets/home_screen/location_btn_click.png",
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildMediaContent(String relativePath, bool isVideo) {
    return FutureBuilder<String>(
      future: StorageService.getFullPath(relativePath),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return _placeholder();
        final fullPath = snapshot.data!;
        final file = File(fullPath);
        if (!file.existsSync()) return _placeholder();

        if (!isVideo) {
          return Image.file(file, fit: BoxFit.cover);
        }

        final thumbPath = _videoThumbCache[relativePath];
        if (thumbPath != null && File(thumbPath).existsSync()) {
          return Image.file(File(thumbPath), fit: BoxFit.cover);
        }

        return FutureBuilder<String?>(
          future: _generateThumbnail(relativePath),
          builder: (context, thumbSnapshot) {
            if (thumbSnapshot.hasData &&
                File(thumbSnapshot.data!).existsSync()) {
              final path = thumbSnapshot.data!;
              _videoThumbCache[relativePath] = path;
              return Image.file(File(path), fit: BoxFit.cover);
            }
            return _placeholder();
          },
        );
      },
    );
  }

  Widget _placeholder() {
    return Container(
      color: Colors.grey[800],
      child: Icon(Icons.broken_image, color: Colors.grey, size: 60.r),
    );
  }

  Widget _emptyState(String text) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            "assets/memories_screen/img.png",
            width: 850.w,
            height: 754.h,
          ),
          SizedBox(height: 40.h),
          AutoSizeText(
            text,
            style: TextStyle(
              color: Color(0xff4B536B),
              fontSize: 60.sp,
              fontFamily: fontFamilySemiBold,
            ),
          ),
        ],
      ),
    );
  }

  String _getMonthName(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return months[month - 1];
  }
}
