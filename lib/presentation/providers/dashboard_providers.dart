import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:econome/presentation/providers/transaction_providers.dart';

part 'dashboard_providers.g.dart';

// ─── Dashboard Data ───────────────────────────────────────────────────

/// Données calculées pour le tableau de bord.
///
/// NE doit PAS avaler les erreurs : les états loading et error sont
/// propagés pour que l'UI puisse réagir correctement.
@riverpod
DashboardData dashboardData(DashboardDataRef ref) {
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
    loading: () => throw const AsyncLoading(),
    error: (e, st) => throw e,
  );
}

/// Valeur du tableau de bord.
class DashboardData {
  final double totalIncome;
  final double totalExpenses;
  final double balance;
  final int month;
  final int year;

  const DashboardData({
    required this.totalIncome,
    required this.totalExpenses,
    required this.balance,
    required this.month,
    required this.year,
  });
}
