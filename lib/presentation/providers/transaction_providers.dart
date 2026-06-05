import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:econome/data/database/app_database.dart';
import 'package:econome/presentation/providers/database_providers.dart';

part 'transaction_providers.g.dart';

// ─── Current Month State ──────────────────────────────────────────────
// Utilise un Notifier pour remplacer StateProvider avec @riverpod
@riverpod
class CurrentMonth extends _$CurrentMonth {
  @override
  DateTime build() => DateTime.now();

  void setMonth(DateTime month) => state = month;
}

// ─── Transaction Providers ────────────────────────────────────────────
@riverpod
Stream<List<Transaction>> monthlyTransactions(MonthlyTransactionsRef ref) {
  final month = ref.watch(currentMonthProvider);
  return ref.watch(transactionDaoProvider).watchByMonth(month.month, month.year);
}

@riverpod
Stream<List<Transaction>> recentTransactions(RecentTransactionsRef ref) {
  return ref.watch(transactionDaoProvider).watchRecent(5);
}
