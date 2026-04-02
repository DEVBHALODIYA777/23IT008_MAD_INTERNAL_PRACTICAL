import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../data/reminder_provider.dart';
import '../domain/models/reminder.dart';

class RemindersScreen extends ConsumerStatefulWidget {
  const RemindersScreen({super.key});

  @override
  ConsumerState<RemindersScreen> createState() => _RemindersScreenState();
}

class _RemindersScreenState extends ConsumerState<RemindersScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  void _showAddReminderDialog() {
    final formKey = GlobalKey<FormState>();
    String title = '';
    String type = 'Oil Change';
    DateTime selectedDate = DateTime.now().add(const Duration(days: 30));
    int? durationInDays;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                top: 24,
                left: 24,
                right: 24,
              ),
              decoration: BoxDecoration(
                color: Theme.of(context).cardTheme.color,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(32),
                ),
              ),
              child: SingleChildScrollView(
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        'Add Due Renewal',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 24),
                      DropdownButtonFormField<String>(
                        value: type,
                        decoration: InputDecoration(
                          labelText: 'Type of Service',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        items:
                            [
                                  'Oil Change',
                                  'General Service',
                                  'Insurance Renewal',
                                  'Engine Wash',
                                  'Custom',
                                ]
                                .map(
                                  (e) => DropdownMenuItem(
                                    value: e,
                                    child: Text(e),
                                  ),
                                )
                                .toList(),
                        onChanged: (val) => setModalState(() => type = val!),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        decoration: InputDecoration(
                          labelText: 'Vehicle or Details',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        onSaved: (val) => title = val ?? 'My Vehicle',
                        validator: (val) =>
                            val == null || val.isEmpty ? 'Required' : null,
                      ),
                      const SizedBox(height: 16),
                      ListTile(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: const BorderSide(color: Colors.grey),
                        ),
                        title: Text(
                          'Due Date: ${selectedDate.toLocal().toString().split(' ')[0]}',
                        ),
                        trailing: const Icon(Icons.calendar_today),
                        onTap: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: selectedDate,
                            firstDate: DateTime.now(),
                            lastDate: DateTime.now().add(
                              const Duration(days: 3650),
                            ),
                          );
                          if (date != null) {
                            setModalState(() => selectedDate = date);
                          }
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        decoration: InputDecoration(
                          labelText:
                              'Renewal Duration (in Days) - exactly notifies you',
                          hintText: 'e.g. 30 for monthly',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        keyboardType: TextInputType.number,
                        onSaved: (val) {
                          if (val != null && val.isNotEmpty) {
                            durationInDays = int.tryParse(val);
                          }
                        },
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: () {
                          if (formKey.currentState!.validate()) {
                            formKey.currentState!.save();
                            final reminder = Reminder(
                              id: const Uuid().v4(),
                              vehicleId: 'default',
                              title: title,
                              type: type,
                              dueDate: selectedDate,
                              renewalDays: durationInDays,
                            );
                            ref
                                .read(remindersProvider.notifier)
                                .addReminder(reminder);
                            Navigator.pop(context);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(
                            context,
                          ).colorScheme.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: const Text('Add Due Renewal'),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final reminders = ref.watch(remindersProvider);
    final active = reminders.where((r) => !r.isCompleted).toList()
      ..sort((a, b) => a.dueDate.compareTo(b.dueDate));
    final completed = reminders.where((r) => r.isCompleted).toList()
      ..sort((a, b) => b.dueDate.compareTo(a.dueDate));

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Dues Menu',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: Theme.of(context).colorScheme.primary,
          unselectedLabelColor: Colors.grey,
          indicatorColor: Theme.of(context).colorScheme.primary,
          tabs: const [
            Tab(icon: Icon(Icons.warning), text: 'Active'),
            Tab(icon: Icon(Icons.check_circle), text: 'Completed'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildList(active, isActive: true),
          _buildList(completed, isActive: false),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddReminderDialog,
        icon: const Icon(Icons.add),
        label: const Text('Add Due Renewal'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
    );
  }

  Widget _buildList(List<Reminder> list, {required bool isActive}) {
    if (list.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isActive ? Icons.task_alt : Icons.history,
              size: 80,
              color: Colors.grey.shade300,
            ),
            const SizedBox(height: 16),
            Text(
              'No dues found in this section.',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
            ),
          ],
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: list.length,
      itemBuilder: (context, index) {
        final r = list[index];
        final daysLeft = r.dueDate.difference(DateTime.now()).inDays;

        // Determine beautiful icon based on Title heuristics (Car vs Bike)
        final isBike =
            r.title.toLowerCase().contains('bike') ||
            r.title.toLowerCase().contains('enfield') ||
            r.title.toLowerCase().contains('motorcycle');
        final vehicleIcon = isBike
            ? Icons.motorcycle
            : Icons.directions_car_filled;

        return Container(
          key: ValueKey(
            r.id,
          ), // Forces Flutter to completely rebuild when moved!
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: Theme.of(context).cardTheme.color,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isActive
                  ? (daysLeft < 5
                        ? Colors.red.withOpacity(0.3)
                        : Colors.orange.withOpacity(0.3))
                  : Colors.green.withOpacity(0.3),
            ),
            boxShadow: const [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 8,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 12,
            ),
            leading: Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isActive
                        ? (daysLeft < 5
                              ? Colors.red.withOpacity(0.1)
                              : Colors.orange.withOpacity(0.1))
                        : Colors.green.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    vehicleIcon,
                    color: isActive
                        ? (daysLeft < 5 ? Colors.red : Colors.orange)
                        : Colors.green,
                    size: 28,
                  ),
                ),
                Positioned(
                  right: -4,
                  bottom: -4,
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isActive ? Icons.error : Icons.check_circle,
                      size: 16,
                      color: isActive ? Colors.orange : Colors.green,
                    ),
                  ),
                ),
              ],
            ),
            title: Text(
              '${r.type} • ${r.title}',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 4.0),
              child: Text(
                'Due: ${r.dueDate.toLocal().toString().split(' ')[0]}' +
                    (r.renewalDays != null
                        ? '\n(Renews every ${r.renewalDays} days)'
                        : ''),
                style: TextStyle(color: Colors.grey.shade600),
              ),
            ),
            isThreeLine: r.renewalDays != null,
            trailing: isActive
                ? ElevatedButton(
                    onPressed: () {
                      ref.read(remindersProvider.notifier).markCompleted(r);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Awesome! Moved to Completed.'),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Complete'),
                  )
                : const Icon(
                    Icons.check_circle_outline,
                    color: Colors.green,
                    size: 32,
                  ),
          ),
        );
      },
    );
  }
}
