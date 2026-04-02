import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/models/reminder.dart';
import '../../../core/database/hive_manager.dart';
import '../../../core/services/notification_service.dart';
import 'package:uuid/uuid.dart';

final remindersProvider = NotifierProvider<ReminderNotifier, List<Reminder>>(() {
  return ReminderNotifier();
});

class ReminderNotifier extends Notifier<List<Reminder>> {
  @override
  List<Reminder> build() {
    // Graceful load ignoring index corruptions if user resets schema
    try {
      return HiveManager.remindersBox.values.toList();
    } catch(e) {
      return [];
    }
  }

  Future<void> addReminder(Reminder reminder) async {
    await HiveManager.remindersBox.put(reminder.id, reminder);
    state = [...state, reminder];
    
    _schedule(reminder);
  }

  Future<void> markCompleted(Reminder reminder) async {
    final updated = reminder.copyWith(isCompleted: true);
    await HiveManager.remindersBox.put(reminder.id, updated);
    
    if (reminder.renewalDays != null && reminder.renewalDays! > 0) {
      final nextDueDate = DateTime.now().add(Duration(days: reminder.renewalDays!));
      final newReminder = Reminder(
        id: const Uuid().v4(),
        vehicleId: reminder.vehicleId,
        title: reminder.title,
        type: reminder.type,
        dueDate: nextDueDate,
        isCompleted: false,
        renewalDays: reminder.renewalDays,
      );
      await HiveManager.remindersBox.put(newReminder.id, newReminder);
      _schedule(newReminder);
      state = [...state.where((r) => r.id != reminder.id), updated, newReminder];
    } else {
      state = [...state.where((r) => r.id != reminder.id), updated];
    }
  }
  
  void _schedule(Reminder r) {
     if(r.dueDate.isAfter(DateTime.now())) {
        NotificationService.scheduleNotification(
          id: r.id.hashCode,
          title: 'Due: ${r.type}',
          body: '${r.title} needs your attention.',
          scheduledDate: r.dueDate,
        );
     }
  }

  void deleteReminder(String id) {
    HiveManager.remindersBox.delete(id);
    state = state.where((v) => v.id != id).toList();
  }
}
