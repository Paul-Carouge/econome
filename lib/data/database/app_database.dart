import 'package:drift/drift.dart';

part 'app_database.g.dart';

// ─── Tables ──────────────────────────────────────────────────────────

class Categories extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  TextColumn get icon => text()(); // Material icon name
  IntColumn get color => integer()(); // ARGB color value
  TextColumn get type => text().withDefault(const Constant('expense'))(); // 'income' | 'expense'
  RealColumn get budget => real().nullable()(); // Monthly budget
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
  BoolColumn get isCustom => boolean().withDefault(const Constant(false))();
}

class Transactions extends Table {
  IntColumn get id => integer().autoIncrement()();
  RealColumn get amount => real()();
  TextColumn get description => text().nullable()();
  TextColumn get date => text()(); // ISO 8601 date
  IntColumn get categoryId => integer().references(Categories, #id)();
  TextColumn get type => text()(); // 'income' | 'expense'
  TextColumn get note => text().nullable()();
  TextColumn get createdAt => text()();
}

class Budgets extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get month => integer()();
  IntColumn get year => integer()();
  RealColumn get totalBudget => real()();
  TextColumn get createdAt => text()();

  @override
  List<Set<Column>> get uniqueKeys => [
    {month, year},
  ];
}

class SavingsGoals extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  RealColumn get targetAmount => real()();
  RealColumn get currentAmount => real().withDefault(const Constant(0.0))();
  TextColumn get deadline => text().nullable()();
  TextColumn get icon => text().withDefault(const Constant('savings'))();
  IntColumn get color => integer().withDefault(const Constant(0xFFF59E0B))();
  TextColumn get notes => text().nullable()();
  TextColumn get createdAt => text()();
  BoolColumn get isCompleted => boolean().withDefault(const Constant(false))();
}

class ImpulseItems extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  RealColumn get amount => real()();
  IntColumn get categoryId => integer().references(Categories, #id).nullable()();
  TextColumn get link => text().nullable()();
  TextColumn get notes => text().nullable()();
  TextColumn get createdAt => text()();
  TextColumn get coolingUntil => text()();
  TextColumn get status => text().withDefault(const Constant('cooling'))();
  TextColumn get approvedAt => text().nullable()();
  TextColumn get dismissedAt => text().nullable()();
}

// ─── Database ────────────────────────────────────────────────────────

@DriftDatabase(
  tables: [
    Categories,
    Transactions,
    Budgets,
    SavingsGoals,
    ImpulseItems,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase(QueryExecutor e) : super(e);

  @override
  int get schemaVersion => 1;
}
