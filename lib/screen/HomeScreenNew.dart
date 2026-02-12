import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:snap_journey/permission/permission_view.dart';
import 'package:snap_journey/screen/MapScreen.dart';
import 'package:snap_journey/screen/MemoriesScreen.dart';
import 'package:snap_journey/screen/TimelineScreen.dart';
import 'package:snap_journey/screen/common_screen/constant.dart';
import 'package:snap_journey/service/sharedPreferencesService.dart';

import '../controller/Cameracontroller.dart';
import '../google_ads_material/ads_variable.dart';
import '../in_app_purchase/app.dart';
import '../service/HapticService.dart';
import '../service/press_unpress.dart';
import 'CameraScreen.dart';
import 'common_screen/setting_screen.dart';

class Homescreennew extends StatelessWidget {
  const Homescreennew({super.key});


  Future _home1btn()async{
    bool permissionss =
        await SharedPreferencesService.getPermission();
    if (permissionss) {
      Get.toNamed('/CameraScreen');
    } else {
      Get.to(() => PermissionView(fromcamera: true,));
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        actions: [
          40.horizontalSpace,
          AutoSizeText(
            '${appName.substring(0, 10)}'.tr,
            style: TextStyle(
              color: Colors.black,
              fontFamily: "medium",
              fontWeight: FontWeight.w900,
              fontSize: 65.sp,
            ),
          ),
          Spacer(),
          Obx(
            () => AdsVariable.isPurchase.isFalse
                ? Container(
                    padding: EdgeInsetsGeometry.all(4),
                    decoration: BoxDecoration(
                      color: appColor.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(23),
                    ),
                    child: Row(
                      children: [
                        20.horizontalSpace,
                        PressUnpress(
                          width: 80.w,
                          height: 80.h,

                          onTap: () {
                            Get.to(
                              const UpsellScreen(item: true),
                              transition: Transition.fadeIn,
                            );
                          },
                          imageAssetPress: 'assets/premium_screen/prem.png',
                          imageAssetUnPress: 'assets/premium_screen/prem.png',
                        ),
                        15.horizontalSpace,
                        AutoSizeText("Pro".tr, style: TextStyle(color: Colors.white)),
                        20.horizontalSpace,
                      ],
                    ),
                  )
                : const SizedBox(),
          ),

          IconButton(
            onPressed: () {
              Get.to(
                () => SettingScreen(data: ''),
                transition: Transition.fadeIn,
              );
            },
            icon: Icon(Icons.settings),
          ),
        ],

        forceMaterialTransparency: true,
      ),

      body: Container(
        width: 1242.w,
        height: 2688.h,
        decoration: BoxDecoration(
          // image: DecorationImage(image: AssetImage("assets/newfies/bg.png"),fit: BoxFit.cover)
        ),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              25.verticalSpace,
              Stack(
                alignment: AlignmentGeometry.bottomRight,
                children: [
                  Center(
                    child: PressUnpress(
                      width: 1141.w,
                      height: 950.h,
                      onTap: () async {
                       _home1btn();
                      },
                      imageAssetPress: "assets/newfies/home1.png",
                      imageAssetUnPress: "assets/newfies/home1.png",
                    ),
                  ),
                  Align(
                    alignment: Alignment.bottomCenter,

                    child: Padding(
                      padding:  EdgeInsets.only(right: 55.w),
                      child: GestureDetector(
                        onTap: ()async{
                          _home1btn();
                        },
                        child: Column(
                          children: [
                            AutoSizeText(
                              "Time & Place Captured".tr,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 68.sp,
                                fontFamily: "medium",
                                color: Colors.white,
                              ),
                            ),
                            40.verticalSpace,
                      Container(
                                padding: EdgeInsets.all(6),
                                width: 550.w,
                                decoration: BoxDecoration(

                                  color: Colors.green.shade50.withOpacity(0.3),
                                  borderRadius: BorderRadius.circular(27),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.videocam,color: Colors.white,),
                                    30.horizontalSpace,
                                    AutoSizeText(
                                      "Click me ".tr,
                                      style: TextStyle(
                                        fontSize: 50.sp,
                                        fontFamily: "Bold",
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            
                            40.verticalSpace
                          ],
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 100.h,
                    right: 130.w,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        CircleAvatar(backgroundColor: Colors.green,radius: 6,),
                        30.horizontalSpace,
                        AutoSizeText("Wind: 10km/h".tr)
                      ],
                    ),
                  ),
                ],
              ),
              30.verticalSpace,
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Stack(
                      alignment: AlignmentGeometry.bottomCenter,

                      children: [
                        PressUnpress(
                          width: 555.w,
                          height: 562.h,
                          onTap: () async {
                            HapticService.selection();

                            bool permissionss =
                                await SharedPreferencesService.getPermission();
                            if (permissionss) {
                              Get.to(() => MapScreen());
                            } else {
                              Get.to(() => PermissionView(fromcamera: false,));
                            }
                          },
                          imageAssetUnPress: "assets/newfies/home2.png",
                          imageAssetPress: "assets/newfies/home2.png",
                        ),
                        Padding(
                          padding:  EdgeInsets.only(bottom: 40.h),
                          child: Container(
                            width: 480.w,

                            decoration: BoxDecoration(color: Colors.black.withOpacity(0.5),borderRadius: BorderRadius.only(

                              topRight: Radius.circular(20),topLeft: Radius.circular(20)
                            )),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                AutoSizeText("Travel Log".tr,textAlign: TextAlign.center,style: TextStyle(

                                    color: Colors.white,fontFamily: "medium",fontSize: 45.sp,letterSpacing: 0.7
                                ),),
                                30.verticalSpace
                              ],
                            ),
                          ),
                        ),

                      ],
                    ),



                    Column(
                      children: [
                        Stack(
                          alignment: AlignmentGeometry.bottomCenter,
                          children: [
                            PressUnpress(
                              width: 552.w,
                              height: 562.h,
                              onTap: () {
                                Get.to(() => TimelineScreen());
                              },
                              imageAssetUnPress: "assets/newfies/home3.png",
                              imageAssetPress: "assets/newfies/home3.png",
                            ),
                            GestureDetector(
                              onTap: (){
                                Get.to(() => TimelineScreen());

                              },
                              child:
                              Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(
                                    width: 552.w,
                                    // height: 150.h,
                                    child: AutoSizeText("Timeline calender".tr,
                                      maxLines: 2,

                                      // maxFontSize: 45.sp,
                                      // minFontSize: 25.sp,
                                      overflow: TextOverflow.ellipsis,
                                      wrapWords: true,
                                      textAlign: TextAlign.start,style: TextStyle(

                                        color: Colors.white,fontFamily: "medium",letterSpacing: 0.7,overflow: TextOverflow.ellipsis,
                                    ),),
                                  ),
                                  10.verticalSpace,
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,

                                    children: [
                                      Icon(Icons.calendar_month,color: Colors.yellow,size: 10,),
                                      20.horizontalSpace,
                                      AutoSizeText("View History".tr,textAlign: TextAlign.start,style: TextStyle(

                                          color: Colors.yellow,fontFamily: "light",fontSize: 35.sp,letterSpacing: 0.7
                                      ),),
                                    ],
                                  ),
                                  30.verticalSpace
                                ],
                              ),
                            ),

                          ],
                        ),

                      ],
                    ),
                  ],
                ),
              ),
              25.verticalSpace,
              Stack(
                alignment: AlignmentGeometry.centerLeft,
                children: [
                  Center(
                    child: PressUnpress(
                      width: 1141.w,
                      height: 650.h,
                      onTap: () {
                        Get.to(() => MemoriesScreen());
                      },
                      imageAssetUnPress: "assets/newfies/memories.png",
                      imageAssetPress: "assets/newfies/memories.png",
                    ),
                  ),
                  GestureDetector(
                    onTap: (){
                      Get.to(() => MemoriesScreen());

                    },
                    child: Align(
                      alignment: Alignment.centerLeft,

                      child: Padding(
                        padding:  EdgeInsets.only(left: 120.w,bottom: 40.h),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            AutoSizeText(
                              "Captured Moments".tr,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 62.sp,
                                fontFamily: "Bold",
                                color: Colors.white,
                              ),
                            ),AutoSizeText(
                              "Recent Captured\n Images and \nvideos".tr,

                              textAlign: TextAlign.start,
                              style: TextStyle(
                                fontSize: 47.sp,
                                fontFamily: "medium",
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}


//your travel log