import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get/get_connect/http/src/utils/utils.dart';
import 'package:snap_journey/controller/MomentsController.dart';
import 'package:snap_journey/model/TimelineGroup.dart';
import 'package:snap_journey/model/moment.dart';
import 'package:snap_journey/screen/ImagePreviewScreen.dart';
import 'package:snap_journey/screen/TimelineScreen.dart';
import 'package:snap_journey/screen/VideoPreviewScreen.dart';
import 'package:snap_journey/screen/common_screen/constant.dart';
import 'package:snap_journey/service/StorageService.dart';
import 'package:snap_journey/service/press_unpress.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'package:visibility_detector/visibility_detector.dart';
import 'package:auto_size_text/auto_size_text.dart';

class CustomTimelineTile extends StatefulWidget {
  const CustomTimelineTile({
    super.key,
    required this.group,
    this.isFirst = false,
    this.isLast = false,
    required this.isLeft,
    required this.index,
    required this.onDelete,
  });

  final TimelineGroup group;
  final bool isFirst;
  final bool isLast;
  final bool isLeft;
  final int index;
  final VoidCallback onDelete;

  @override
  State<CustomTimelineTile> createState() => _CustomTimelineTileState();
}

class _CustomTimelineTileState extends State<CustomTimelineTile>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  final Map<String, Uint8List?> _thumbnailCache = {};

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _slideAnimation =
        Tween<Offset>(
          begin: Offset(widget.isLeft ? -0.4 : 0.4, 0.1),
          end: Offset.zero,
        ).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeOutCubic,
          ),
        );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeIn),
      ),
    );
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutBack),
    );

    // Pre-generate thumbnails
    _preloadThumbnails();
  }

  Future<void> _preloadThumbnails() async {
    final videoMoments =
        widget.group.moments
            .where((m) => m.mediaType == 'video' && m.videoPaths.isNotEmpty)
            .toList()
          ..sort((a, b) => b.date.compareTo(a.date))
          ..take(4);

    for (var m in videoMoments) {
      final path = m.videoPaths.first;
      if (_thumbnailCache.containsKey(path)) continue;

      try {
        final fullPath = await StorageService.getFullPath(path);
        final thumbnail = await VideoThumbnail.thumbnailData(
          video: fullPath,
          imageFormat: ImageFormat.JPEG,
          maxWidth: 600,
          quality: 75,
        );
        if (mounted) {
          setState(() => _thumbnailCache[path] = thumbnail);
        }
      } catch (e) {
        debugPrint('Thumbnail error for $path: $e');
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final MomentsController controller = Get.find();
    return VisibilityDetector(
      key: Key(widget.group.date.toIso8601String()),
      onVisibilityChanged: (info) {
        if (info.visibleFraction > 0.1 && !_animationController.isCompleted) {
          _animationController.forward();
        }
      },
      child: Obx(() {
        final primaryColor =
            TimelineColors.colors[controller.selectedColorIndex.value];
        return SlideTransition(
          position: _slideAnimation,
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: Padding(
                padding: EdgeInsets.only(left: 24.w, right: 24.w, bottom: 85.h),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (widget.isLeft) ...[
                      _buildTimelineConnector(primaryColor),
                      SizedBox(width: 36.w),
                    ],
                    Expanded(child: _buildContentCard(primaryColor)),
                    if (!widget.isLeft) ...[
                      SizedBox(width: 36.w),
                      _buildTimelineConnector(primaryColor),
                    ],
                  ],
                ),
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildTimelineConnector(Color primaryColor) {
    return SizedBox(
      width: 152.w,
      child: Column(
        children: [
          if (!widget.isFirst)
            Container(
              width: 12.w,
              height: 97.h,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    primaryColor.withOpacity(0.4),
                    primaryColor.withOpacity(0.8),
                  ],
                ),
              ),
            ),
          Container(
            width: 85.w,
            height: 85.h,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: primaryColor,
              border: Border.all(color: Colors.white, width: 12.w),
              boxShadow: [
                BoxShadow(
                  color: primaryColor.withOpacity(0.8),
                  blurRadius: 48.h,
                  spreadRadius: 12.w,
                ),
                BoxShadow(
                  color: Colors.black.withOpacity(0.5),
                  blurRadius: 24.h,
                ),
              ],
            ),
            child: Center(
              child: Container(
                width: 30.w,
                height: 30.h,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          if (!widget.isLast)
            Container(
              width: 12.w,
              height: 364.h,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    primaryColor.withOpacity(0.8),
                    primaryColor.withOpacity(0.3),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildContentCard(Color primaryColor) {
    return Card(
      color: Colors.grey[900],
      elevation: 36.h,
      shadowColor: primaryColor.withOpacity(0.3),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.grey[850]!, primaryColor.withOpacity(0.06)],
          ),
          border: Border.all(color: primaryColor.withOpacity(0.2), width: 6.w),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.4),
              blurRadius: 61.h,
              offset: Offset(0, 12.h),
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.all(50.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildAddressHeader(primaryColor),
              SizedBox(height: 40.h),
              _buildDateBadge(primaryColor),
              SizedBox(height: 40.h),
              _buildMediaGallery(primaryColor),
              SizedBox(height: 40.h),
              if (widget.group.moments.isNotEmpty &&
                  _buildTitleSection() != null) ...[
                _buildTitleSection()!,
                SizedBox(height: 40.h),
              ],
              _buildAISummarySection(primaryColor),
              SizedBox(height: 40.h),
              _buildActionButtons(primaryColor),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAddressHeader(Color primaryColor) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(20.w),
          decoration: BoxDecoration(
            color: primaryColor.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.location_on, color: primaryColor, size: 61.sp),
        ),
        SizedBox(width: 35.w),
        Expanded(
          child: AutoSizeText(
            widget.group.place ?? 'A memorable day'.tr,
            style: TextStyle(
              color: Colors.white,
              fontFamily: fontFamilyBold,
              fontSize: 50.sp,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildDateBadge(Color primaryColor) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 40.w, vertical: 20.h),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            primaryColor.withOpacity(0.15),
            primaryColor.withOpacity(0.08),
          ],
        ),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: primaryColor.withOpacity(0.3), width: 4.5.w),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withOpacity(0.2),
            blurRadius: 24.h,
            spreadRadius: 3.w,
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.calendar_today, color: primaryColor, size: 50.w),
          SizedBox(width: 25.w),
          AutoSizeText(
            _formatDate(widget.group.date),
            style: TextStyle(
              color: Colors.white,
              fontFamily: fontFamilyMedium,
              fontSize: 40.sp,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMediaGallery(Color primaryColor) {
    // Show latest media first
    final List<Moment> mediaMoments = widget.group.moments
        .where((m) => m.hasMedia)
        .toList();
    mediaMoments.sort((a, b) => b.date.compareTo(a.date));

    final int momentsToShow = mediaMoments.length > 4 ? 3 : mediaMoments.length;
    if (mediaMoments.isEmpty) {
      return Container(
        height: 300.h,
        decoration: BoxDecoration(
          color: Colors.grey[850]!,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: primaryColor.withOpacity(0.2)),
        ),
        child: Center(
          child: Icon(
            Icons.image_not_supported_outlined,
            color: Colors.white60,
            size: 145.sp,
          ),
        ),
      );
    }

    return SizedBox(
      height: 300.h,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: momentsToShow + (mediaMoments.length > 4 ? 1 : 0),
        itemBuilder: (context, i) {
          if (i == 3 && mediaMoments.length > 4) {
            return _buildMorePhotosWidget(primaryColor);
          }
          final moment = mediaMoments.elementAt(i);
          return _buildMediaWidget(moment, primaryColor, i);
        },
      ),
    );
  }

  Widget _buildMediaWidget(Moment moment, Color themeColor, int displayIndex) {
    return GestureDetector(
      onTap: () {
        if (moment.mediaType == 'photo') {
          final index = widget.group.moments
              .where((m) => m.mediaType == 'photo')
              .toList()
              .indexOf(moment);
          Get.to(() => ImagePreviewScreen(moment: moment, imageIndex: index));
        } else {
          final index = widget.group.moments
              .where((m) => m.mediaType == 'video')
              .toList()
              .indexOf(moment);
          Get.to(() => VideoPreviewScreen(moment: moment, videoIndex: index));
        }
      },
      child: Padding(
        padding: EdgeInsets.only(right: 40.w),
        child: Container(
          width: 300.w,
          height: 300.h,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: themeColor.withOpacity(0.3), width: 6.w),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 12.h,
                offset: Offset(0, 4.h),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: moment.mediaType == 'photo'
                ? FutureBuilder<String>(
                    future: StorageService.getFullPath(moment.previewPath),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) return _loadingPlaceholder();
                      final file = File(snapshot.data!);
                      return file.existsSync()
                          ? Image.file(
                              file,
                              fit: BoxFit.cover,
                              cacheWidth: 1212,
                              cacheHeight: 1212,
                            )
                          : _errorPlaceholder();
                    },
                  )
                : _buildVideoThumbnail(moment, themeColor),
          ),
        ),
      ),
    );
  }

  Widget _buildVideoThumbnail(Moment moment, Color themeColor) {
    final path = moment.videoPaths.first;
    final thumbnail = _thumbnailCache[path];

    if (thumbnail != null) {
      return Stack(
        fit: StackFit.expand,
        children: [
          Image.memory(thumbnail, fit: BoxFit.cover),
          Center(
            child: Container(
              padding: EdgeInsets.all(20.w),
              decoration: BoxDecoration(
                color: Colors.black54,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.play_arrow, color: Colors.white, size: 80.sp),
            ),
          ),
        ],
      );
    }

    // Fallback: generate on-demand
    return FutureBuilder<Uint8List?>(
      future: () async {
        if (_thumbnailCache.containsKey(path)) return _thumbnailCache[path];
        final fullPath = await StorageService.getFullPath(path);
        final thumb = await VideoThumbnail.thumbnailData(
          video: fullPath,
          imageFormat: ImageFormat.JPEG,
          maxWidth: 600,
          quality: 75,
        );
        _thumbnailCache[path] = thumb;
        return thumb;
      }(),
      builder: (context, snapshot) {
        if (snapshot.hasData && snapshot.data != null) {
          return Stack(
            fit: StackFit.expand,
            children: [
              Image.memory(snapshot.data!, fit: BoxFit.cover),
              Center(
                child: Container(
                  padding: EdgeInsets.all(20.w),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.play_arrow,
                    color: Colors.white,
                    size: 80.sp,
                  ),
                ),
              ),
            ],
          );
        }
        return _loadingPlaceholder();
      },
    );
  }

  Widget _loadingPlaceholder() {
    return Container(
      color: Colors.grey[800],
      child: Center(child: CupertinoActivityIndicator(color: appColor)),
    );
  }

  Widget _errorPlaceholder() {
    return Container(
      color: Colors.grey[800],
      child: Icon(Icons.broken_image, color: Colors.grey, size: 60.r),
    );
  }

  Widget _buildMorePhotosWidget(Color themeColor) {
    return GestureDetector(
      onTap: () {
        Get.find<MomentsController>().setDateFilter(widget.group.date);
        Get.toNamed('/memories');
      },
      child: Container(
        width: 300.w,
        height: 300.h,
        margin: EdgeInsets.only(right: 40.w),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [themeColor.withOpacity(0.9), themeColor],
          ),
          border: Border.all(color: Colors.white, width: 7.5.w),
          boxShadow: [
            BoxShadow(
              color: themeColor.withOpacity(0.5),
              blurRadius: 36.h,
              spreadRadius: 6.w,
              offset: Offset(0, 8.h),
            ),
            BoxShadow(
              color: Colors.black.withOpacity(0.4),
              blurRadius: 24.h,
              offset: Offset(0, 4.h),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.photo_library, color: Colors.white, size: 100.w),
              SizedBox(height: 20.h),
              AutoSizeText(
                '+${widget.group.moments.length - 3}',
                style: TextStyle(
                  color: Colors.white,
                  fontFamily: fontFamilyBold,
                  fontSize: 50.sp,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget? _buildTitleSection() {
    final firstMoment = widget.group.moments.last;
    final title = firstMoment.title?.trim();
    final caption = firstMoment.caption?.trim();
    final note = firstMoment.note?.trim();
    final content = [
      title,
      caption,
      note,
    ].firstWhere((e) => e != null && e.isNotEmpty, orElse: () => null);
    if (content == null) return null;
    return Container(
      padding: EdgeInsets.all(36.w),
      decoration: BoxDecoration(
        color: Colors.grey[800],
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey[600]!),
      ),
      child: AutoSizeText(
        content,
        style: TextStyle(
          color: Colors.white,
          fontSize: 45.sp,
          fontFamily: fontFamilyMedium,
        ),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _buildAISummarySection(Color primaryColor) {
    final summary = widget.group.summary ?? '';
    final dateKey = widget.group.date.toIso8601String().split('T')[0];
    final isGenerating =
        summary.contains('Generating') ||
        Get.find<MomentsController>().pendingSummaries.contains(dateKey);

    return Container(
      padding: EdgeInsets.all(42.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            primaryColor.withOpacity(0.1),
            primaryColor.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: primaryColor.withOpacity(0.2), width: 4.5.w),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.auto_awesome, color: primaryColor, size: 50.w),
              SizedBox(width: 25.w),
              AutoSizeText(
                'AI Summary',
                style: TextStyle(
                  color: primaryColor,
                  fontFamily: fontFamilySemiBold,
                  fontSize: 45.sp,
                ),
              ),
            ],
          ),
          SizedBox(height: 30.h),
          if (isGenerating)
            const CupertinoActivityIndicator()
          else
            ConstrainedBox(
              constraints: BoxConstraints(maxHeight: 350.h),
              child: Scrollbar(
                thumbVisibility: true,
                radius: Radius.circular(20),
                thickness: 9.w,
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: AutoSizeText(
                    summary,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 45.sp,
                      fontFamily: fontFamilyMedium,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(Color primaryColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: 40.w),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                primaryColor.withOpacity(0.1),
                primaryColor.withOpacity(0.05),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: primaryColor.withOpacity(0.3)),
          ),
          child: TextButton.icon(
            onPressed: () {
              Get.find<MomentsController>().setDateFilter(widget.group.date);
              Get.toNamed('/memories');
            },
            icon: Icon(Icons.visibility, size: 50.w, color: primaryColor),
            label: AutoSizeText(
              'View All'.tr,
              style: TextStyle(
                color: primaryColor,
                fontSize: 45.sp,
                fontFamily: fontFamilyMedium,
              ),
            ),
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
              foregroundColor: primaryColor,
            ),
          ),
        ),
        IconButton(
          icon: Icon(Icons.delete_outline, size: 75.w, color: Colors.red),
          onPressed: () => _showDeleteDialog(primaryColor),
          padding: EdgeInsets.all(25.w),
          constraints: const BoxConstraints(),
          style: IconButton.styleFrom(
            backgroundColor: Colors.red.withOpacity(0.1),
            shape: const CircleBorder(),
          ),
        ),
      ],
    );
  }

  void _showDeleteDialog(Color color) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        backgroundColor: Colors.grey[900],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: EdgeInsets.all(40.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(height: 25.h),
              Image.asset(
                "assets/timeline_screen/delete_ic.png",
                width: 180.w,
                height: 180.h,
              ),
              SizedBox(height: 25.h),
              AutoSizeText(
                'Delete Timeline',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 75.sp,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 25.h),
              AutoSizeText(
                'Are you sure you want to delete this entire day\'s memories? This action cannot be undone.'.tr,
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 45.sp,
                  fontFamily: fontFamilySemiBold,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 40.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  PressUnpress(
                    onTap: () => Navigator.pop(context),
                    height: 140.h,
                    width: 400.w,
                    child: Center(child: AutoSizeText("Cancel".tr,style: TextStyle(color: Colors.white),),),
                    pressColor: Colors.grey,
                    unPressColor: Colors.grey,
                  ),
                  PressUnpress(
                    onTap: () {
                      Navigator.pop(context);
                      widget.onDelete();
                    },
                    height: 140.h,
                    width: 400.w,
child: Center(child: AutoSizeText("Delete",style: TextStyle(color: Colors.white),),),
                    pressColor: pressColor,
                    unPressColor: unPressColor,
                    // imageAssetPress:
                    //     'assets/timeline_screen/delete_btn_click.png',
                    // imageAssetUnPress: 'assets/timeline_screen/delete_btn.png',
                  ),
                ],
              ),
              SizedBox(height: 24.h),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
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
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }
}
