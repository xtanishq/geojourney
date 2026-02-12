// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'TimelineGroup.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TimelineGroupAdapter extends TypeAdapter<TimelineGroup> {
  @override
  final int typeId = 1;

  @override
  TimelineGroup read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TimelineGroup(
      date: fields[0] as DateTime,
      moments: (fields[1] as List).cast<Moment>(),
      place: fields[2] as String?,
      summary: fields[3] as String?,
      colorValue: fields[4] as int?,
    );
  }

  @override
  void write(BinaryWriter writer, TimelineGroup obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.date)
      ..writeByte(1)
      ..write(obj.moments)
      ..writeByte(2)
      ..write(obj.place)
      ..writeByte(3)
      ..write(obj.summary)
      ..writeByte(4)
      ..write(obj.colorValue);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TimelineGroupAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
