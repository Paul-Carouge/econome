import 'package:home_widget/home_widget.dart';

/// Service responsable de mettre à jour tous les widgets d'écran d'accueil.
///
/// 4 types de widgets disponibles :
/// - **Full** (EconomeWidget) : solde + budget + 3 dernières transactions
/// - **Compact** (CompactWidget) : solde uniquement, large police
/// - **Budget** (BudgetWidget) : barre de progression du budget
/// - **Savings** (SavingsWidget) : progression du 1er objectif d'épargne
class WidgetUpdateService {
  static const _fullWidget = 'EconomeWidget';
  static const _compactWidget = 'CompactWidget';
  static const _budgetWidget = 'BudgetWidget';
  static const _savingsWidget = 'SavingsWidget';

  /// Met à jour tous les types de widgets avec les données actuelles.
  static Future<void> updateAll({
    required String balance,
    required String balanceColor,
    String budgetLabel = '',
    String budgetSpent = '',
    String budgetTotal = '',
    String budgetPct = '0',
    List<String> recentTransactions = const [],
    String savingsName = '',
    String savingsCurrent = '',
    String savingsTarget = '',
    String savingsPct = '0',
  }) async {
    try {
      // ── Full Widget ──
      await HomeWidget.saveWidgetData<String>('widgetName', _fullWidget);
      await HomeWidget.saveWidgetData<String>('balance', balance);
      await HomeWidget.saveWidgetData<String>('balanceColor', balanceColor);
      await HomeWidget.saveWidgetData<String>('budgetLabel', budgetLabel);
      await HomeWidget.saveWidgetData<String>('tx1',
          recentTransactions.isNotEmpty ? recentTransactions[0] : '');
      await HomeWidget.saveWidgetData<String>('tx2',
          recentTransactions.length > 1 ? recentTransactions[1] : '');
      await HomeWidget.saveWidgetData<String>('tx3',
          recentTransactions.length > 2 ? recentTransactions[2] : '');
      await HomeWidget.updateWidget(name: _fullWidget);

      // ── Compact Widget ──
      await HomeWidget.saveWidgetData<String>('widgetName', _compactWidget);
      await HomeWidget.saveWidgetData<String>('balance', balance);
      await HomeWidget.saveWidgetData<String>('balanceColor', balanceColor);
      await HomeWidget.updateWidget(name: _compactWidget);

      // ── Budget Widget ──
      await HomeWidget.saveWidgetData<String>('widgetName', _budgetWidget);
      await HomeWidget.saveWidgetData<String>('budgetLabel', budgetLabel);
      await HomeWidget.saveWidgetData<String>('budgetSpent', budgetSpent);
      await HomeWidget.saveWidgetData<String>('budgetTotal', budgetTotal);
      await HomeWidget.saveWidgetData<String>('budgetPct', budgetPct);
      await HomeWidget.updateWidget(name: _budgetWidget);

      // ── Savings Widget ──
      await HomeWidget.saveWidgetData<String>('widgetName', _savingsWidget);
      await HomeWidget.saveWidgetData<String>('savingsName', savingsName);
      await HomeWidget.saveWidgetData<String>('savingsCurrent', savingsCurrent);
      await HomeWidget.saveWidgetData<String>('savingsTarget', savingsTarget);
      await HomeWidget.saveWidgetData<String>('savingsPct', savingsPct);
      await HomeWidget.updateWidget(name: _savingsWidget);
    } catch (e) {
      // Le widget n'est pas critique — silence les erreurs
    }
  }

  // ─── Helpers ──────────────────────────────────────────────────────

  /// Formate un montant en euros pour le widget.
  static String formatAmount(double amount) {
    final sign = amount >= 0 ? '+' : '';
    final abs = amount.abs();
    if (abs >= 1000000) {
      return '$sign${(abs / 1000000).toStringAsFixed(1)}M €';
    }
    return '$sign${abs.toStringAsFixed(0)} €';
  }

  /// Retourne la couleur hex pour un solde.
  static String colorForBalance(double balance) {
    if (balance > 0) return '#22C55E';
    if (balance < 0) return '#EF4444';
    return '#A1A1AA';
  }

  /// Formate une transaction pour l'affichage dans le widget (1 ligne).
  static String formatTransaction(
    String description,
    double amount,
    String type,
  ) {
    final sign = type == 'income' ? '+' : '-';
    final abs = amount.abs().toStringAsFixed(0);
    final maxDesc =
        description.length > 18 ? '${description.substring(0, 16)}…' : description;
    return '$maxDesc  $sign$abs €';
  }

  /// Pourcentage formaté à partir d'une valeur entre 0.0 et 1.0.
  static String formatPercent(double value) {
    return (value.clamp(0.0, 1.0) * 100).toStringAsFixed(0);
  }
}
