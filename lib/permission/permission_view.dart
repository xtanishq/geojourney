import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:snap_journey/screen/MapScreen.dart';
import 'package:snap_journey/service/dialog.dart';
import 'package:snap_journey/service/sharedPreferencesService.dart';
import '../screen/common_screen/constant.dart';
import '../service/permission.dart';
import 'package:auto_size_text/auto_size_text.dart';

class PermissionView extends StatefulWidget {
  final bool fromcamera;
  const PermissionView({
    required this.fromcamera,
    super.key});

  @override
  State<PermissionView> createState() => _PermissionViewState();
}

class _PermissionViewState extends State<PermissionView> with TickerProviderStateMixin {
  final Map<String, bool> _permissionStatus = {
    'camera': false,
    'microphone': false,
    'gallery': false,
    'location': false,
  };

  late AnimationController _mainController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _checkAllPermissions();
  }

  void _setupAnimations() {
    _mainController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(parent: _mainController, curve: Curves.easeIn);
    _slideAnimation = Tween<Offset>(begin: const Offset(0, 0.05), end: Offset.zero)
        .animate(CurvedAnimation(parent: _mainController, curve: Curves.easeOutQuad));
    _mainController.forward();
  }

  @override
  void dispose() {
    _mainController.dispose();
    super.dispose();
  }

  /// Refreshes the local state based on actual system permission status
  Future<void> _checkAllPermissions() async {
    _permissionStatus['camera'] = await Permission.camera.isGranted;
    _permissionStatus['microphone'] = await Permission.microphone.isGranted;

    // Android 13+ uses specific media permissions, older use storage
    if (Platform.isAndroid) {
      _permissionStatus['gallery'] = await Permission.storage.isGranted || await Permission.photos.isGranted;
    } else {
      _permissionStatus['gallery'] = await Permission.photos.isGranted;
    }

    _permissionStatus['location'] = await Permission.location.isGranted;

    if (mounted) setState(() {});
  }

  /// Logic to request permission using your MyPermissionHandler
  Future<void> _requestPermission(String type) async {
    // 1. Try to request the permission
    final bool isGranted = await MyPermissionHandler.checkPermission(context, type);

    // 2. If it returns false (denied or permanently denied), show your custom professional dialog
    if (!isGranted) {
      if (mounted) {
        MyPermissionHandler.showPermissionDialog(context, type);
      }
    }

    // 3. Refresh the UI status
    await _checkAllPermissions();
  }

  bool get _allGranted => !_permissionStatus.values.contains(false);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        forceMaterialTransparency: true,
        backgroundColor: Colors.transparent,
        leading:  IconButton(onPressed: (){
          Get.back();
        }, icon: Icon(Icons.arrow_back_ios_new),),
        title: AutoSizeText(
          'Permissions'.tr,
          style: TextStyle(
            fontSize: 22, // Adjusted for standard look, use .sp if preferred
            fontFamily: fontFamilyBold,
            color: primarycolor,
            letterSpacing: -0.5,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 10),
                  AutoSizeText(
                    'Enable access to unlock all SnapJourney features.'.tr,
                    style: TextStyle(
                      fontSize: 15,
                      fontFamily: fontFamilyRegular,
                      color: Colors.grey.shade600,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 32),
                  _buildProgressSection(),
                  const SizedBox(height: 24),
                  Expanded(
                    child: ListView(
                      physics: const BouncingScrollPhysics(),
                      children: [
                        _buildPermissionItem(
                          'camera',
                          'Camera'.tr,
                          'Capture your journey in real-time'.tr,
                          Icons.videocam_outlined,
                        ),
                        _buildPermissionItem(
                          'microphone',
                          'Microphone'.tr,
                          'Record audio for your video stories'.tr,
                          Icons.mic_none_outlined,
                        ),
                        _buildPermissionItem(
                          'gallery',
                          'Gallery'.tr,
                          'Save and view your captured memories'.tr,
                          Icons.photo_outlined,
                        ),
                        _buildPermissionItem(
                          'location',
                          'Location'.tr,
                          'Tag and map your favorite places'.tr,
                          Icons.location_on_outlined,
                        ),
                      ],
                    ),
                  ),
                  _buildContinueButton(),
120.verticalSpace
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProgressSection() {
    final grantedCount = _permissionStatus.values.where((v) => v).length;
    final totalCount = _permissionStatus.length;
    final progress = grantedCount / totalCount;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              AutoSizeText(
                'Setup Progress'.tr,
                style: TextStyle(
                  fontFamily: fontFamilySemiBold,
                  color: Colors.grey.shade800,
                ),
              ),
              AutoSizeText(
                '$grantedCount of $totalCount',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: primarycolor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.grey.shade100,
              valueColor: const AlwaysStoppedAnimation<Color>(primarycolor),
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPermissionItem(String key, String title, String subtitle, IconData icon) {
    bool isGranted = _permissionStatus[key] ?? false;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isGranted ? Colors.transparent : Colors.grey.shade200,
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: isGranted ? primarycolor.withOpacity(0.05) : Colors.grey.shade50,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            color: isGranted ? primarycolor : Colors.grey.shade400,
          ),
        ),
        title: AutoSizeText(
          title,
          style: TextStyle(
            fontFamily: fontFamilyBold,
            fontSize: 16,
            color: isGranted ? primarycolor : Colors.black87,
          ),
        ),
        subtitle: AutoSizeText(
          subtitle,
          style: TextStyle(
              fontSize: 13,
              fontFamily: fontFamilyRegular,
              color: Colors.grey.shade500
          ),
        ),
        trailing: isGranted
            ? const Icon(Icons.check_circle_rounded, color: Colors.green, size: 28)
            : TextButton(
          onPressed: () => _requestPermission(key),
          style: TextButton.styleFrom(
            foregroundColor: primarycolor,
            backgroundColor: primarycolor.withOpacity(0.08),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            padding: const EdgeInsets.symmetric(horizontal: 16),
          ),
          child: AutoSizeText(
            'Allow'.tr,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  Widget _buildContinueButton() {
    return Center(
      child: SizedBox(
        width: 1100.w,
        height: 170.h,
        child: ElevatedButton(
          onPressed: _allGranted ? () async{
            DialogService.showLoading(context);
           SharedPreferencesService.setPermission(true);
           Navigator.pop(context);
            // Get.back();
            if(widget.fromcamera){
              Get.offNamed('/CameraScreen');

            }
            else{
              Get.off(()=>MapScreen());

            }
            // Add your navigation logic here (e.g., Get.to(HomeScreen()))
          } : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: primarycolor,
            foregroundColor: Colors.white,
            disabledBackgroundColor: Colors.grey.shade300,
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: AutoSizeText(
            'Get Started'.tr,
            style: TextStyle(
              fontSize: 65.sp,
              fontFamily: "BOld",


            ),
          ),
        ),
      ),
    );
  }
}