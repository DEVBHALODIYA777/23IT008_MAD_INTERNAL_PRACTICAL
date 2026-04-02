import 'package:hive_flutter/hive_flutter.dart';
import '../../features/vehicle/domain/models/vehicle.dart';
import '../../features/vehicle/domain/models/service_record.dart';
import '../../features/expenses/domain/models/expense.dart';
import '../../features/reminders/domain/models/reminder.dart';

class HiveManager {
  static Future<void> init() async {
    await Hive.initFlutter();
    
    // Register Adapters
    Hive.registerAdapter(VehicleAdapter());
    Hive.registerAdapter(ServiceRecordAdapter());
    Hive.registerAdapter(ExpenseAdapter());
    Hive.registerAdapter(ReminderAdapter());
    
    // Open boxes
    await Hive.openBox<Vehicle>('vehicles_v2');
    await Hive.openBox<ServiceRecord>('service_records_v2');
    await Hive.openBox<Expense>('expenses_v2');
    await Hive.openBox<Reminder>('reminders_v2');
  }

  static Box<Vehicle> get vehiclesBox => Hive.box<Vehicle>('vehicles_v2');
  static Box<ServiceRecord> get serviceRecordsBox => Hive.box<ServiceRecord>('service_records_v2');
  static Box<Expense> get expensesBox => Hive.box<Expense>('expenses_v2');
  static Box<Reminder> get remindersBox => Hive.box<Reminder>('reminders_v2');
}
