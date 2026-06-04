import 'package:drift/drift.dart';
import '../app_database.dart';

part 'impulse_dao.g.dart';

@DriftAccessor(tables: [ImpulseItems, Categories])
class ImpulseDao extends DatabaseAccessor<AppDatabase> with _$ImpulseDaoMixin {
  ImpulseDao(AppDatabase db) : super(db);

  Stream<List<ImpulseItem>> watchAll() =>
      (select(impulseItems)..orderBy([(i) => OrderingTerm.desc(i.createdAt)])).watch();

  Stream<List<ImpulseItem>> watchByStatus(String status) =>
      (select(impulseItems)
            ..where((i) => i.status.equals(status))
            ..orderBy([(i) => OrderingTerm.desc(i.createdAt)]))
          .watch();

  Future<List<ImpulseItem>> getCooling() =>
      (select(impulseItems)
            ..where((i) => i.status.equals('cooling'))
            ..orderBy([(i) => OrderingTerm.desc(i.createdAt)]))
          .get();

  Future<ImpulseItem?> getById(int id) =>
      (select(impulseItems)..where((i) => i.id.equals(id))).getSingleOrNull();

  Future<int> insert(ImpulseItemsCompanion entry) =>
      into(impulseItems).insert(entry);

  Future<bool> updateStatus(int id, String status) async =>
      (await (update(impulseItems)..where((i) => i.id.equals(id))).write(
        ImpulseItemsCompanion(
          status: Value(status),
          approvedAt: status == 'approved' ? Value(DateTime.now().toIso8601String()) : const Value(null),
          dismissedAt: status == 'dismissed' ? Value(DateTime.now().toIso8601String()) : const Value(null),
        ),
      )) > 0;

  Future<int> deleteEntry(int id) =>
      (delete(impulseItems)..where((i) => i.id.equals(id))).go();

  Future<int> getActiveCount() async {
    final rows = await (select(impulseItems)
          ..where((i) => i.status.equals('cooling')))
        .get();
    return rows.length;
  }
}
