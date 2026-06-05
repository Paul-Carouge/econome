import 'package:flutter_test/flutter_test.dart';
import 'package:drift/drift.dart';
import 'package:econome/data/database/app_database.dart';
import 'package:econome/data/database/dao/category_dao.dart';
import 'package:econome/data/database/dao/transaction_dao.dart';
import '../../helpers/test_db.dart';

void main() {
  late AppDatabase db;
  late TransactionDao dao;
  late CategoryDao categoryDao;

  setUp(() {
    db = createTestDatabase();
    dao = TransactionDao(db);
    categoryDao = CategoryDao(db);
  });

  tearDown(() async {
    await db.close();
  });

  group('TransactionDao', () {
    Future<int> _createTestCategory() async {
      return await categoryDao.insert(CategoriesCompanion.insert(
        name: 'TestCat',
        icon: 'star',
        color: 0xFFFF0000,
      ));
    }

    test('watchByMonth retourne les transactions du mois', () async {
      final catId = await _createTestCategory();
      final now = DateTime.now();
      final month = now.month;
      final year = now.year;

      final stream = dao.watchByMonth(month, year);
      final future = stream.first;

      await dao.insert(TransactionsCompanion(
        amount: const Value(100.0),
        description: const Value('Test transaction'),
        date: Value(now.toIso8601String().substring(0, 10)),
        categoryId: Value(catId),
        type: const Value('expense'),
        createdAt: Value(DateTime.now().toIso8601String()),
      ));

      final transactions = await future;
      expect(transactions.length, equals(1));
      expect(transactions.first.description, equals('Test transaction'));
    });

    test('watchByMonth exclut les autres mois', () async {
      final catId = await _createTestCategory();
      final stream = dao.watchByMonth(1, 2020);
      final future = stream.first;

      await dao.insert(TransactionsCompanion(
        amount: const Value(50.0),
        description: const Value('Another month'),
        date: const Value('2024-06-15'),
        categoryId: Value(catId),
        type: const Value('expense'),
        createdAt: Value(DateTime.now().toIso8601String()),
      ));

      final transactions = await future;
      expect(transactions, isEmpty);
    });

    test('insert et getAll retournent les transactions', () async {
      final catId = await _createTestCategory();
      await dao.insert(TransactionsCompanion(
        amount: const Value(200.0),
        description: const Value('Test insert'),
        date: const Value('2024-06-01'),
        categoryId: Value(catId),
        type: const Value('income'),
        createdAt: Value(DateTime.now().toIso8601String()),
      ));

      final all = await dao.getAll();
      expect(all.length, equals(1));
      expect(all.first.amount, equals(200.0));
    });

    test('deleteEntry supprime une transaction', () async {
      final catId = await _createTestCategory();
      final id = await dao.insert(TransactionsCompanion(
        amount: const Value(50.0),
        description: const Value('To delete'),
        date: const Value('2024-06-01'),
        categoryId: Value(catId),
        type: const Value('expense'),
        createdAt: Value(DateTime.now().toIso8601String()),
      ));

      await dao.deleteEntry(id);
      final all = await dao.getAll();
      expect(all, isEmpty);
    });
  });
}
