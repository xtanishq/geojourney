// lib/model/TimelineGroup.dart
import 'dart:ui';
import 'package:hive/hive.dart';
import 'package:snap_journey/model/moment.dart';

part 'TimelineGroup.g.dart';

@HiveType(typeId: 1)
class TimelineGroup extends HiveObject {
  @HiveField(0)
  DateTime date;

  @HiveField(1)
  List<Moment> moments;

  @HiveField(2)
  String? place;

  @HiveField(3)
  String? summary;

  @HiveField(4)
  int? colorValue;

  TimelineGroup({
    required this.date,
    required this.moments,
    this.place,
    this.summary,
    this.colorValue,
  });

  Color? get color => colorValue != null ? Color(colorValue!) : null;

  void setColor(Color c) {
    colorValue = c.value;
  }
}