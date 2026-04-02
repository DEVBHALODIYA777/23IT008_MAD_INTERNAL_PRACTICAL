import 'package:hive/hive.dart';

class Vehicle {
  final String id;
  final String name;
  final String model;
  final String registrationNumber;
  final String fuelType;
  final DateTime purchaseDate;
  final DateTime? lastServiceDate;

  Vehicle({
    required this.id,
    required this.name,
    required this.model,
    required this.registrationNumber,
    required this.fuelType,
    required this.purchaseDate,
    this.lastServiceDate,
  });
}

class VehicleAdapter extends TypeAdapter<Vehicle> {
  @override
  final int typeId = 0;

  @override
  Vehicle read(BinaryReader reader) {
    return Vehicle(
      id: reader.read(),
      name: reader.read(),
      model: reader.read(),
      registrationNumber: reader.read(),
      fuelType: reader.read(),
      purchaseDate: reader.read(),
      lastServiceDate: reader.read(),
    );
  }

  @override
  void write(BinaryWriter writer, Vehicle obj) {
    writer.write(obj.id);
    writer.write(obj.name);
    writer.write(obj.model);
    writer.write(obj.registrationNumber);
    writer.write(obj.fuelType);
    writer.write(obj.purchaseDate);
    writer.write(obj.lastServiceDate);
  }
}
