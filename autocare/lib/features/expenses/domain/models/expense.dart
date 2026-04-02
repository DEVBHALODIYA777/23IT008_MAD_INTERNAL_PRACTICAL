import 'package:hive/hive.dart';

class Expense {
  final String id;
  final String vehicleId;
  final String category; // Fuel, Service, Insurance, Repairs
  final double amount;
  final DateTime date;
  final String notes;

  Expense({
    required this.id,
    required this.vehicleId,
    required this.category,
    required this.amount,
    required this.date,
    required this.notes,
  });
}

class ExpenseAdapter extends TypeAdapter<Expense> {
  @override
  final int typeId = 2;

  @override
  Expense read(BinaryReader reader) {
    return Expense(
      id: reader.read(),
      vehicleId: reader.read(),
      category: reader.read(),
      amount: reader.read(),
      date: reader.read(),
      notes: reader.read(),
    );
  }

  @override
  void write(BinaryWriter writer, Expense obj) {
    writer.write(obj.id);
    writer.write(obj.vehicleId);
    writer.write(obj.category);
    writer.write(obj.amount);
    writer.write(obj.date);
    writer.write(obj.notes);
  }
}
