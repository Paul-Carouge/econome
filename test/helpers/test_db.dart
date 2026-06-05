import 'package:drift/native.dart';
import 'package:econome/data/database/app_database.dart';

/// Crée une base de données en mémoire pour les tests.
/// Chaque appel retourne une nouvelle instance isolée.
AppDatabase createTestDatabase() {
  return AppDatabase(NativeDatabase.memory());
}
