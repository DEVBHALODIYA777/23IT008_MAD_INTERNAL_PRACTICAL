import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../data/expense_provider.dart';
import '../domain/models/expense.dart';
import 'package:uuid/uuid.dart';

class ExpensesScreen extends ConsumerStatefulWidget {
  const ExpensesScreen({super.key});

  @override
  ConsumerState<ExpensesScreen> createState() => _ExpensesScreenState();
}

class _ExpensesScreenState extends ConsumerState<ExpensesScreen> {
  
  void _showAddExpenseDialog() {
    final formKey = GlobalKey<FormState>();
    double amount = 0;
    String category = 'Fuel';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Monthly Expense'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                value: category,
                decoration: InputDecoration(
                  labelText: 'Category',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                ),
                items: ['Fuel', 'Service', 'Insurance', 'Repairs', 'Other']
                    .map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                onChanged: (val) => category = val!,
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Amount (\$)',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                ),
                keyboardType: TextInputType.number,
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                onSaved: (val) => amount = double.parse(val!),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                formKey.currentState!.save();
                final exp = Expense(
                  id: const Uuid().v4(),
                  vehicleId: 'default',
                  category: category,
                  amount: amount,
                  date: DateTime.now(),
                  notes: '',
                );
                ref.read(expensesProvider.notifier).addExpense(exp);
                Navigator.pop(context);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final expenses = ref.watch(expensesProvider);
    final total = expenses.fold(0.0, (sum, i) => sum + i.amount);

    Map<String, double> grouped = {};
    for (var e in expenses) {
      grouped[e.category] = (grouped[e.category] ?? 0) + e.amount;
    }

    final chartSections = grouped.keys.map((k) {
      Color c = Colors.grey;
      if (k == 'Fuel') c = Colors.blue;
      else if (k == 'Service') c = Colors.red;
      else if (k == 'Insurance') c = Colors.green;
      else if (k == 'Repairs') c = Colors.orange;

      return PieChartSectionData(
        color: c,
        value: grouped[k]!,
        title: total > 0 ? '${(grouped[k]! / total * 100).toStringAsFixed(0)}%' : '',
        radius: 60,
        titleStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
      );
    }).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Expenses Overview', style: TextStyle(fontWeight: FontWeight.bold))),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardTheme.color,
                  borderRadius: BorderRadius.circular(32),
                  boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 20, offset: Offset(0, 10))],
                ),
                child: Column(
                  children: [
                    const Text('Total Monthly Spent', style: TextStyle(fontSize: 16, color: Colors.grey, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    Text('\$${total.toStringAsFixed(2)}', style: const TextStyle(fontSize: 48, fontWeight: FontWeight.w900, letterSpacing: -1)),
                    const SizedBox(height: 32),
                    SizedBox(
                      height: 220,
                      child: expenses.isEmpty 
                        ? const Center(child: Text('No expenses added.'))
                        : PieChart(
                            PieChartData(
                              sectionsSpace: 4,
                              centerSpaceRadius: 50,
                              startDegreeOffset: -90,
                              sections: chartSections,
                            ),
                          ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final e = expenses[index];
                  IconData icon = Icons.money;
                  Color color = Colors.grey;
                  if (e.category == 'Fuel') { icon = Icons.local_gas_station; color = Colors.blue; }
                  else if (e.category == 'Service') { icon = Icons.build; color = Colors.red; }
                  else if (e.category == 'Insurance') { icon = Icons.security; color = Colors.green; }
                  else if (e.category == 'Repairs') { icon = Icons.car_repair; color = Colors.orange; }
                  
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardTheme.color,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      leading: CircleAvatar(backgroundColor: color.withOpacity(0.15), child: Icon(icon, color: color)),
                      title: Text(e.category, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text(e.date.toString().split(' ')[0]),
                      trailing: Text('\$${e.amount.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                    ),
                  );
                },
                childCount: expenses.length,
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        onPressed: _showAddExpenseDialog,
        icon: const Icon(Icons.add),
        label: const Text('Add Expense'),
      ),
    );
  }
}
