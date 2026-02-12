// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:get/get.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:snap_journey/controller/NotesController.dart';
// import 'package:snap_journey/google_ads_material/InterstitialAdUtil.dart';
// import 'package:snap_journey/google_ads_material/ads_variable.dart';
// import 'package:snap_journey/in_app_purchase/app.dart';
// import 'package:snap_journey/screen/common_screen/constant.dart';
// import 'package:snap_journey/service/checkConnectivity.dart';
// import 'package:snap_journey/service/dialog.dart';
// import 'package:snap_journey/service/press_unpress.dart';
// import 'package:snap_journey/service/sharedPreferencesService.dart';
//
// class NotesScreen extends StatelessWidget {
//   const NotesScreen({super.key});
//
//   void back(BuildContext context) {
//     InterstitialAdManager.showInterstitial(
//       onAdDismissed: () {
//         Get.back();
//       },
//       id: AdsVariable.fullscreen_notes_screen,
//       isContinue: AdsVariable.notes_screen_ad_continue_ads_online,
//       flag: AdsVariable.notesFlag,
//       context: context,
//     );
//
//     AdsVariable.notesFlag++;
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final notesController = Get.put(NotesController());
//     final titleController = TextEditingController();
//     final contentController = TextEditingController();
//
//     return GestureDetector(
//       onTap: () {
//         notesController.tittleFocusNode.unfocus();
//         notesController.contentFocusNode.unfocus();
//       },
//       child: Scaffold(
//         extendBodyBehindAppBar: true,
//         extendBody: true,
//         backgroundColor: Colors.transparent,
//         resizeToAvoidBottomInset: false,
//         appBar: AppBar(
//           forceMaterialTransparency: true,
//           backgroundColor: Colors.transparent,
//           elevation: 0,
//           automaticallyImplyLeading: false,
//           centerTitle: true,
//           leading: PressUnpress(
//             onTap: () {
//               back(context);
//             },
//             height: 120.h,
//             width: 120.w,
//             imageAssetPress: 'assets/home_screen/back_arrow_click.png',
//             imageAssetUnPress: 'assets/home_screen/back_arrow.png',
//           ).marginAll(30.w),
//           title: AutoSizeText(
//             'Add Note',
//             style: TextStyle(
//               color: Colors.white,
//               fontSize: 70.sp,
//               fontFamily: fontFamilySemiBold,
//             ),
//           ),
//           actions: [
//             ValueListenableBuilder(
//               valueListenable: titleController,
//               builder: (context, _, __) {
//                 return ValueListenableBuilder(
//                   valueListenable: contentController,
//                   builder: (context, _, __) {
//                     final isEnabled =
//                         titleController.text.trim().isNotEmpty &&
//                             contentController.text.trim().isNotEmpty;
//
//                     if (!isEnabled) return const SizedBox.shrink();
//
//                     return PressUnpress(
//                       onTap: () {
//                         ConnectivityService.checkConnectivity().then((
//                             value,
//                             ) async {
//                           if (value) {
//                             if (!AdsVariable.isPurchase.value) {
//                               bool canUse =
//                               await SharedPreferencesService.canUseTool(
//                                 "notesFreeTrial",
//                                 AdsVariable.notesFreeTrial,
//                               );
//                               if (canUse) {
//                                 await SharedPreferencesService.incrementToolUsage(
//                                   "notesFreeTrial",
//                                 );
//                                 notesController.saveNote(
//                                   title: titleController.text,
//                                   content: contentController.text,
//                                 );
//                               } else {
//                                 await Navigator.push(
//                                   context,
//                                   MaterialPageRoute(
//                                     builder: (context) =>
//                                     const UpsellScreen(item: true),
//                                   ),
//                                 );
//
//                                 if (AdsVariable.isPurchase.value &&
//                                     context.mounted) {
//                                   notesController.saveNote(
//                                     title: titleController.text,
//                                     content: contentController.text,
//                                   );
//                                 }
//                                 print(
//                                   'You have used this tool the maximum allowed times.',
//                                 );
//                               }
//                             } else {
//                               notesController.saveNote(
//                                 title: titleController.text,
//                                 content: contentController.text,
//                               );
//                             }
//                           } else {
//                             DialogService.showCheckConnectivity(context);
//                           }
//                         });
//                       },
//                       height: 120.h,
//                       width: 120.w,
//                       imageAssetPress:
//                       'assets/preview_screen/save_btn_click.png',
//                       imageAssetUnPress: 'assets/preview_screen/save_btn.png',
//                     ).marginOnly(right: 40.w);
//                   },
//                 );
//               },
//             ),
//           ],
//         ),
//
//         body: WillPopScope(
//           onWillPop: () async {
//             back(context);
//             return false;
//           },
//           child: Container(
//             width: 1242.w,
//             height: 2688.h,
//             decoration: const BoxDecoration(
//               image: DecorationImage(
//                 image: AssetImage('assets/setting_screen/bg.png'),
//                 fit: BoxFit.cover,
//               ),
//             ),
//             child: Stack(
//               children: [
//                 SafeArea(
//                   child: SingleChildScrollView(
//                     padding: EdgeInsets.all(60.w),
//                     child: Column(
//                       children: [
//                         _buildTextFields(
//                           titleController,
//                           contentController,
//                           notesController.tittleFocusNode,
//                           notesController.contentFocusNode,
//                         ),
//                         40.verticalSpace,
//                         Obx(() => _buildAttachmentPreview(notesController)),
//                         200.verticalSpace,
//                       ],
//                     ),
//                   ),
//                 ),
//                 Positioned(
//                   left: 0,
//                   right: 0,
//                   bottom: 100.h,
//                   child: Align(
//                     alignment: Alignment.bottomCenter,
//                     child: _buildAttachmentOptions(notesController),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildTextFields(
//       TextEditingController title,
//       TextEditingController content,
//       FocusNode titleFocusNode,
//       FocusNode contentFocusNode,
//       ) {
//     return Container(
//       decoration: BoxDecoration(
//         color: const Color(0xff1F232F),
//         borderRadius: BorderRadius.circular(20),
//         border: Border.all(color: const Color(0xff535353)),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.3),
//             blurRadius: 8,
//             offset: const Offset(0, 4),
//           ),
//         ],
//       ),
//       padding: const EdgeInsets.all(20),
//       child: Column(
//         children: [
//           Align(
//             alignment: Alignment.centerLeft,
//             child: AutoSizeText(
//               "Tittle",
//               style: TextStyle(
//                 color: Colors.white,
//                 fontSize: 50.sp,
//                 fontFamily: fontFamilyBold,
//               ),
//             ),
//           ),
//           40.verticalSpace,
//           TextField(
//             controller: title,
//             focusNode: titleFocusNode,
//             style: const TextStyle(color: Colors.white),
//             decoration: _inputDecoration('Enter title'),
//           ),
//           40.verticalSpace,
//           Align(
//             alignment: Alignment.centerLeft,
//             child: AutoSizeText(
//               "Content",
//               style: TextStyle(
//                 color: Colors.white,
//                 fontSize: 50.sp,
//                 fontFamily: fontFamilyBold,
//               ),
//             ),
//           ),
//           40.verticalSpace,
//           TextField(
//             controller: content,
//             focusNode: contentFocusNode,
//             style: const TextStyle(color: Colors.white),
//             decoration: _inputDecoration('Write your content here...'),
//           ),
//         ],
//       ),
//     );
//   }
//
//   InputDecoration _inputDecoration(String hint) {
//     return InputDecoration(
//       hintText: hint,
//       hintStyle: const TextStyle(color: Colors.white54),
//       filled: true,
//       fillColor: const Color(0xff383A42),
//       contentPadding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
//       border: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(12),
//         borderSide: BorderSide.none,
//       ),
//       focusedBorder: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(12),
//         borderSide: BorderSide(color: appColor, width: 2.w),
//       ),
//     );
//   }
//
//   Widget _buildAttachmentPreview(NotesController controller) {
//     final images = controller.selectedImages;
//     final videos = controller.selectedVideos;
//     final thumbs = controller.videoThumbnails;
//     final location = controller.selectedLocation.value;
//
//     if (images.isEmpty && videos.isEmpty && location == null) {
//       return const SizedBox.shrink();
//     }
//
//     final mediaList = <Widget>[];
//
//     for (int i = 0; i < images.length; i++) {
//       mediaList.add(
//         _mediaGridItem(
//           Image.file(images[i], fit: BoxFit.cover),
//           onRemove: () => controller.removeImage(i),
//         ),
//       );
//     }
//
//     for (int i = 0; i < thumbs.length; i++) {
//       mediaList.add(
//         _mediaGridItem(
//           Stack(
//             alignment: Alignment.center,
//             children: [
//               Image.file(thumbs[i], fit: BoxFit.cover),
//               const Icon(Icons.play_circle_fill, color: Colors.white, size: 50),
//             ],
//           ),
//           onRemove: () => controller.removeVideo(i),
//         ),
//       );
//     }
//
//     return Container(
//       padding: EdgeInsets.all(40.w),
//       decoration: BoxDecoration(
//         color: Color(0xff1F232F),
//         borderRadius: BorderRadius.circular(20),
//         border: Border.all(color: Color(0xff535353)),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.3),
//             blurRadius: 8,
//             offset: const Offset(0, 4),
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           AutoSizeText(
//             'Attachments',
//             style: TextStyle(
//               fontSize: 50.sp,
//               fontFamily: fontFamilySemiBold,
//               color: Colors.white,
//             ),
//           ),
//           40.verticalSpace,
//           if (mediaList.isNotEmpty)
//             GridView.count(
//               crossAxisCount: 2,
//               crossAxisSpacing: 30.w,
//               mainAxisSpacing: 30.w,
//               shrinkWrap: true,
//               physics: const NeverScrollableScrollPhysics(),
//               children: mediaList,
//             ),
//           if (location != null)
//             Padding(
//               padding: EdgeInsets.only(top: 50.h),
//               child: _mediaGridItem(
//                 SizedBox(
//                   height: 550.h,
//                   child: GoogleMap(
//                     initialCameraPosition: CameraPosition(
//                       target: location,
//                       zoom: 14.5,
//                     ),
//                     markers: {
//                       Marker(
//                         markerId: const MarkerId('loc'),
//                         position: location,
//                       ),
//                     },
//                     myLocationButtonEnabled: false,
//                     myLocationEnabled: false,
//                     zoomControlsEnabled: false,
//                     liteModeEnabled: true,
//                   ),
//                 ),
//                 isMap: true,
//                 onRemove: controller.removeLocation,
//               ),
//             ),
//           40.verticalSpace,
//         ],
//       ),
//     );
//   }
//
//   Widget _mediaGridItem(
//       Widget child, {
//         required VoidCallback onRemove,
//         bool isMap = false,
//       }) {
//     return Stack(
//       children: [
//         ClipRRect(
//           borderRadius: BorderRadius.circular(20),
//           child: isMap
//               ? SizedBox(height: 550.h, width: double.infinity, child: child)
//               : AspectRatio(aspectRatio: 1, child: child),
//         ),
//         Positioned(
//           top: 30.h,
//           right: 30.w,
//           child: GestureDetector(
//             onTap: onRemove,
//             child: Container(
//               padding: const EdgeInsets.all(4),
//               decoration: const BoxDecoration(
//                 color: Colors.black54,
//                 shape: BoxShape.circle,
//               ),
//               child: const Icon(Icons.close, color: Colors.white, size: 18),
//             ),
//           ),
//         ),
//       ],
//     );
//   }
//
//   Widget _buildAttachmentOptions(NotesController controller) {
//     final attachments = [
//       {
//         'onTap': controller.pickImage,
//         'unpress': 'assets/notes_screen/img_btn.png',
//         'press': 'assets/notes_screen/img_btn_click.png',
//       },
//       {
//         'onTap': controller.pickVideo,
//         'unpress': 'assets/notes_screen/video_btn.png',
//         'press': 'assets/notes_screen/video_btn_click.png',
//       },
//       {
//         'onTap': controller.pickLocation,
//         'unpress': 'assets/notes_screen/location_btn.png',
//         'press': 'assets/notes_screen/location_btn_click.png',
//       },
//     ];
//
//     return Container(
//       height: 250.h,
//       width: 600.w,
//
//       decoration: const BoxDecoration(
//         image: DecorationImage(
//           image: AssetImage('assets/notes_screen/btn_slide.png'),
//           fit: BoxFit.fitWidth,
//           alignment: Alignment.center,
//         ),
//       ),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: attachments.asMap().entries.map((entry) {
//           final item = entry.value;
//
//           return Padding(
//             padding: EdgeInsets.symmetric(horizontal: 15.w),
//             child: PressUnpress(
//               width: 165.w,
//               height: 165.h,
//               onTap: item['onTap'] as VoidCallback,
//               imageAssetUnPress: item['unpress'] as String,
//               imageAssetPress: item['press'] as String,
//             ),
//           );
//         }).toList(),
//       ),
//     );
//   }
// }
//
//
