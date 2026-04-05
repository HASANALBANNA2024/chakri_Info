// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'jobsync_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class JobSyncModelAdapter extends TypeAdapter<JobSyncModel> {
  @override
  final int typeId = 0;

  @override
  JobSyncModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return JobSyncModel(
      id: fields[0] as String,
      title: fields[1] as String,
      company: fields[2] as String,
      start: fields[3] as String,
      applyLink: fields[5] as String,
      deadline: fields[4] as String,
      logo: fields[6] as String,
      totalpost: fields[8] as String,
      circularImage: fields[7] as String,
      isGovt: fields[9] as bool,
      step1: fields[10] as String,
      step2: fields[11] as String,
      step3: fields[12] as String?,
      step4: fields[13] as String?,
      publishDate: fields[14] as String?,
      positions: (fields[15] as List?)?.cast<dynamic>(),
    );
  }

  @override
  void write(BinaryWriter writer, JobSyncModel obj) {
    writer
      ..writeByte(16)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.company)
      ..writeByte(3)
      ..write(obj.start)
      ..writeByte(4)
      ..write(obj.deadline)
      ..writeByte(5)
      ..write(obj.applyLink)
      ..writeByte(6)
      ..write(obj.logo)
      ..writeByte(7)
      ..write(obj.circularImage)
      ..writeByte(8)
      ..write(obj.totalpost)
      ..writeByte(9)
      ..write(obj.isGovt)
      ..writeByte(10)
      ..write(obj.step1)
      ..writeByte(11)
      ..write(obj.step2)
      ..writeByte(12)
      ..write(obj.step3)
      ..writeByte(13)
      ..write(obj.step4)
      ..writeByte(14)
      ..write(obj.publishDate)
      ..writeByte(15)
      ..write(obj.positions);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is JobSyncModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
