import 'package:hive/hive.dart';
part 'NotificationPlan.g.dart';

@HiveType(typeId: 10)
class NotificationPlan extends HiveObject {
  @HiveField(0)
  late DateTime date;

  @HiveField(1)
  late int notificationId;

  @HiveField(2)
  late String title;

  @HiveField(3)
  late String body;

  @HiveField(4)
  late String payload;

  @HiveField(5)
  bool isMemory = false;

  @HiveField(6)
  int hour = 7;
}
