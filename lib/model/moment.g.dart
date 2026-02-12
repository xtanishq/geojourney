// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'moment.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class MomentAdapter extends TypeAdapter<Moment> {
  @override
  final int typeId = 0;

  @override
  Moment read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Moment(
      date: fields[0] as DateTime,
      lat: fields[1] as double,
      lng: fields[2] as double,
      note: fields[3] as String,
      title: fields[4] as String?,
      photoPathsJson: fields[5] as String?,
      videoPathsJson: fields[6] as String?,
      caption: fields[7] as String?,
      collection: fields[8] as String?,
      colorValue: fields[9] as int?,
      isNote: fields[10] as bool,
      hasLocation: fields[11] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, Moment obj) {
    writer
      ..writeByte(12)
      ..writeByte(0)
      ..write(obj.date)
      ..writeByte(1)
      ..write(obj.lat)
      ..writeByte(2)
      ..write(obj.lng)
      ..writeByte(3)
      ..write(obj.note)
      ..writeByte(4)
      ..write(obj.title)
      ..writeByte(5)
      ..write(obj.photoPathsJson)
      ..writeByte(6)
      ..write(obj.videoPathsJson)
      ..writeByte(7)
      ..write(obj.caption)
      ..writeByte(8)
      ..write(obj.collection)
      ..writeByte(9)
      ..write(obj.colorValue)
      ..writeByte(10)
      ..write(obj.isNote)
      ..writeByte(11)
      ..write(obj.hasLocation);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MomentAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
