import 'dart:async';
import 'dart:io';
import 'package:auto_size_text/auto_size_text.dart';

import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geocoding/geocoding.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';
import 'package:snap_journey/configuration/FirebaseAnalyticsService.dart';
import 'package:snap_journey/controller/MomentsController.dart';
import 'package:snap_journey/google_ads_material/ads_variable.dart';
import 'package:snap_journey/google_ads_material/banner_widget.dart';
import 'package:snap_journey/screen/EditMomentScreen.dart';
import 'package:snap_journey/service/StorageService.dart';
import 'package:snap_journey/service/press_unpress.dart';
import 'package:video_player/video_player.dart';
import 'package:snap_journey/model/moment.dart';
import 'package:snap_journey/screen/common_screen/constant.dart';

import '../controller/Cameracontroller.dart';

class VideoPreviewScreen extends StatefulWidget {
  final Moment moment;
  final int videoIndex;

  const VideoPreviewScreen({
    super.key,
    required this.moment,
    this.videoIndex = 0,
  });

  @override
  State<VideoPreviewScreen> createState() => _VideoPreviewScreenState();
}

class _VideoPreviewScreenState extends State<VideoPreviewScreen>
    with SingleTickerProviderStateMixin {
  // Controllers
  VideoPlayerController? _controller;
  late final AnimationController _fadeController;
  late final Animation<double> _fadeAnimation;
  final _placeName = RxnString();

  final _isLoadingPlace = false.obs;

  // Reactive state
  final _showControls = true.obs;
  final _isPlaying = false.obs;
  final _progress = 0.0.obs;
  final _isLoading = true.obs;
  final _error = RxnString();

  Timer? _hideTimer;

  @override
  void initState() {
    super.initState();
    FirebaseAnalyticsService.logEvent(
      eventName: "Snap_Journey_Video_Preview_Screen",
    );
    _setupAnimations();
    _loadVideo();
    if (widget.moment.hasLocation) {
      _fetchPlaceName();
    }
  }

  Future<void> _fetchPlaceName() async {
    if (!widget.moment.hasLocation) return;

    _isLoadingPlace.value = true;
    _placeName.value = null;

    try {
      final placemarks = await placemarkFromCoordinates(
        widget.moment.lat,
        widget.moment.lng,
      );

      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        final parts = <String>[];

        final subLocality = place.subLocality ?? '';
        final locality = place.locality ?? '';
        final adminArea = place.administrativeArea ?? '';
        final country = place.country ?? '';

        if (subLocality.isNotEmpty && subLocality != locality)
          parts.add(subLocality);
        if (locality.isNotEmpty) parts.add(locality);
        if (adminArea.isNotEmpty && adminArea != locality) parts.add(adminArea);
        if (country.isNotEmpty) parts.add(country);

        _placeName.value = parts.isNotEmpty ? parts.join(', ') : null;
      } else {
        _placeName.value = null;
      }
    } catch (e) {
      debugPrint('Geocoding error: $e');
      _placeName.value = null;
    } finally {
      _isLoadingPlace.value = false;
    }
  }

  void _setupAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeOut));
  }

  Future<void> _loadVideo() async {
    _isLoading.value = true;
    _error.value = null;

    final relativePath = _getValidVideoPath();
    if (relativePath == null) {
      _error.value = 'No video found';
      _isLoading.value = false;
      return;
    }

    try {
      final fullPath = await StorageService.getFullPath(relativePath);
      final file = File(fullPath);

      if (!await file.exists()) {
        _error.value = 'Video file not found';
        _isLoading.value = false;
        return;
      }

      _controller = VideoPlayerController.file(file)..addListener(_onProgress);

      await _controller!.initialize();

      if (!mounted) return;

      await _controller!.play();
      _isPlaying.value = true;
      _showControls.value = true;
      _startHideTimer();
    } catch (e, s) {
      debugPrint('Video load error: $e\n$s');
      _error.value = 'Failed to load video';
    } finally {
      if (mounted) _isLoading.value = false;
    }
  }

  String? _getValidVideoPath() {
    if (widget.moment.videoPaths.isEmpty) return null;
    final index = widget.videoIndex.clamp(
      0,
      widget.moment.videoPaths.length - 1,
    );
    return widget.moment.videoPaths[index];
  }

  void _onProgress() {
    if (_controller case final controller?) {
      final duration = controller.value.duration.inMilliseconds;
      if (duration == 0) return;

      _progress.value = controller.value.position.inMilliseconds / duration;

      if (controller.value.position >= controller.value.duration) {
        _isPlaying.value = false;
        _showControls.value = true;
        _fadeController.reset();
        _fadeController.forward();
        _cancelHideTimer();
      } else {
        _isPlaying.value = controller.value.isPlaying;
      }
    }
  }

  void _togglePlayPause() {
    if (_controller case final controller?) {
      if (controller.value.position >= controller.value.duration) {
        controller.seekTo(Duration.zero);
        controller.play();
      } else {
        controller.value.isPlaying ? controller.pause() : controller.play();
      }
      _showControls.value = true;
      _startHideTimer();
    }
  }

  void _seekTo(double value) {
    if (_controller case final controller?) {
      controller.seekTo(controller.value.duration * value);
      _showControls.value = true;
      _startHideTimer();
    }
  }

  void _startHideTimer() {
    _cancelHideTimer();
    _hideTimer = Timer(const Duration(seconds: 3), () {
      if (mounted && _isPlaying.value) {
        _showControls.value = false;
      }
    });
  }

  void _cancelHideTimer() {
    _hideTimer?.cancel();
    _hideTimer = null;
  }

  void _showControlsTemporarily() {
    _showControls.value = true;
    _startHideTimer();
  }

  @override
  void dispose() {
    _cancelHideTimer();
    _controller?.removeListener(_onProgress);
    _controller?.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appbackgroundColor,
      extendBodyBehindAppBar: true,
      appBar: buildAppBar(),
      body: _buildBody(),
    );
  }

  Widget _buildInfoContainer() {
    final hasTitle = widget.moment.title?.trim().isNotEmpty ?? false;
    final hasNote = widget.moment.note?.trim().isNotEmpty ?? false;
    final hasCaption = widget.moment.caption?.trim().isNotEmpty ?? false;

    final hasValidLocation = _placeName.value != null;
    if (!hasTitle && !hasNote && !hasCaption || hasValidLocation) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 40.w, vertical: 20.h),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(30.w),
        decoration: BoxDecoration(
          color: const Color(0xff1F232F),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xff535353), width: 2.w),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Title
            if (hasTitle)
              AutoSizeText(
                widget.moment.title!,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 55.sp,
                  fontFamily: fontFamilyBold,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),

            // Note
            if (hasNote) ...[
              if (hasTitle) SizedBox(height: 15.h),
              AutoSizeText(
                widget.moment.note!,
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 45.sp,
                  fontFamily: fontFamilyMedium,
                ),
                maxLines: 4,
                overflow: TextOverflow.ellipsis,
              ),
            ],

            // Caption
            if (hasCaption) ...[
              if (hasTitle || hasNote) SizedBox(height: 15.h),
              AutoSizeText(
                widget.moment.caption!,
                style: TextStyle(
                  color: appColor,
                  fontSize: 45.sp,
                  fontFamily: fontFamilyMedium,
                  fontStyle: FontStyle.italic,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],

            if (_placeName.value != null) ...[
              SizedBox(height: 20.h),
              Row(
                children: [
                  Image.asset(
                    "assets/timeline_screen/location_ic.png",
                    width: 100.w,
                    height: 100.h,
                  ),
                  SizedBox(width: 20.w),
                  _isLoadingPlace.value
                      ? const SizedBox(
                          width: 12,
                          height: 12,
                          child: CircularProgressIndicator(
                            strokeWidth: 1.5,
                            color: Colors.white70,
                          ),
                        )
                      : Expanded(
                          child: AutoSizeText(
                            _placeName.value!,
                            style: TextStyle(
                              color: Colors.white60,
                              fontSize: 40.sp,
                              fontFamily: fontFamilyMedium,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget buildAppBar() {
    return AppBar(
      forceMaterialTransparency: true,
      backgroundColor: Colors.transparent,
      centerTitle: true,
      leading:
      Padding(
        padding: const EdgeInsets.all(8.0),
        child: CircleAvatar(
          backgroundColor: Colors.black.withOpacity(0.4),
          child: Padding(
            padding: EdgeInsets.only(left: 10.w),
            child: Center(
              child: IconButton(
                onPressed: () {
                 Get.back();                  },
                icon: Icon(Icons.arrow_back_ios, color: Colors.white),
              ),
            ),
          ),
        ),
      ),
      // PressUnpress(
      //   onTap: () => Get.back(),
      //   height: 120.h,
      //   width: 120.w,
      //   imageAssetPress: 'assets/home_screen/back_arrow_click.png',
      //   imageAssetUnPress: 'assets/home_screen/back_arrow.png',
      // ).marginAll(30.w),
      title: AutoSizeText(
        'Video Player'.tr,
        style: TextStyle(
          color: Colors.black,
          fontSize: 70.sp,
          fontFamily: fontFamilySemiBold,
        ),
      ),
      actions: [
        DropdownButtonHideUnderline(
          child: DropdownButton2<String>(
            customButton: Container(
              width: 120.w,
              height: 120.h,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.1),
              ),
              child: Icon(Icons.more_vert, color: Colors.black, size: 30),
            ),
            items: [
              // Edit Option
              DropdownMenuItem<String>(
                value: 'edit',
                child: Row(
                  children: [
                    Image.asset(
                      'assets/home_screen/edit_btn.png',
                      width: 80.w,
                      height: 80.h,
                    ),
                    SizedBox(width: 20.w),
                    AutoSizeText(
                      'Edit',
                      style: TextStyle(
                        fontSize: 45.sp,
                        fontFamily: fontFamilyMedium,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              // Share Option
              DropdownMenuItem<String>(
                value: 'share',
                child: Row(
                  children: [

                    Center(
                      child:  Icon(Icons.share, color: Colors.white,size: 20,),
                    ),
                    SizedBox(width: 15.w),
                    SizedBox(
                      width: 220.w,
                      child: AutoSizeText(
                        'Share'.tr,
                        overflow: TextOverflow.ellipsis,
                        softWrap: true,
                        style: TextStyle(
                          fontSize: 45.sp,
                          fontFamily: fontFamilyMedium,
                          overflow: TextOverflow.ellipsis,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Delete Option
              DropdownMenuItem<String>(
                value: 'delete',
                child: Row(
                  children: [
                    Center(
                      child:  Icon(Icons.delete, color: Colors.white,size: 20,),
                    ),
                    SizedBox(width: 20.w),
                    AutoSizeText(
                      'Delete'.tr,
                      style: TextStyle(
                        fontSize: 45.sp,
                        fontFamily: fontFamilyMedium,
                        color: Colors.red,
                      ),
                    ),
                  ],
                ),
              ),
            ],
            onChanged: (String? value) async {
              switch (value) {
                case 'edit':
                  if (_controller?.value.isPlaying == true) {
                    _controller?.pause();
                    _isPlaying.value = false;
                  }
                  Get.lazyPut<Cameracontroller>(() => Cameracontroller(),fenix: true);

                  await Get.to(() => EditMomentScreen(moment: widget.moment));
                  if (mounted) {
                    setState(() {});
                  }
                  break;
                case 'share':
                  _shareVideo();
                  break;
                case 'delete':
                  _confirmDelete();
                  break;
              }
            },
            dropdownStyleData: DropdownStyleData(
              width: 400.w,
              padding: EdgeInsets.symmetric(vertical: 20.h),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: const Color(0xff1F232F),
                border: Border.all(color: const Color(0xff535353)),
              ),
              offset: Offset(-20.w, 0),
            ),
            menuItemStyleData: MenuItemStyleData(
              height: 120.h,
              padding: EdgeInsets.symmetric(horizontal: 30.w),
            ),
          ),
        ).marginOnly(right: 40.w),
      ],
    );
  }
  void _shareVideo() async {
    try {
      if (widget.moment.videoPaths.isEmpty) return;

      final videoPath = widget.moment.videoPaths.first;
      final fullPath = await StorageService.getFullPath(videoPath);

      // Prepare the caption properly
      String? shareText = widget.moment.caption?.trim();
      if (shareText == null || shareText.isEmpty) {
        shareText = 'Check out this video from SnapJourney!';
      }

      await Share.shareXFiles(
        [XFile(fullPath)],
        text: shareText,
      );
    } catch (e) {
      debugPrint("Share Error: $e");
      Get.snackbar(
        'Error',
        'Failed to share video',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> _confirmDelete() async {
    final confirm =
        await showDialog<bool>(
          context: context,
          builder: (context) => _buildDeleteDialog(),
        ) ??
        false;

    if (confirm) {
      await _deleteMoment();
    }
  }

  Future<void> _deleteMoment() async {
    try {
      await widget.moment.delete();

      final momentsController = Get.find<MomentsController>();
      await momentsController.loadMoments();

      Get.back(); // Go back to previous screen
      Get.snackbar(
        'Deleted',
        'Video deleted successfully',
        backgroundColor: Colors.black87,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to delete: $e',
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Widget _buildDeleteDialog() {
    return AlertDialog(
      backgroundColor: const Color(0xff1F232F),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: AutoSizeText(
        'Delete Video',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 60.sp,
          fontFamily: fontFamilyBold,
          color: Colors.white,
        ),
      ),
      content: AutoSizeText(
        'Are you sure you want to delete this video?'.tr,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 50.sp,
          fontFamily: fontFamilyMedium,
          color: Colors.white,
        ),
      ),
      actionsAlignment: MainAxisAlignment.spaceEvenly,
      actions: [
        TextButton(

          onPressed: () => Navigator.pop(context, false),

          style: TextButton.styleFrom(

            backgroundColor: Colors.black.withOpacity(0.2),
            // Set your background color here
            foregroundColor: Colors.white,
            // This sets the text/icon color
            padding: EdgeInsets.symmetric(horizontal: 60.w, vertical: 10.h),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(
                40.r,

              ), // Optional: rounded corners
            ),
          ),

          child: AutoSizeText(
            'Cancel'.tr,
            style: TextStyle(color: Colors.white, fontSize: 50.sp),
          ),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, true),
          style: TextButton.styleFrom(

            backgroundColor: Colors.white.withOpacity(0.2),
            // Set your background color here
            foregroundColor: Colors.white,
            // This sets the text/icon color
            padding: EdgeInsets.symmetric(horizontal: 60.w, vertical: 10.h),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(
                40.r,

              ), // Optional: rounded corners
            ),
          ),
          child: AutoSizeText(
            'Delete',
            style: TextStyle(color: Colors.red, fontSize: 50.sp),
          ),
        ),
      ],
    );
  }

  Widget _buildBody() {
    return Container(
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
            Expanded(child: _buildVideoPlayer()),
            // _buildInfoContainer(),
            // _buildAdBanner(),
          ],
        ),
      ),
    );
  }

  Widget _buildVideoPlayer() {
    return Obx(() {
      if (_isLoading.value) return _buildLoading();
      if (_error.value != null) return _buildError();
      if (_controller == null || !_controller!.value.isInitialized) {
        return const Center(child: AutoSizeText('Video not ready'));
      }

      return GestureDetector(
        onTap: _showControlsTemporarily,
        child: Stack(
          alignment: Alignment.topCenter,
          children: [
            _buildVideoWidget(),
            Center(child: _buildPlayPauseButton()),
            _buildProgressBar(),
          ],
        ),
      );
    });
  }

  Widget _buildLoading() {
    return const Center(
      child: CircularProgressIndicator(color: appColor, strokeWidth: 3),
    );
  }

  Widget _buildError() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline, color: Colors.white70, size: 80),
          const SizedBox(height: 16),
          AutoSizeText(
            _error.value!,
            style: TextStyle(color: Colors.white70, fontSize: 50.sp),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          PressUnpress(
            onTap: _loadVideo,
            width: 400.w,
            height: 120.h,
            child: AutoSizeText(
              'Retry'.tr,
              style: TextStyle(
                color: Colors.white,
                fontSize: 50.sp,
                fontFamily: fontFamilyMedium,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVideoWidget() {
    return Padding(
      padding: EdgeInsets.all(40.w),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: AspectRatio(
          aspectRatio: _controller!.value.aspectRatio,
          child: VideoPlayer(_controller!),
        ),
      ),
    );
  }

  Widget _buildPlayPauseButton() {
    return Obx(() {
      // 1. Check for visibility first (Performance: prevents unnecessary rendering)
      if (!_showControls.value) return const SizedBox.shrink();

      return FadeTransition(
        opacity: _fadeAnimation,
        child: PressUnpress(
          onTap: _togglePlayPause,
          height: 180.h,
          width: 180.w,
          // Using a child instead of image assets
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.black.withOpacity(0.5), // Semi-transparent background
              border: Border.all(color: Colors.white24, width: 2),
            ),
            child: Center(
              child: Icon(
                _isPlaying.value ? Icons.pause_rounded : Icons.play_arrow_rounded,
                color: Colors.white,
                size: 100.h, // Scaled icon size
              ),
            ),
          ),
        ),
      );
    });
  }

  Widget _buildProgressBar() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Obx(() {
        if (!_showControls.value) return const SizedBox.shrink();

        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: EdgeInsets.symmetric(vertical: 30.h, horizontal: 40.w),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.transparent, Colors.black.withOpacity(0.8)],
            ),
          ),
          child: Row(
            children: [
              _buildTimeText(_controller!.value.position),
              Expanded(child: _buildSlider()),
              _buildTimeText(_controller!.value.duration),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildTimeText(Duration duration) {
    return AutoSizeText(
      _formatDuration(duration),
      style: TextStyle(
        color: Colors.white70,
        fontSize: 45.sp,
        fontFamily: fontFamilyMedium,
      ),
    );
  }

  Widget _buildSlider() {
    return SliderTheme(
      data: SliderTheme.of(context).copyWith(
        thumbColor: appColor,
        activeTrackColor: appColor,
        inactiveTrackColor: Colors.white24,
        trackHeight: 6,
        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
        overlayShape: const RoundSliderOverlayShape(overlayRadius: 16),
      ),
      child: Slider(value: _progress.value, min: 0, max: 1, onChanged: _seekTo),
    );
  }

  Widget _buildAdBanner() {
    return Obx(
      () => AdsVariable.isPurchase.isFalse
          ? BannerTemplate(
              bannerId: AdsVariable.banner_vid_preview_screen,
            ).marginOnly(top: 40.h)
          : const SizedBox.shrink(),
    );
  }

  String _formatDuration(Duration d) {
    final minutes = d.inMinutes.toString().padLeft(2, '0');
    final seconds = (d.inSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }
}
