import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:econome/presentation/providers/provider_app.dart';

/// Helper pour wrapper un widget test dans ProviderScope
/// avec un router GoRouter simple pour éviter les erreurs de navigation.
extension PumpApp on WidgetTester {
  Future<void> pumpApp(
    Widget child, {
    List<dynamic> overrides = const [],
  }) async {
    await pumpWidget(
      ProviderScope(
        overrides: [
          // Surcharge le provider d'onboarding pour éviter l'exception
          onboardingCompleteProvider.overrideWithValue(true),
          ...overrides,
        ],
        child: MaterialApp(
          theme: ThemeData.dark(),
          home: child,
        ),
      ),
    );
  }
}
