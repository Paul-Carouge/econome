import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:econome/data/database/app_database.dart';
import 'package:econome/data/database/database_builder.dart';
import 'package:econome/data/database/dao/category_dao.dart';
import 'package:econome/data/database/dao/transaction_dao.dart';
import 'package:econome/data/database/dao/budget_dao.dart';
import 'package:econome/data/database/dao/savings_dao.dart';
import 'package:econome/data/database/dao/impulse_dao.dart';
import 'package:econome/data/repositories/category_repository.dart';
import 'package:econome/data/repositories/transaction_repository.dart';
import 'package:econome/data/repositories/budget_repository.dart';
import 'package:econome/data/repositories/savings_repository.dart';
import 'package:econome/data/repositories/impulse_repository.dart';

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

// ─── Repository Providers ─────────────────────────────────────────────
@Riverpod(keepAlive: true)
CategoryRepository categoryRepository(CategoryRepositoryRef ref) {
  return CategoryRepository(ref.watch(categoryDaoProvider));
}

@Riverpod(keepAlive: true)
TransactionRepository transactionRepository(TransactionRepositoryRef ref) {
  return TransactionRepository(ref.watch(transactionDaoProvider));
}

@Riverpod(keepAlive: true)
BudgetRepository budgetRepository(BudgetRepositoryRef ref) {
  return BudgetRepository(ref.watch(budgetDaoProvider));
}

@Riverpod(keepAlive: true)
SavingsRepository savingsRepository(SavingsRepositoryRef ref) {
  return SavingsRepository(ref.watch(savingsDaoProvider));
}

@Riverpod(keepAlive: true)
ImpulseRepository impulseRepository(ImpulseRepositoryRef ref) {
  return ImpulseRepository(ref.watch(impulseDaoProvider));
}

// ─── Data Reset ───────────────────────────────────────────────────────
/// Clears all data from all tables.
Future<void> clearAllData(AppDatabase db) async {
  await db.transaction(() async {
    await db.delete(db.savingsGoals).go();
    await db.delete(db.budgets).go();
    await db.delete(db.transactions).go();
    await db.delete(db.impulseItems).go();
  });
}
