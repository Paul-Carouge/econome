import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:econome/presentation/providers/transaction_providers.dart';

// ─── Dashboard Data ───────────────────────────────────────────────────

/// Données calculées pour le tableau de bord.
///
/// NE doit PAS avaler les erreurs : les états loading et error sont
/// propagés pour que l'UI puisse réagir correctement.
final dashboardInfoProvider = Provider<DashboardInfo>((ref) {
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
      return DashboardInfo(
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
});

/// Valeur du tableau de bord.
class DashboardInfo {
  final double totalIncome;
  final double totalExpenses;
  final double balance;
  final int month;
  final int year;

  const DashboardInfo({
    required this.totalIncome,
    required this.totalExpenses,
    required this.balance,
    required this.month,
    required this.year,
  });
}
