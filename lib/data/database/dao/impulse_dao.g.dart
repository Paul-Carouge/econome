// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'impulse_dao.dart';

// ignore_for_file: type=lint
mixin _$ImpulseDaoMixin on DatabaseAccessor<AppDatabase> {
  $CategoriesTable get categories => attachedDatabase.categories;
  $ImpulseItemsTable get impulseItems => attachedDatabase.impulseItems;
  ImpulseDaoManager get managers => ImpulseDaoManager(this);
}

class ImpulseDaoManager {
  final _$ImpulseDaoMixin _db;
  ImpulseDaoManager(this._db);
  $$CategoriesTableTableManager get categories =>
      $$CategoriesTableTableManager(_db.attachedDatabase, _db.categories);
  $$ImpulseItemsTableTableManager get impulseItems =>
      $$ImpulseItemsTableTableManager(_db.attachedDatabase, _db.impulseItems);
}
