import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart'; // For guaranteed unique file names
import 'package:snap_journey/controller/Cameracontroller.dart';
import 'package:snap_journey/model/moment.dart';
import 'package:snap_journey/service/StorageService.dart';

class NotesController extends GetxController {
  final Cameracontroller cameraCtrl = Get.find();
  final ImagePicker picker = ImagePicker();
  final Uuid _uuid = const Uuid();

  var isLoading = false.obs;
  var selectedImages = <File>[].obs;
  var selectedVideos = <File>[].obs;
  var videoThumbnails = <File>[].obs;
  var selectedLocation = Rxn<LatLng>();
  final FocusNode tittleFocusNode = FocusNode();
  final FocusNode contentFocusNode = FocusNode();

  Future<void> pickImage() async {
    try {
      isLoading.value = true;
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        selectedImages.add(File(image.path));
        print('📸 Image selected: ${image.path}');
      } else {
        print('❌ No image selected.');
      }
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> pickVideo() async {
    try {
      isLoading.value = true;
      final XFile? video = await picker.pickVideo(source: ImageSource.gallery);
      if (video != null) {
        final vidFile = File(video.path);
        selectedVideos.add(vidFile);
        print('🎥 Video selected: ${video.path}');
        final thumbPath = await generateThumbnail(video.path);
        if (thumbPath != null) {
          videoThumbnails.add(File(thumbPath));
          print('🖼️ Thumbnail generated: $thumbPath');
        }
      } else {
        print('❌ No video selected.');
      }
    } finally {
      isLoading.value = false;
    }
  }

  static Future<String?> generateThumbnail(String videoPath) async {
    try {
      final dir = await getTemporaryDirectory();
      final thumb = await VideoThumbnail.thumbnailFile(
        video: videoPath,
        thumbnailPath: dir.path,
        imageFormat: ImageFormat.PNG,
        quality: 75,
      );
      print('✅ Thumbnail created at: $thumb');
      return thumb;
    } catch (e) {
      print('❌ Thumbnail generation error: $e');
      return null;
    }
  }

  Future<void> pickLocation() async {
    try {
      isLoading.value = true;
      await cameraCtrl.getCurrentLocation();
      final pos = cameraCtrl.currentPosition.value;
      if (pos != null) {
        selectedLocation.value = LatLng(pos.latitude, pos.longitude);
        print('📍 Location selected: ${pos.latitude}, ${pos.longitude}');
      } else {
        print('❌ No location found.');
      }
    } finally {
      isLoading.value = false;
    }
  }

  void removeImage(int index) {
    print('🗑️ Removing image: ${selectedImages[index].path}');
    selectedImages.removeAt(index);
  }

  void removeVideo(int index) {
    print('🗑️ Removing video: ${selectedVideos[index].path}');
    selectedVideos.removeAt(index);
    videoThumbnails.removeAt(index);
  }

  void removeLocation() {
    print('🗑️ Removing location');
    selectedLocation.value = null;
  }

  void clearAll() {
    print('🧹 Clearing all selections');
    selectedImages.clear();
    selectedVideos.clear();
    videoThumbnails.clear();
    selectedLocation.value = null;
  }

  Future<void> saveNote({
    required String title,
    required String content,
  }) async {
    if (title.trim().isEmpty && content.trim().isEmpty) {
      Get.snackbar(
        'Error',
        'Please enter title or content',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    try {
      isLoading.value = true;
      final dirPath = await StorageService.getMomentsDirectory();
      print('Saving files to directory: $dirPath');

      final savedImages = <String>[];
      final savedVideos = <String>[];

      for (int i = 0; i < selectedImages.length; i++) {
        final img = selectedImages[i];
        final uuid = _uuid.v4();
        final timestamp = DateTime.now().microsecondsSinceEpoch;
        final ext = path.extension(img.path);
        final fileName = "${uuid}_${timestamp}_photo_$i$ext";

        final relativePath = await StorageService.copyToPersistentDir(
          img.path,
          fileName,
        );
        if (relativePath == null) {
          print('Failed to copy image: ${img.path}');
          continue;
        }

        savedImages.add(relativePath);
        print('Image saved: $relativePath');

        try {
          if (await img.exists()) await img.delete();
        } catch (e) {
          print('Failed to delete original image: $e');
        }
      }

      for (int i = 0; i < selectedVideos.length; i++) {
        final vid = selectedVideos[i];
        final uuid = _uuid.v4();
        final timestamp = DateTime.now().microsecondsSinceEpoch;
        final ext = path.extension(vid.path);
        final fileName = "${uuid}_${timestamp}_video_$i$ext";

        final relativePath = await StorageService.copyToPersistentDir(
          vid.path,
          fileName,
        );
        if (relativePath == null) {
          print('Failed to copy video: ${vid.path}');
          continue;
        }

        savedVideos.add(relativePath);
        print('Video saved: $relativePath');

        try {
          if (await vid.exists()) await vid.delete();
        } catch (e) {
          print('Failed to delete original video: $e');
        }
      }

      final moment = Moment(
        date: DateTime.now(),
        lat: selectedLocation.value?.latitude ?? 0.0,
        lng: selectedLocation.value?.longitude ?? 0.0,
        note: content,
        title: title,
        isNote: true,
        hasLocation: selectedLocation.value != null,
      );

      moment.photoPaths = savedImages;
      moment.videoPaths = savedVideos;

      print(
        'Moment created: ${savedImages.length} photos, ${savedVideos.length} videos',
      );

      await cameraCtrl.saveMoment(moment);

      clearAll();
      Get.back();
      Get.snackbar(
        'Success',
        'Note saved with ${savedImages.length + savedVideos.length} attachments!',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e, stack) {
      Get.snackbar(
        'Error',
        'Failed to save note: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
      debugPrint('Save error: $e\n$stack');
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    tittleFocusNode.dispose();
    contentFocusNode.dispose();
    super.onClose();
  }
}
