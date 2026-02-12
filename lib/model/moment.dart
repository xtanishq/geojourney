import 'dart:convert';
import 'dart:ui';
import 'package:hive/hive.dart';

part 'moment.g.dart';

@HiveType(typeId: 0)
class Moment extends HiveObject {
  @HiveField(0)
  DateTime date;

  @HiveField(1)
  double lat;

  @HiveField(2)
  double lng;

  @HiveField(3)
  String note;

  @HiveField(4)
  String? title;

  @HiveField(5)
  String? photoPathsJson;

  @HiveField(6)
  String? videoPathsJson;

  @HiveField(7)
  String? caption;

  @HiveField(8)
  String? collection;

  @HiveField(9)
  int? colorValue;

  @HiveField(10)
  bool isNote;

  @HiveField(11)
  bool hasLocation;

  Moment({
    required this.date,
    required this.lat,
    required this.lng,
    required this.note,
    this.title,
    this.photoPathsJson,
    this.videoPathsJson,
    this.caption,
    this.collection,
    this.colorValue,
    this.isNote = false,
    this.hasLocation = false,
  });

  Color? get color => colorValue != null ? Color(colorValue!) : null;

  void setColor(Color c) {
    colorValue = c.value;
  }

  List<String> get photoPaths => photoPathsJson != null
      ? List<String>.from(jsonDecode(photoPathsJson!))
      : <String>[];

  List<String> get videoPaths => videoPathsJson != null
      ? List<String>.from(jsonDecode(videoPathsJson!))
      : <String>[];

  set photoPaths(List<String> paths) {
    photoPathsJson = jsonEncode(paths);
  }

  set videoPaths(List<String> paths) {
    videoPathsJson = jsonEncode(paths);
  }

  bool get hasMedia => photoPaths.isNotEmpty || videoPaths.isNotEmpty;

  String get mediaType => photoPaths.isNotEmpty ? 'photo' : 'video';

  String get previewPath => photoPaths.isNotEmpty
      ? photoPaths.first
      : (videoPaths.isNotEmpty ? videoPaths.first : '');
}
