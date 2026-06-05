import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:econome/data/database/app_database.dart';
import 'package:econome/data/database/database_builder.dart';
import 'package:econome/data/database/dao/category_dao.dart';
import 'package:econome/data/database/dao/transaction_dao.dart';
import 'package:econome/data/database/dao/budget_dao.dart';
import 'package:econome/data/database/dao/savings_dao.dart';
import 'package:econome/data/database/dao/impulse_dao.dart';

part 'database_providers.g.dart';

// ─── Database Provider ───────────────────────────────────────────────
@Riverpod(keepAlive: true)
AppDatabase database(DatabaseRef ref) => buildDatabase();

// ─── DAO Providers ────────────────────────────────────────────────────
@Riverpod(keepAlive: true)
CategoryDao categoryDao(CategoryDaoRef ref) {
  return CategoryDao(ref.watch(databaseProvider));
}

@Riverpod(keepAlive: true)
TransactionDao transactionDao(TransactionDaoRef ref) {
  return TransactionDao(ref.watch(databaseProvider));
}

@Riverpod(keepAlive: true)
BudgetDao budgetDao(BudgetDaoRef ref) {
  return BudgetDao(ref.watch(databaseProvider));
}

@Riverpod(keepAlive: true)
SavingsDao savingsDao(SavingsDaoRef ref) {
  return SavingsDao(ref.watch(databaseProvider));
}

@Riverpod(keepAlive: true)
ImpulseDao impulseDao(ImpulseDaoRef ref) {
  return ImpulseDao(ref.watch(databaseProvider));
}
