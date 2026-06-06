import 'package:home_widget/home_widget.dart';

/// Service responsable de mettre à jour les données du widget d'écran d'accueil.
///
/// Appeler [updateWidget] après chaque modification de transaction, budget
/// ou objectif d'épargne pour que le widget reflète les dernières données.
class WidgetUpdateService {
  static const _widgetName = 'EconomeWidget';

  /// Met à jour le widget avec les données financières actuelles.
  ///
  /// [balance] : solde formaté (ex: "+1 250 €")
  /// [balanceColor] : couleur hex du solde (ex: "#22C55E" pour positif)
  /// [budgetLabel] : texte du budget restant (ex: "Budget resto : 120 €")
  /// [budgetProgress] : progression du budget (0.0 à 1.0)
  /// [recentTransactions] : liste des 3 dernières transactions formatées
  static Future<void> updateWidget({
    required String balance,
    required String balanceColor,
    String budgetLabel = '',
    double budgetProgress = 0.0,
    List<String> recentTransactions = const [],
  }) async {
    try {
      await HomeWidget.saveWidgetData<String>('balance', balance);
      await HomeWidget.saveWidgetData<String>('balanceColor', balanceColor);
      await HomeWidget.saveWidgetData<String>('budgetLabel', budgetLabel);
      await HomeWidget.saveWidgetData<double>('budgetProgress', budgetProgress);
      await HomeWidget.saveWidgetData<String>('tx1',
          recentTransactions.isNotEmpty ? recentTransactions[0] : '');
      await HomeWidget.saveWidgetData<String>('tx2',
          recentTransactions.length > 1 ? recentTransactions[1] : '');
      await HomeWidget.saveWidgetData<String>('tx3',
          recentTransactions.length > 2 ? recentTransactions[2] : '');

      await HomeWidget.updateWidget(name: _widgetName);
    } catch (e) {
      // Le widget n'est pas critique — silence les erreurs
    }
  }

  /// Formate un montant en euros.
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
    if (balance > 0) return '#22C55E'; // vert
    if (balance < 0) return '#EF4444'; // rouge
    return '#A1A1AA'; // gris
  }

  /// Formate une transaction pour l'affichage dans le widget (1 ligne).
  static String formatTransaction(
    String description,
    double amount,
    String type,
  ) {
    final sign = type == 'income' ? '+' : '-';
    final abs = amount.abs().toStringAsFixed(0);
    final maxDesc = description.length > 18
        ? '${description.substring(0, 16)}…'
        : description;
    return '$maxDesc  $sign$abs €';
  }
}
