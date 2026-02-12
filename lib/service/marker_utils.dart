// marker_utils.dart
import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:snap_journey/screen/common_screen/constant.dart';
import 'package:snap_journey/service/StorageService.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

class MarkerUtils {
  static final Map<String, BitmapDescriptor> _cache = {};

  static Future<BitmapDescriptor> createCustomMarker({
    required String? previewPath,
    required String? caption,
    required bool isVideo,
    double width = 180,
  }) async {
    final cacheKey = '$previewPath|$caption|$isVideo';
    if (_cache.containsKey(cacheKey)) {
      return _cache[cacheKey]!;
    }

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final size = Size(width, 180);
    final paint = Paint();

    // Background (white with shadow effect via border)
    final bgRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Radius.circular(24.r),
    );
    canvas.drawRRect(bgRect, paint..color = Colors.white);

    // Shadow (soft)
    canvas.drawRRect(
      bgRect,
      Paint()
        ..color = Colors.black.withOpacity(0.15)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, 6),
    );

    // Image container
    final imageRect = Rect.fromLTWH(0, 0, width, 110);
    final clipRRect = RRect.fromRectAndRadius(
      imageRect,
      Radius.circular(20.r),
    );

    ui.Image? image;
    if (previewPath != null && previewPath.isNotEmpty) {
      try {
        String fullPath;

        if (previewPath.startsWith('http')) {
          final response = await http.get(Uri.parse(previewPath));
          if (response.statusCode == 200 && response.bodyBytes.isNotEmpty) {
            fullPath = await _saveTempImage(response.bodyBytes);
          } else {
            fullPath = '';
          }
        } else {
          fullPath = await StorageService.getFullPath(previewPath);
        }

        if (fullPath.isNotEmpty && await File(fullPath).exists()) {
          final bytes = await File(fullPath).readAsBytes();
          if (bytes.isNotEmpty) {
            if (isVideo) {
              // Generate thumbnail for video
              final thumbPath = await _generateVideoThumbnail(fullPath);
              if (thumbPath != null && await File(thumbPath).exists()) {
                final thumbBytes = await File(thumbPath).readAsBytes();
                image = await decodeImageFromList(thumbBytes);
              }
            } else {
              // It's an image
              image = await decodeImageFromList(bytes);
            }
          }
        }
      } catch (e) {
        debugPrint('Marker image decode error: $e');
      }
    }

    // Draw image or placeholder
    if (image != null) {
      canvas.save();
      canvas.clipRRect(clipRRect);
      paintImage(
        canvas: canvas,
        rect: imageRect,
        image: image,
        fit: BoxFit.cover,
      );
      canvas.restore();

      // Dark overlay for text contrast
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(0, 70, width, 40),
          Radius.circular(20.r),
        ),
        Paint()..color = Colors.black.withOpacity(0.4),
      );
    } else {
      // Placeholder
      canvas.drawRRect(
        clipRRect,
        paint..color = Colors.grey[300]!,
      );
      final iconPaint = Paint()..color = Colors.grey[600]!;
      final path = Path()
        ..moveTo(width * 0.3, 50)
        ..lineTo(width * 0.7, 50)
        ..lineTo(width * 0.7, 80)
        ..lineTo(width * 0.3, 80)
        ..close();
      canvas.drawPath(path, iconPaint);
    }

    // Caption
    final textPainter = TextPainter(
      text: TextSpan(
        text: caption ?? 'No caption',
        style: TextStyle(
          fontSize: 38.sp,
          color: Colors.white,
          fontFamily: fontFamilyBold,
          shadows: [
            Shadow(
              offset: Offset(0, 1),
              blurRadius: 2,
              color: Colors.black.withOpacity(0.6),
            ),
          ],
        ),
      ),
      textDirection: TextDirection.ltr,
      maxLines: 2,
      ellipsis: '...',
    );
    textPainter.layout(maxWidth: width - 20);
    textPainter.paint(canvas, Offset(10, 75));

    // Tail (triangle below)
    final tailPath = Path()
      ..moveTo(width / 2 - 15, size.height)
      ..lineTo(width / 2 + 15, size.height)
      ..lineTo(width / 2, size.height + 25)
      ..close();
    canvas.drawPath(tailPath, paint..color = Colors.white);
    canvas.drawShadow(tailPath, Colors.black, 3, false);

    final picture = recorder.endRecording();
    final img = await picture.toImage(width.toInt(), (size.height + 25).toInt());
    final byteData = await img.toByteData(format: ui.ImageByteFormat.png);
    final pngBytes = byteData!.buffer.asUint8List();

    final descriptor = BitmapDescriptor.fromBytes(pngBytes);
    _cache[cacheKey] = descriptor;
    return descriptor;
  }

  // Helper: Save network image temporarily
  static Future<String> _saveTempImage(List<int> bytes) async {
    final tempDir = await getTemporaryDirectory();
    final file = File('${tempDir.path}/marker_${DateTime.now().millisecondsSinceEpoch}.jpg');
    await file.writeAsBytes(bytes);
    return file.path;
  }

  // Helper: Generate video thumbnail
  static Future<String?> _generateVideoThumbnail(String videoPath) async {
    try {
      final thumbDir = (await getTemporaryDirectory()).path;
      final videoName = path.basenameWithoutExtension(videoPath);
      final thumbPath = path.join(thumbDir, '${videoName}_thumb.png');

      if (await File(thumbPath).exists()) return thumbPath;

      final generated = await VideoThumbnail.thumbnailFile(
        video: videoPath,
        thumbnailPath: thumbDir,
        imageFormat: ImageFormat.PNG,
        maxHeight: 400,
        quality: 85,
      );

      if (generated != null && await File(generated).exists()) {
        await File(generated).rename(thumbPath);
        return thumbPath;
      }
    } catch (e) {
      debugPrint('Thumbnail gen failed: $e');
    }
    return null;
  }
}