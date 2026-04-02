import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../vehicle/data/vehicle_provider.dart';
import '../../vehicle/presentation/add_vehicle_screen.dart';
import '../../reminders/data/reminder_provider.dart';
import '../../expenses/data/expense_provider.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vehicles = ref.watch(vehiclesProvider);
    final expenses = ref.watch(expensesProvider);
    final reminders = ref.watch(remindersProvider);

    final totalExpenses = expenses.fold(0.0, (sum, i) => sum + i.amount);
    
    // Sort active reminders by due date
    final activeReminders = reminders.where((r) => !r.isCompleted).toList()
      ..sort((a,b) => a.dueDate.compareTo(b.dueDate));

    return Scaffold(
      appBar: AppBar(
        title: const Text('AutoCare Dashboard', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Add Vehicle',
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const AddVehicleScreen()));
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(24.0),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF0F62FE), Color(0xFF4589FF)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: const [
                  BoxShadow(color: Color(0x660F62FE), blurRadius: 15, spreadRadius: 2, offset: Offset(0, 5)),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Total Expenses (Monthly)', style: TextStyle(fontSize: 14, color: Colors.white70, fontWeight: FontWeight.w500)),
                  const SizedBox(height: 8),
                  Text('\$ ${totalExpenses.toStringAsFixed(2)}', style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: -0.5)),
                ],
              ),
            ),
            const SizedBox(height: 32),
            const Text('Action Needed', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            
            if (activeReminders.isEmpty)
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardTheme.color,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.grey.withOpacity(0.1)),
                ),
                child: const Text('All caught up! No active dues.', style: TextStyle(color: Colors.grey)),
              )
            else
              Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).cardTheme.color,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.orange.withOpacity(0.3), width: 1.5),
                  boxShadow: const [
                    BoxShadow(color: Colors.black12, blurRadius: 10, spreadRadius: 1, offset: Offset(0, 4)),
                  ],
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  leading: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: Colors.orange.withOpacity(0.15), shape: BoxShape.circle),
                    child: const Icon(Icons.warning_amber_rounded, color: Colors.orange),
                  ),
                  title: Text(activeReminders.first.type, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('${activeReminders.first.title} • Due: ${activeReminders.first.dueDate.toLocal().toString().split(' ')[0]}'),
                  trailing: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    ),
                    onPressed: () {
                      ref.read(remindersProvider.notifier).markCompleted(activeReminders.first);
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Marked as done and rescheduled if recurring')));
                    },
                    child: const Text('Done'),
                  ),
                ),
              ),

            const SizedBox(height: 32),
            const Text('My Garage', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Expanded(
              child: vehicles.isEmpty 
                  ? Center(child: Text('No vehicles added yet. Pull into the garage!', style: TextStyle(color: Colors.grey.shade600)))
                  : ListView.builder(
                      itemCount: vehicles.length,
                      itemBuilder: (context, index) {
                        final v = vehicles[index];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            color: Theme.of(context).cardTheme.color,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 2))],
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.all(16),
                            leading: Container(
                              height: 60,
                              width: 60,
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Icon(Icons.directions_car, color: Theme.of(context).colorScheme.primary, size: 32),
                            ),
                            title: Text(v.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                            subtitle: Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Text('${v.model} • ${v.registrationNumber}', style: TextStyle(color: Colors.grey.shade600)),
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                              onPressed: () {
                                ref.read(vehiclesProvider.notifier).deleteVehicle(v.id);
                              },
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
