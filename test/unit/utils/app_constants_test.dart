import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:econome/core/constants/app_constants.dart';

void main() {
  setUpAll(() async {
    await initializeDateFormatting('fr_FR', null);
  });

  group('AppConstants.formatAmount', () {
    test('formate un montant positif', () {
      final result = AppConstants.formatAmount(1234.56);
      expect(result, contains('+'));
      expect(result, contains('€'));
      expect(result, contains('1'));
    });

    test('formate un montant négatif', () {
      final result = AppConstants.formatAmount(-500.0);
      expect(result, startsWith('-'));
      expect(result, contains('500'));
      expect(result, contains('€'));
    });

    test('formate zéro', () {
      final result = AppConstants.formatAmount(0);
      expect(result, contains('0'));
      expect(result, contains('€'));
    });
  });

  group('AppConstants.formatAmountPlain', () {
    test('formate sans signe', () {
      final result = AppConstants.formatAmountPlain(100.0);
      expect(result, contains('100'));
      expect(result, contains('€'));
      expect(result, isNot(startsWith('+')));
      expect(result, isNot(startsWith('-')));
    });
  });

  group('AppConstants.formatAmountCompact', () {
    test('formate les milliers', () {
      final result = AppConstants.formatAmountCompact(1500);
      expect(result, contains('k'));
    });

    test('formate les millions', () {
      final result = AppConstants.formatAmountCompact(2000000);
      expect(result, contains('M'));
    });
  });

  group('AppConstants.formatDate', () {
    test('formate une date en français', () {
      final result = AppConstants.formatDate(DateTime(2024, 6, 15));
      expect(result, contains('15'));
      expect(result, contains('06'));
      expect(result, contains('2024'));
    });
  });

  group('AppConstants constants', () {
    test('appName est Économe', () {
      expect(AppConstants.appName, equals('Économe'));
    });

    test('defaultCurrencySymbol est €', () {
      expect(AppConstants.defaultCurrencySymbol, equals('€'));
    });
  });
}
