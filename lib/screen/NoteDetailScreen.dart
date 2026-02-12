// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:get/get.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:share_plus/share_plus.dart';
// import 'package:snap_journey/google_ads_material/ads_variable.dart';
// import 'package:snap_journey/google_ads_material/banner_widget.dart';
// import 'package:snap_journey/model/moment.dart';
// import 'package:snap_journey/controller/NotesController.dart';
// import 'package:snap_journey/screen/common_screen/constant.dart';
// import 'package:snap_journey/service/possessing_dialog.dart';
// import 'package:snap_journey/service/press_unpress.dart';
// import 'package:snap_journey/service/StorageService.dart'; // ADD THIS
// import 'ImagePreviewScreen.dart';
// import 'VideoPreviewScreen.dart';
//
// class NotePreviewScreen extends StatefulWidget {
//   final Moment moment;
//
//   const NotePreviewScreen({super.key, required this.moment});
//
//   @override
//   State<NotePreviewScreen> createState() => _NotePreviewScreenState();
// }
//
// class _NotePreviewScreenState extends State<NotePreviewScreen> {
//   late List<String> photoPaths;
//   late List<String> videoPaths;
//   final Map<String, String?> _thumbnailCache = <String, String?>{};
//
//   @override
//   void initState() {
//     super.initState();
//     photoPaths = List<String>.from(widget.moment.photoPaths);
//     videoPaths = List<String>.from(widget.moment.videoPaths);
//   }
//
//   Widget _buildPhotoThumbnail(String relativePath) {
//     return FutureBuilder<String>(
//       future: StorageService.getFullPath(relativePath),
//       builder: (context, snapshot) {
//         if (!snapshot.hasData) {
//           return Container(
//             decoration: BoxDecoration(
//               color: Colors.grey[900],
//               borderRadius: BorderRadius.circular(16),
//             ),
//             child: const Center(
//               child: SizedBox(
//                 width: 30,
//                 height: 30,
//                 child: CircularProgressIndicator(
//                   color: Colors.white70,
//                   strokeWidth: 2,
//                 ),
//               ),
//             ),
//           );
//         }
//
//         final fullPath = snapshot.data!;
//         final file = File(fullPath);
//
//         if (!file.existsSync()) {
//           return Container(
//             decoration: BoxDecoration(
//               color: Colors.grey[900],
//               borderRadius: BorderRadius.circular(16),
//             ),
//             child: const Icon(
//               Icons.broken_image,
//               color: Colors.white70,
//               size: 48,
//             ),
//           );
//         }
//
//         return ClipRRect(
//           borderRadius: BorderRadius.circular(16),
//           child: Image.file(
//             file,
//             fit: BoxFit.cover,
//             width: double.infinity,
//             height: double.infinity,
//             errorBuilder: (c, e, s) => Container(
//               color: Colors.grey[800],
//               child: const Icon(
//                 Icons.image_not_supported,
//                 size: 48,
//                 color: Colors.white70,
//               ),
//             ),
//           ),
//         );
//       },
//     );
//   }
//
//   // FIXED: Use full path for thumbnail generation
//   Widget _buildVideoThumbnail(String relativePath) {
//     final cacheKey = relativePath.hashCode.toString();
//
//     if (_thumbnailCache.containsKey(cacheKey)) {
//       final cached = _thumbnailCache[cacheKey];
//       if (cached != null && File(cached).existsSync()) {
//         return _buildVideoThumbnailWidget(cached);
//       }
//     }
//
//     return FutureBuilder<String>(
//       future: StorageService.getFullPath(relativePath),
//       builder: (context, pathSnapshot) {
//         if (!pathSnapshot.hasData) {
//           return _buildVideoLoadingWidget();
//         }
//
//         final fullPath = pathSnapshot.data!;
//         final file = File(fullPath);
//         if (!file.existsSync()) {
//           return _buildVideoErrorWidget();
//         }
//
//         return FutureBuilder<String?>(
//           key: ValueKey(cacheKey),
//           future: NotesController.generateThumbnail(fullPath), // Use full path
//           builder: (context, thumbSnapshot) {
//             if (thumbSnapshot.connectionState == ConnectionState.waiting) {
//               return _buildVideoLoadingWidget();
//             }
//
//             final thumbPath = thumbSnapshot.data;
//             _thumbnailCache[cacheKey] = thumbPath;
//
//             if (thumbPath != null && File(thumbPath).existsSync()) {
//               return _buildVideoThumbnailWidget(thumbPath);
//             }
//             return _buildVideoErrorWidget();
//           },
//         );
//       },
//     );
//   }
//
//   Widget _buildVideoLoadingWidget() {
//     return Container(
//       decoration: BoxDecoration(
//         color: Colors.grey[900],
//         borderRadius: BorderRadius.circular(16),
//       ),
//       child: const Center(
//         child: CircularProgressIndicator(color: Colors.white70, strokeWidth: 2),
//       ),
//     );
//   }
//
//   Widget _buildVideoErrorWidget() {
//     return Container(
//       decoration: BoxDecoration(
//         color: Colors.grey[900],
//         borderRadius: BorderRadius.circular(16),
//       ),
//       child: const Icon(Icons.videocam_off, size: 50, color: Colors.white70),
//     );
//   }
//
//   Widget _buildVideoThumbnailWidget(String thumbPath) {
//     return Stack(
//       children: [
//         ClipRRect(
//           borderRadius: BorderRadius.circular(16),
//           child: Image.file(
//             File(thumbPath),
//             fit: BoxFit.cover,
//             width: double.infinity,
//             height: double.infinity,
//           ),
//         ),
//         const Center(
//           child: Icon(Icons.play_circle_outline, size: 50, color: Colors.white),
//         ),
//       ],
//     );
//   }
//
//   Future<void> _shareMoment() async {
//     ProgressDialog.show2("Please wait...");
//     final moment = widget.moment;
//     List<XFile> files = [];
//
//     for (final relativePath in [...photoPaths, ...videoPaths]) {
//       final fullPath = await StorageService.getFullPath(relativePath);
//       final file = File(fullPath);
//       if (await file.exists()) {
//         files.add(XFile(fullPath));
//       }
//     }
//
//     final text = [
//       if (moment.title?.isNotEmpty ?? false) 'Title: ${moment.title}',
//       if (moment.note.isNotEmpty) 'Note: ${moment.note}',
//       if (moment.caption?.isNotEmpty ?? false) 'Caption: ${moment.caption}',
//       if (moment.hasLocation)
//         'Location: ${moment.lat.toStringAsFixed(4)}, ${moment.lng.toStringAsFixed(4)}',
//     ].join('\n\n');
//
//     if (files.isNotEmpty) {
//       ProgressDialog.dismiss2();
//       await Share.shareXFiles(files, text: text);
//     } else {
//       ProgressDialog.dismiss2();
//       await Share.share(text);
//     }
//   }
//
//   Future<void> _confirmDelete() async {
//     bool confirm = false;
//
//     await showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         backgroundColor: const Color(0xff1F232F),
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
//         title: AutoSizeText(
//           'Delete Note',
//           textAlign: TextAlign.center,
//           style: TextStyle(
//             fontSize: 60.sp,
//             fontFamily: fontFamilyBold,
//             color: Colors.white,
//           ),
//         ),
//         content: AutoSizeText(
//           'Are you sure you want to delete this note?',
//           textAlign: TextAlign.center,
//           style: TextStyle(
//             fontSize: 50.sp,
//             fontFamily: fontFamilyBold,
//             color: Colors.white,
//           ),
//         ),
//         actionsAlignment: MainAxisAlignment.spaceAround,
//         actions: [
//           PressUnpress(
//             onTap: () => Navigator.of(context).pop(),
//             width: 400.w,
//             height: 140.h,
//             pressLinearGradient: pressLinearGradiant,
//             unPressLinearGradient: unPressLinearGradiant,
//             child: Center(
//               child: AutoSizeText(
//                 "Cancel",
//                 style: TextStyle(
//                   color: textColor,
//                   fontSize: 50.sp,
//                   fontFamily: fontFamilyMedium,
//                 ),
//               ),
//             ),
//           ),
//           PressUnpress(
//             onTap: () {
//               confirm = true;
//               Navigator.of(context).pop();
//             },
//             width: 400.w,
//             height: 140.h,
//             pressLinearGradient: pressLinearGradiant,
//             unPressLinearGradient: unPressLinearGradiant,
//             child: Center(
//               child: AutoSizeText(
//                 "Delete",
//                 style: TextStyle(
//                   color: textColor,
//                   fontSize: 50.sp,
//                   fontFamily: fontFamilyMedium,
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//
//     if (confirm) {
//       await widget.moment.delete();
//       Get.back();
//       Get.snackbar(
//         'Deleted',
//         'Note deleted successfully',
//         snackPosition: SnackPosition.BOTTOM,
//         backgroundColor: Colors.redAccent.withOpacity(0.8),
//         colorText: Colors.white,
//       );
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final moment = widget.moment;
//     final hasLocation = moment.hasLocation;
//
//     return Scaffold(
//       extendBodyBehindAppBar: true,
//       backgroundColor: appbackgroundColor,
//       appBar: AppBar(
//         forceMaterialTransparency: true,
//         backgroundColor: Colors.transparent,
//         elevation: 0,
//         automaticallyImplyLeading: false,
//         centerTitle: true,
//         leading: PressUnpress(
//           onTap: () => Get.back(),
//           height: 120.h,
//           width: 120.w,
//           imageAssetPress: 'assets/home_screen/back_arrow_click.png',
//           imageAssetUnPress: 'assets/home_screen/back_arrow.png',
//         ).marginAll(30.w),
//         title: AutoSizeText(
//           'Note Preview',
//           style: TextStyle(
//             color: Colors.white,
//             fontSize: 70.sp,
//             fontFamily: fontFamilySemiBold,
//           ),
//         ),
//         actions: [
//           PressUnpress(
//             onTap: () => _shareMoment(),
//             height: 120.h,
//             width: 120.w,
//             imageAssetPress: 'assets/preview_screen/share_btn_click.png',
//             imageAssetUnPress: 'assets/preview_screen/share_btn.png',
//           ).marginOnly(right: 40.w),
//           PressUnpress(
//             onTap: _confirmDelete,
//             height: 120.h,
//             width: 120.w,
//             imageAssetPress: 'assets/preview_screen/delete_btn_click.png',
//             imageAssetUnPress: 'assets/preview_screen/delete_btn.png',
//           ).marginOnly(right: 40.w),
//         ],
//       ),
//       body: Container(
//         width: 1242.w,
//         height: 2688.h,
//         decoration: const BoxDecoration(
//           image: DecorationImage(
//             image: AssetImage('assets/setting_screen/bg.png'),
//             fit: BoxFit.cover,
//           ),
//         ),
//         child: SafeArea(
//           child: Column(
//             children: [
//               Expanded(
//                 child: SingleChildScrollView(
//                   padding: EdgeInsets.all(60.w),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       if (moment.title?.isNotEmpty ?? false)
//                         AutoSizeText(
//                           moment.title!,
//                           style: TextStyle(
//                             fontSize: 60.sp,
//                             fontFamily: fontFamilyBold,
//                             color: Colors.white,
//                           ),
//                         ),
//                       SizedBox(height: 20.h),
//                       Row(
//                         children: [
//                           const Icon(
//                             Icons.access_time,
//                             color: Colors.white70,
//                             size: 20,
//                           ),
//                           SizedBox(width: 30.w),
//                           AutoSizeText(
//                             '${moment.date.day}/${moment.date.month}/${moment.date.year} at ${moment.date.hour}:${moment.date.minute.toString().padLeft(2, '0')}',
//                             style: TextStyle(
//                               color: Colors.white,
//                               fontSize: 45.sp,
//                               fontFamily: fontFamilyMedium,
//                             ),
//                           ),
//                         ],
//                       ),
//                       SizedBox(height: 60.h),
//                       if (moment.note.isNotEmpty)
//                         Container(
//                           width: double.infinity,
//                           padding: EdgeInsets.all(40.w),
//                           decoration: BoxDecoration(
//                             color: Colors.grey[900],
//                             borderRadius: BorderRadius.circular(16),
//                             border: Border.all(color: Colors.grey[700]!),
//                           ),
//                           child: AutoSizeText(
//                             moment.note,
//                             style: TextStyle(
//                               fontSize: 45.sp,
//                               fontFamily: fontFamilyMedium,
//                               color: Colors.white,
//                             ),
//                           ),
//                         ),
//                       SizedBox(height: 60.h),
//                       if (photoPaths.isNotEmpty || videoPaths.isNotEmpty)
//                         Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             AutoSizeText(
//                               'Attachments',
//                               style: TextStyle(
//                                 fontSize: 55.sp,
//                                 fontFamily: fontFamilyBold,
//                                 color: Colors.white,
//                               ),
//                             ),
//                             SizedBox(height: 40.h),
//                             GridView.builder(
//                               shrinkWrap: true,
//                               physics: const NeverScrollableScrollPhysics(),
//                               gridDelegate:
//                               const SliverGridDelegateWithFixedCrossAxisCount(
//                                 crossAxisCount: 2,
//                                 mainAxisSpacing: 12,
//                                 crossAxisSpacing: 12,
//                                 childAspectRatio: 1.2,
//                               ),
//                               itemCount: photoPaths.length + videoPaths.length,
//                               itemBuilder: (context, index) {
//                                 if (index < photoPaths.length) {
//                                   return GestureDetector(
//                                     onTap: () => Get.to(
//                                           () => ImagePreviewScreen(
//                                         moment: moment,
//                                         imageIndex: index,
//                                       ),
//                                     ),
//                                     child: _buildPhotoThumbnail(photoPaths[index]),
//                                   );
//                                 } else {
//                                   final vidIndex = index - photoPaths.length;
//                                   return GestureDetector(
//                                     onTap: () => Get.to(
//                                           () => VideoPreviewScreen(
//                                         moment: moment,
//                                         videoIndex: vidIndex,
//                                       ),
//                                     ),
//                                     child: _buildVideoThumbnail(videoPaths[vidIndex]),
//                                   );
//                                 }
//                               },
//                             ),
//                           ],
//                         ),
//                       SizedBox(height: 60.h),
//                       if (hasLocation)
//                         Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             AutoSizeText(
//                               'Location',
//                               style: TextStyle(
//                                 fontSize: 55.sp,
//                                 fontFamily: fontFamilyBold,
//                                 color: Colors.white,
//                               ),
//                             ),
//                             SizedBox(height: 40.h),
//                             ClipRRect(
//                               borderRadius: const BorderRadius.all(
//                                 Radius.circular(20),
//                               ),
//                               child: SizedBox(
//                                 height: 500.h,
//                                 child: GoogleMap(
//                                   initialCameraPosition: CameraPosition(
//                                     target: LatLng(moment.lat, moment.lng),
//                                     zoom: 15,
//                                   ),
//                                   markers: {
//                                     Marker(
//                                       markerId: const MarkerId('loc'),
//                                       position: LatLng(moment.lat, moment.lng),
//                                       icon: BitmapDescriptor.defaultMarkerWithHue(
//                                         BitmapDescriptor.hueRed,
//                                       ),
//                                     ),
//                                   },
//                                   zoomControlsEnabled: false,
//                                   myLocationButtonEnabled: false,
//                                   mapType: MapType.normal,
//                                 ),
//                               ),
//                             ),
//                           ],
//                         ),
//                     ],
//                   ),
//                 ),
//               ),
//               Obx(
//                     () => AdsVariable.isPurchase.isFalse
//                     ? BannerTemplate(
//                   bannerId: AdsVariable.banner_noteDetails_screen,
//                 ).marginOnly(top: 40.h)
//                     : const SizedBox.shrink(),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
