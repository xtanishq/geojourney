import 'package:get/get.dart';
import 'package:snap_journey/controller/Cameracontroller.dart';

class BottomNavController extends GetxController {
  var currentIndex = 2.obs;

  Future<void> changeTabIndex(int index) async {
    if (currentIndex.value == 2) {
      final cameraCtrl = Get.find<Cameracontroller>();
      if (cameraCtrl.isRecording.value) {
        await cameraCtrl.stopVideo();
      }
    }
    currentIndex.value = index;
  }
}
