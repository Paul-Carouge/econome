import 'package:flutter_test/flutter_test.dart';
import 'package:econome/data/database/app_database.dart';
import 'package:econome/data/database/dao/category_dao.dart';
import '../../helpers/test_db.dart';

void main() {
  late AppDatabase db;
  late CategoryDao dao;

  setUp(() {
    db = createTestDatabase();
    dao = CategoryDao(db);
  });

  tearDown(() async {
    await db.close();
  });

  group('CategoryDao', () {
    test('insertDefaults() insère les catégories par défaut', () async {
      await dao.insertDefaults();
      final categories = await dao.getAll();
      expect(categories.length, greaterThan(0));
      // Vérifie qu'il y a au moins une catégorie expense et une income
      expect(categories.any((c) => c.type == 'expense'), isTrue);
      expect(categories.any((c) => c.type == 'income'), isTrue);
    });

    test('insertDefaults() est idempotent', () async {
      await dao.insertDefaults();
      final firstCount = (await dao.getAll()).length;
      await dao.insertDefaults();
      final secondCount = (await dao.getAll()).length;
      expect(firstCount, equals(secondCount));
    });

    test('getAll() retourne toutes les catégories', () async {
      await dao.insert(CategoriesCompanion.insert(
        name: 'Test',
        icon: 'star',
        color: 0xFFFF0000,
      ));
      final categories = await dao.getAll();
      expect(categories.length, equals(1));
      expect(categories.first.name, equals('Test'));
    });

    test('watchAll() émet des mises à jour', () async {
      final stream = dao.watchAll();
      final future = stream.first;
      await dao.insert(CategoriesCompanion.insert(
        name: 'WatchTest',
        icon: 'star',
        color: 0xFF00FF00,
      ));
      final categories = await future;
      expect(categories.any((c) => c.name == 'WatchTest'), isTrue);
    });

    test('getById() retourne null pour un ID inexistant', () async {
      final cat = await dao.getById(999);
      expect(cat, isNull);
    });

    test('getByType() filtre par type', () async {
      await dao.insertDefaults();
      final expenses = await dao.getByType('expense');
      final incomes = await dao.getByType('income');
      expect(expenses.every((c) => c.type == 'expense'), isTrue);
      expect(incomes.every((c) => c.type == 'income'), isTrue);
    });
  });
}
