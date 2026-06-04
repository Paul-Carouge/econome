import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AppConstants {
  AppConstants._();

  static const String appName = 'Économe';
  static const String appTagline = 'Think before you spend';

  // ─── Currency ─────────────────────────────────────────────────────
  static String get defaultCurrencySymbol => '€';
  static String get locale => 'fr_FR';

  // ─── Date formatting ─────────────────────────────────────────────
  static String formatDate(DateTime date) =>
      DateFormat('dd/MM/yyyy', locale).format(date);

  static String formatMonthYear(DateTime date) =>
      DateFormat('MMMM yyyy', locale).format(date);

  static String formatDayMonth(DateTime date) =>
      DateFormat('EEE d MMM', locale).format(date);

  // ─── Amount formatting ────────────────────────────────────────────
  static String formatAmount(double amount) {
    final formatter = NumberFormat('#,##0.00', locale);
    final sign = amount >= 0 ? '+' : '';
    return '$sign${formatter.format(amount)} €';
  }

  static String formatAmountPlain(double amount) {
    final formatter = NumberFormat('#,##0.00', locale);
    return '${formatter.format(amount)} €';
  }

  static String formatAmountCompact(double amount) {
    if (amount >= 1000000) return '${(amount / 1000000).toStringAsFixed(1)}M €';
    if (amount >= 1000) return '${(amount / 1000).toStringAsFixed(1)}k €';
    final formatter = NumberFormat('#,##0', locale);
    return '${formatter.format(amount)} €';
  }

  // ─── Icons map ────────────────────────────────────────────────────
  static const Map<String, IconData> categoryIcons = {
    'food': Icons.restaurant,
    'transport': Icons.directions_car,
    'shopping': Icons.shopping_bag,
    'entertainment': Icons.movie,
    'health': Icons.favorite,
    'education': Icons.school,
    'housing': Icons.home,
    'utilities': Icons.bolt,
    'salary': Icons.work,
    'freelance': Icons.computer,
    'gift': Icons.card_giftcard,
    'savings': Icons.savings,
    'investment': Icons.trending_up,
    'insurance': Icons.verified_user,
    'other': Icons.more_horiz,
    'car': Icons.directions_car,
    'flight': Icons.flight,
    'travel_explore': Icons.explore,
    'star': Icons.star,
    'account_balance': Icons.account_balance,
    'shopping_cart': Icons.shopping_cart,
    'directions_car': Icons.directions_car,
  };
}
