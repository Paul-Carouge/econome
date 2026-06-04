import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:budgethink/data/database/app_database.dart';
import 'package:budgethink/data/database/database_builder.dart';
import 'package:budgethink/data/database/dao/category_dao.dart';
import 'package:budgethink/data/database/dao/transaction_dao.dart';
import 'package:budgethink/data/database/dao/budget_dao.dart';
import 'package:budgethink/data/database/dao/savings_dao.dart';
import 'package:budgethink/data/database/dao/impulse_dao.dart';

// ─── Database Provider ───────────────────────────────────────────────
final databaseProvider = Provider<AppDatabase>((ref) => buildDatabase());

// ─── DAO Providers ────────────────────────────────────────────────────
final categoryDaoProvider = Provider<CategoryDao>((ref) {
  return CategoryDao(ref.watch(databaseProvider));
});

final transactionDaoProvider = Provider<TransactionDao>((ref) {
  return TransactionDao(ref.watch(databaseProvider));
});

final budgetDaoProvider = Provider<BudgetDao>((ref) {
  return BudgetDao(ref.watch(databaseProvider));
});

final savingsDaoProvider = Provider<SavingsDao>((ref) {
  return SavingsDao(ref.watch(databaseProvider));
});

final impulseDaoProvider = Provider<ImpulseDao>((ref) {
  return ImpulseDao(ref.watch(databaseProvider));
});

// ─── Category Providers ───────────────────────────────────────────────
final expenseCategoriesProvider = StreamProvider<List<Category>>((ref) {
  return ref.watch(categoryDaoProvider).watchExpenseCategories();
});

final allCategoriesProvider = StreamProvider<List<Category>>((ref) {
  return ref.watch(categoryDaoProvider).watchAll();
});

// ─── Transaction Providers ────────────────────────────────────────────
final currentMonthProvider = StateProvider<DateTime>((ref) => DateTime.now());

final monthlyTransactionsProvider = StreamProvider<List<Transaction>>((ref) {
  final month = ref.watch(currentMonthProvider);
  return ref.watch(transactionDaoProvider).watchByMonth(month.month, month.year);
});

final recentTransactionsProvider = StreamProvider<List<Transaction>>((ref) {
  return ref.watch(transactionDaoProvider).watchRecent(5);
});

// ─── Budget Providers ─────────────────────────────────────────────────
final currentBudgetProvider = FutureProvider.autoDispose<Budget?>((ref) async {
  final now = DateTime.now();
  return ref.watch(budgetDaoProvider).getByMonth(now.month, now.year);
});

// ─── Savings Providers ────────────────────────────────────────────────
final savingsListProvider = StreamProvider<List<SavingsGoal>>((ref) {
  return ref.watch(savingsDaoProvider).watchAll();
});

// ─── Impulse Providers ────────────────────────────────────────────────
final impulseListProvider = StreamProvider<List<ImpulseItem>>((ref) {
  return ref.watch(impulseDaoProvider).watchAll();
});

final impulseCoolingProvider = StreamProvider<List<ImpulseItem>>((ref) {
  return ref.watch(impulseDaoProvider).watchByStatus('cooling');
});

final impulseActiveCountProvider = FutureProvider<int>((ref) async {
  return ref.watch(impulseDaoProvider).getActiveCount();
});

// ─── Dashboard Provider ───────────────────────────────────────────────
final dashboardDataProvider = Provider.autoDispose<DashboardData>((ref) {
  final transactions = ref.watch(monthlyTransactionsProvider);
  return transactions.when(
    data: (list) {
      double income = 0, expenses = 0;
      for (final t in list) {
        if (t.type == 'income') {
          income += t.amount;
        } else {
          expenses += t.amount;
        }
      }
      final now = DateTime.now();
      return DashboardData(
        totalIncome: income,
        totalExpenses: expenses,
        balance: income - expenses,
        month: now.month,
        year: now.year,
      );
    },
    loading: () => DashboardData(
      totalIncome: 0,
      totalExpenses: 0,
      balance: 0,
      month: 1,
      year: 2026,
    ),
    error: (_, _) => DashboardData(
      totalIncome: 0,
      totalExpenses: 0,
      balance: 0,
      month: 1,
      year: 2026,
    ),
  );
});

class DashboardData {
  final double totalIncome;
  final double totalExpenses;
  final double balance;
  final int month;
  final int year;

  DashboardData({
    required this.totalIncome,
    required this.totalExpenses,
    required this.balance,
    required this.month,
    required this.year,
  });
}
