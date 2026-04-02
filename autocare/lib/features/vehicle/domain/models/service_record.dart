import 'package:hive/hive.dart';

class ServiceRecord {
  final String id;
  final String vehicleId;
  final DateTime date;
  final String serviceType;
  final String notes;
  final double cost;

  ServiceRecord({
    required this.id,
    required this.vehicleId,
    required this.date,
    required this.serviceType,
    required this.notes,
    required this.cost,
  });
}

class ServiceRecordAdapter extends TypeAdapter<ServiceRecord> {
  @override
  final int typeId = 1;

  @override
  ServiceRecord read(BinaryReader reader) {
    return ServiceRecord(
      id: reader.read(),
      vehicleId: reader.read(),
      date: reader.read(),
      serviceType: reader.read(),
      notes: reader.read(),
      cost: reader.read(),
    );
  }

  @override
  void write(BinaryWriter writer, ServiceRecord obj) {
    writer.write(obj.id);
    writer.write(obj.vehicleId);
    writer.write(obj.date);
    writer.write(obj.serviceType);
    writer.write(obj.notes);
    writer.write(obj.cost);
  }
}
