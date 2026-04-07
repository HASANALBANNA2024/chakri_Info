// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'question_bank_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class QuestionBankModelAdapter extends TypeAdapter<QuestionBankModel> {
  @override
  final int typeId = 1;

  @override
  QuestionBankModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return QuestionBankModel(
      title: (fields[0] as String?) ?? 'Untitled',
      question: (fields[1] as String?) ?? '',
      options: (fields[2] as List?)?.cast<String>(),
      answer: (fields[3] as String?) ?? '',
      explanation: fields[4] as String?,
      type: (fields[5] as String?) ?? 'MCQ',
    );
  }

  @override
  void write(BinaryWriter writer, QuestionBankModel obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.title)
      ..writeByte(1)
      ..write(obj.question)
      ..writeByte(2)
      ..write(obj.options)
      ..writeByte(3)
      ..write(obj.answer)
      ..writeByte(4)
      ..write(obj.explanation)
      ..writeByte(5)
      ..write(obj.type);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is QuestionBankModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
