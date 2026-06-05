import 'dart:typed_data';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import 'package:econome/data/database/app_database.dart';

/// Service d'export de transactions au format CSV.
class ExportService {
  /// Exporte la liste de [transactions] au format CSV et ouvre le partage.
  ///
  /// [categories] sert à résoudre le nom et le type de chaque catégorie.
  Future<void> exportToCsv(
    List<Transaction> transactions,
    List<Category> categories,
  ) async {
    // Build a category map for quick lookup
    final catMap = <int, Category>{};
    for (final c in categories) {
      catMap[c.id] = c;
    }

    // Generate CSV content
    final buffer = StringBuffer();

    // BOM for Excel UTF-8 compatibility + header line
    buffer.write('\uFEFF');
    buffer.writeln('Date;Description;Montant;Type;Catégorie');

    final dateFormat = DateFormat('dd/MM/yyyy');

    for (final t in transactions) {
      final date = dateFormat.format(DateTime.parse(t.date));
      final description =
          (t.description ?? '').replaceAll('"', '""');
      final amount = t.amount.toStringAsFixed(2);
      final type = t.type == 'income' ? 'Revenu' : 'Dépense';
      final category = catMap[t.categoryId]?.name ?? '';

      buffer.writeln('$date;"$description";$amount;$type;$category');
    }

    final csvString = buffer.toString();
    final csvData = Uint8List.fromList(csvString.codeUnits);

    final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());

    // Use share_plus to share the file
    await Share.shareXFiles(
      [
        XFile.fromData(
          csvData,
          mimeType: 'text/csv',
          name: 'transactions_$timestamp.csv',
        ),
      ],
      text: 'Export des transactions',
    );
  }
}
