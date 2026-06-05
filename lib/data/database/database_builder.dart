import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'app_database.dart';

/// Builds the [AppDatabase] with a standard SQLite database.
///
/// TODO(phantom): Ajouter le chiffrement SQLCipher quand le conflit de namespace
/// entre sqlcipher_flutter_libs et sqlite3_flutter_libs sera résolu.
/// Voir : https://github.com/simolus3/sqlcipher_flutter_libs/issues
AppDatabase buildDatabase() {
  return AppDatabase(LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'econome.db'));
    return NativeDatabase(file);
  }));
}
