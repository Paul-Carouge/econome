import 'dart:io';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:drift/drift.dart';
import 'app_database.dart';

// TODO(phantom): Migrer vers sqlcipher pour chiffrer les données financières
// Nécessite : sqlcipher_flutter_libs, drift avec NativeDatabase chiffré
AppDatabase buildDatabase() {
  return AppDatabase(LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'econome.db'));
    return NativeDatabase(file);
  }));
}
