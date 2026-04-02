import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/models/expense.dart';
import '../../../core/database/hive_manager.dart';

final expensesProvider = NotifierProvider<ExpenseNotifier, List<Expense>>(() {
  return ExpenseNotifier();
});

class ExpenseNotifier extends Notifier<List<Expense>> {
  @override
  List<Expense> build() {
    try {
      return HiveManager.expensesBox.values.toList();
    } catch(e) {
      return [];
    }
  }

  void addExpense(Expense expense) {
    HiveManager.expensesBox.put(expense.id, expense);
    state = [...state, expense];
  }

  void deleteExpense(String id) {
    HiveManager.expensesBox.delete(id);
    state = state.where((e) => e.id != id).toList();
  }
}
