import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:econome/presentation/screens/dashboard_screen.dart';
import 'package:econome/presentation/providers/dashboard_providers.dart';
import 'package:econome/presentation/providers/provider_app.dart';

/// Test basique du DashboardScreen.
/// On surcharge dashboardDataProvider pour éviter l'AsyncLoading
/// et on vérifie la structure de base.
void main() {
  setUpAll(() {
    Intl.defaultLocale = 'fr_FR';
  });

  setUp(() async {
    // initializeDateFormatting uses Timer internally which conflicts with
    // Flutter test framework's pending timer check. We call it once per test
    // inside runAsync to properly clean up the timers.
    await TestWidgetsFlutterBinding.instance.runAsync<dynamic>(
      () => initializeDateFormatting('fr_FR', null),
    );
  });

  Future<void> pumpDashboard(WidgetTester tester, Widget widget) async {
    await tester.pumpWidget(widget);
    // Pump multiple frames for animations + async data
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pump(const Duration(milliseconds: 100));
  }
  const testData = DashboardData(
    totalIncome: 2000,
    totalExpenses: 1500,
    balance: 500,
    month: 6,
    year: 2024,
  );

  testWidgets('DashboardScreen affiche le titre Économe', (tester) async {
    await pumpDashboard(
      tester,
      ProviderScope(
        overrides: [
          onboardingCompleteProvider.overrideWithValue(true),
          dashboardDataProvider.overrideWithValue(testData),
        ],
        child: const MaterialApp(
          home: DashboardScreen(),
        ),
      ),
    );

    // Le titre de l'AppBar
    expect(find.text('Économe'), findsOneWidget);
  });

  testWidgets('DashboardScreen a un FloatingActionButton', (tester) async {
    await pumpDashboard(
      tester,
      ProviderScope(
        overrides: [
          onboardingCompleteProvider.overrideWithValue(true),
          dashboardDataProvider.overrideWithValue(testData),
        ],
        child: const MaterialApp(
          home: DashboardScreen(),
        ),
      ),
    );

    // FAB
    expect(find.byType(FloatingActionButton), findsOneWidget);
    // Check l'icône +
    expect(
      find.descendant(
        of: find.byType(FloatingActionButton),
        matching: find.byIcon(Icons.add),
      ),
      findsOneWidget,
    );
  });

  testWidgets('DashboardScreen affiche le solde formaté', (tester) async {
    await pumpDashboard(
      tester,
      ProviderScope(
        overrides: [
          onboardingCompleteProvider.overrideWithValue(true),
          dashboardDataProvider.overrideWithValue(testData),
        ],
        child: const MaterialApp(
          home: DashboardScreen(),
        ),
      ),
    );

    // Le solde (+500,00 €) doit apparaître
    expect(find.textContaining('500'), findsWidgets);
    expect(find.textContaining('€'), findsWidgets);
  });
}
