// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'NotificationPlan.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class NotificationPlanAdapter extends TypeAdapter<NotificationPlan> {
  @override
  final int typeId = 10;

  @override
  NotificationPlan read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return NotificationPlan()
      ..date = fields[0] as DateTime
      ..notificationId = fields[1] as int
      ..title = fields[2] as String
      ..body = fields[3] as String
      ..payload = fields[4] as String
      ..isMemory = fields[5] as bool
      ..hour = fields[6] as int;
  }

  @override
  void write(BinaryWriter writer, NotificationPlan obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.date)
      ..writeByte(1)
      ..write(obj.notificationId)
      ..writeByte(2)
      ..write(obj.title)
      ..writeByte(3)
      ..write(obj.body)
      ..writeByte(4)
      ..write(obj.payload)
      ..writeByte(5)
      ..write(obj.isMemory)
      ..writeByte(6)
      ..write(obj.hour);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NotificationPlanAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
