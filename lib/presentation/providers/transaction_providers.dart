import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:econome/core/services/export_service.dart';
import 'package:econome/data/database/app_database.dart';
import 'package:econome/presentation/providers/database_providers.dart';

// ─── Current Month State ──────────────────────────────────────────────
final currentMonthProvider = StateProvider<DateTime>((ref) => DateTime.now());

// ─── Transaction Providers ────────────────────────────────────────────
final monthlyTransactionsProvider = StreamProvider<List<Transaction>>((ref) {
  final month = ref.watch(currentMonthProvider);
  return ref.watch(transactionDaoProvider).watchByMonth(month.month, month.year);
});

final recentTransactionsProvider = StreamProvider<List<Transaction>>((ref) {
  return ref.watch(transactionDaoProvider).watchRecent(5);
});

// ─── Export Service Provider ──────────────────────────────────────────
final exportServiceProvider = Provider<ExportService>((ref) => ExportService());

// ─── Cache pour éviter le flash blanc ──────────────────────────────
/// Dernières transactions mensuelles valides, conservées en cache pour
/// éviter le flash blanc lors du changement de mois.
///
/// Quand le StreamProvider `monthlyTransactionsProvider` se recharge
/// (changement de mois), `asData?.value` devient null pendant un instant.
/// Ce cache permet de renvoyer les anciennes données pendant le chargement.
List<Transaction>? _cachedMonthlyTransactions;

// ─── Filter State Providers ──────────────────────────────────────────
/// Texte de recherche pour filtrer les transactions.
final searchTextProvider = StateProvider<String>((ref) => '');

/// ID de la catégorie sélectionnée pour le filtre (null = toutes).
final categoryFilterProvider = StateProvider<int?>((ref) => null);

/// Type sélectionné pour le filtre (null = tous, 'income' = revenus, 'expense' = dépenses).
final typeFilterProvider = StateProvider<String?>((ref) => null);

/// Transactions filtrées selon les critères de recherche, catégorie et type.
///
/// Le filtrage est effectué côté client sur les transactions déjà chargées.
///
/// Protégé contre le flash blanc : si le stream est en chargement (changement
/// de mois), les anciennes données sont conservées jusqu'à l'arrivée des nouvelles.
final filteredTransactionsProvider = Provider<List<Transaction>>((ref) {
  final asyncTransactions = ref.watch(monthlyTransactionsProvider);

  final transactions = asyncTransactions.when(
    data: (data) {
      _cachedMonthlyTransactions = data;
      return data;
    },
    loading: () => _cachedMonthlyTransactions ?? [],
    error: (_, __) => _cachedMonthlyTransactions ?? [],
  );

  final searchText = ref.watch(searchTextProvider).toLowerCase().trim();
  final categoryId = ref.watch(categoryFilterProvider);
  final type = ref.watch(typeFilterProvider);

  return transactions.where((t) {
    // Filtre par type
    if (type != null && t.type != type) return false;

    // Filtre par catégorie
    if (categoryId != null && t.categoryId != categoryId) return false;

    // Filtre par recherche textuelle
    if (searchText.isNotEmpty) {
      final desc = (t.description ?? '').toLowerCase();
      final note = (t.note ?? '').toLowerCase();
      if (!desc.contains(searchText) && !note.contains(searchText)) {
        return false;
      }
    }

    return true;
  }).toList();
});
