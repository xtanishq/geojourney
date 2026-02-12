// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:snap_journey/controller/creation_controller.dart';
// import 'package:snap_journey/screen/common_screen/constant.dart';
// import 'package:path_provider/path_provider.dart';
//
// class AudioSaver {
//   static Future<bool> saveAudioBatch({
//     required List<File> audioFiles,
//     required List<String> texts,
//     required List<String> voices,
//     List<String>? timestamps,
//     String? summary,
//     required String type,
//   }) async {
//     try {
//       final directory = await getApplicationDocumentsDirectory();
//       final folderPath = '${directory.path}/creation';
//       await Directory(folderPath).create(recursive: true);
//
//       final safeAppName = appName.replaceAll(RegExp(r'[^\w\s-]'), '_');
//       final timestamp = DateTime.now().millisecondsSinceEpoch;
//
//       final newAudioFiles = <File>[];
//       for (var i = 0; i < audioFiles.length; i++) {
//         final audioFile = audioFiles[i];
//         final fileName = '${safeAppName}_${type}_$timestamp\_$i.mp3';
//         final newFilePath = '$folderPath/$fileName';
//         final newFile = await audioFile.copy(newFilePath);
//         newAudioFiles.add(newFile);
//       }
//
//       final creationController = Get.find<CreationController>();
//       await creationController.addNewMedia(
//         audioFiles: newAudioFiles,
//         texts: texts,
//         voices: voices,
//         timestamps: timestamps ?? [],
//         summary: summary,
//         type: type,
//       );
//
//       Get.snackbar(
//         'Success',
//         'Audio and text saved successfully',
//         snackPosition: SnackPosition.BOTTOM,
//         backgroundColor: appColor,
//         colorText: Colors.white,
//       );
//
//       return true;
//     } catch (e) {
//       Get.snackbar(
//         'Error',
//         'Failed to save audio: $e',
//         snackPosition: SnackPosition.BOTTOM,
//         backgroundColor: appColor,
//         colorText: Colors.white,
//       );
//       print('ERROR saving audio batch: $e');
//       return false;
//     }
//   }
// }
