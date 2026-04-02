import 'package:hive/hive.dart';

class Reminder {
  final String id;
  final String vehicleId;
  final String title;
  final String type; // Oil Change, General Service, Insurance Renewal, Custom
  final DateTime dueDate;
  final bool isCompleted;
  final int? renewalDays;

  Reminder({
    required this.id,
    required this.vehicleId,
    required this.title,
    required this.type,
    required this.dueDate,
    this.isCompleted = false,
    this.renewalDays,
  });

  Reminder copyWith({bool? isCompleted}) {
    return Reminder(
      id: id,
      vehicleId: vehicleId,
      title: title,
      type: type,
      dueDate: dueDate,
      isCompleted: isCompleted ?? this.isCompleted,
      renewalDays: renewalDays,
    );
  }
}

class ReminderAdapter extends TypeAdapter<Reminder> {
  @override
  final int typeId = 3;

  @override
  Reminder read(BinaryReader reader) {
    final fieldsCount = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < fieldsCount; i++) reader.readByte(): reader.read(),
    };
    return Reminder(
      id: fields[0] as String,
      vehicleId: fields[1] as String,
      title: fields[2] as String,
      type: fields[3] as String,
      dueDate: fields[4] as DateTime,
      isCompleted: fields[5] as bool,
      renewalDays: fields[6] as int?,
    );
  }

  @override
  void write(BinaryWriter writer, Reminder obj) {
    writer.writeByte(7);
    writer.writeByte(0);
    writer.write(obj.id);
    writer.writeByte(1);
    writer.write(obj.vehicleId);
    writer.writeByte(2);
    writer.write(obj.title);
    writer.writeByte(3);
    writer.write(obj.type);
    writer.writeByte(4);
    writer.write(obj.dueDate);
    writer.writeByte(5);
    writer.write(obj.isCompleted);
    writer.writeByte(6);
    writer.write(obj.renewalDays);
  }
}
