import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:snap_journey/screen/common_screen/constant.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:auto_size_text/auto_size_text.dart';

class DependencyInjection {
  static void init() {
    Get.put<NetworkController>(NetworkController(), permanent: true);
  }
}

class NetworkController extends GetxController {
  final Connectivity _connectivity = Connectivity();

  @override
  void onInit() {
    super.onInit();
    // _connectivity.onConnectivityChanged.listen((event) {
    //   if (event == ConnectivityResult.none) {
    //     _updateConnectionStatus(ConnectivityResult.none);
    //   } else {
    //     _updateConnectionStatus(event);
    //     // firebaseConfigure();
    //   }
    // });
    _connectivity.onConnectivityChanged
        .listen((List<ConnectivityResult> connectivityResults) {
      if (connectivityResults.contains(ConnectivityResult.none)) {
        _updateConnectionStatus(ConnectivityResult.none);
      } else {
        _updateConnectionStatus(ConnectivityResult.mobile);
      }
    });
  }

  void _updateConnectionStatus(ConnectivityResult connectivityResult) {
    if (connectivityResult == ConnectivityResult.none) {
      Get.showSnackbar(GetSnackBar(
        messageText: const AutoSizeText(
          'PLEASE CONNECT TO THE INTERNET',
          style: TextStyle(color: Colors.black, fontSize: 14),
        ),
        isDismissible: false,
        duration: const Duration(days: 1),
        backgroundColor: appColor,
        icon: Icon(
          Icons.wifi_off,
          color: Colors.black,
          size: 45.sp,
        ),
        margin: EdgeInsets.zero,
        snackStyle: SnackStyle.GROUNDED,
        overlayBlur: 0.7,
        snackPosition: SnackPosition.BOTTOM,
      ));
    } else {
      if (Get.isSnackbarOpen) {
        Get.closeCurrentSnackbar();
      }
    }
  }
}
