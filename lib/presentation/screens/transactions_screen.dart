import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';

import '../../core/theme/app_theme.dart';
import '../../core/constants/app_constants.dart';
import '../providers/app_providers.dart';
import '../../data/database/app_database.dart';

// ─── Transactions Screen ───────────────────────────────────────────────

class TransactionsScreen extends ConsumerStatefulWidget {
  const TransactionsScreen({super.key});

  @override
  ConsumerState<TransactionsScreen> createState() =>
      _TransactionsScreenState();
}

class _TransactionsScreenState extends ConsumerState<TransactionsScreen> {
  @override
  Widget build(BuildContext context) {
    final month = ref.watch(currentMonthProvider);

    return Scaffold(
      backgroundColor: AppTheme.zinc950,
      appBar: AppBar(
        title: Text(DateFormat('MMMM yyyy', 'fr_FR').format(month)),
        actions: [
          // Month navigation
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: () => _changeMonth(-1),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: () => _changeMonth(1),
          ),
        ],
      ),
      body: Column(
        children: [
          // Month total bar
          _MonthTotals(),

          // Transaction list
          Expanded(
            child: _TransactionGroupedList(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          HapticFeedback.lightImpact();
          context.push('/transactions/add');
        },
        backgroundColor: AppTheme.amberAccent,
        foregroundColor: AppTheme.zinc950,
        child: const Icon(Icons.add),
      ),
    );
  }

  void _changeMonth(int delta) {
    HapticFeedback.selectionClick();
    final current = ref.read(currentMonthProvider);
    ref
        .read(currentMonthProvider.notifier)
        .state = DateTime(current.year, current.month + delta, 1);
  }
}

// ─── Month Totals Bar ──────────────────────────────────────────────────

class _MonthTotals extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboardAsync = ref.watch(dashboardDataProvider);

    return dashboardAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, _) => const SizedBox.shrink(),
      data: (data) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
        decoration: BoxDecoration(
          color: AppTheme.zinc900,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.zinc800),
        ),
        child: Row(
          children: [
            Expanded(
              child: _TotalChip(
                label: 'Revenus',
                amount: data.totalIncome,
                color: AppTheme.greenAccent,
              ),
            ),
            Container(
              width: 1,
              height: 32,
              color: AppTheme.zinc800,
            ),
            Expanded(
              child: _TotalChip(
                label: 'Dépenses',
                amount: data.totalExpenses,
                color: AppTheme.redAccent,
              ),
            ),
            Container(
              width: 1,
              height: 32,
              color: AppTheme.zinc800,
            ),
            Expanded(
              child: _TotalChip(
                label: 'Solde',
                amount: data.balance,
                color:
                    data.balance >= 0 ? AppTheme.greenAccent : AppTheme.redAccent,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TotalChip extends StatelessWidget {
  final String label;
  final double amount;
  final Color color;

  const _TotalChip({
    required this.label,
    required this.amount,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: AppTheme.zinc500,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          AppConstants.formatAmountPlain(amount),
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
      ],
    );
  }
}

// ─── Grouped Transactions List ─────────────────────────────────────────

class _TransactionGroupedList extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactionsAsync = ref.watch(monthlyTransactionsProvider);
    final categoriesAsync = ref.watch(allCategoriesProvider);

    return transactionsAsync.when(
      loading: () => const Center(
        child: CircularProgressIndicator(strokeWidth: 2),
      ),
      error: (err, _) => Center(
        child: Text(
          'Erreur: $err',
          style: const TextStyle(color: AppTheme.zinc500),
        ),
      ),
      data: (transactions) {
        if (transactions.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.receipt_long_outlined,
                  color: AppTheme.zinc600,
                  size: 48,
                ),
                SizedBox(height: 12),
                Text(
                  'Aucune transaction ce mois',
                  style: TextStyle(
                    fontSize: 16,
                    color: AppTheme.zinc500,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Appuyez sur + pour en ajouter une',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppTheme.zinc600,
                  ),
                ),
              ],
            ),
          );
        }

        final catMap = <int, Category>{};
        final catList = categoriesAsync.valueOrNull ?? [];
        for (final c in catList) {
          catMap[c.id] = c;
        }

        // Group by date
        final grouped = <String, List<Transaction>>{};
        for (final t in transactions) {
          grouped.putIfAbsent(t.date, () => []).add(t);
        }

        // Sort dates descending
        final dates = grouped.keys.toList()
          ..sort((a, b) => b.compareTo(a));

        return RefreshIndicator(
          color: AppTheme.amberAccent,
          backgroundColor: AppTheme.zinc900,
          onRefresh: () async {
            HapticFeedback.lightImpact();
            ref.invalidate(monthlyTransactionsProvider);
            ref.invalidate(dashboardDataProvider);
            await Future.delayed(600.ms);
          },
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
            itemCount: dates.length,
            itemBuilder: (context, index) {
              final dateStr = dates[index];
              final items = grouped[dateStr]!;
              final date = DateTime.tryParse(dateStr) ?? DateTime.now();

              return _DateGroup(
                date: date,
                transactions: items,
                categoryMap: catMap,
              );
            },
          ),
        );
      },
    );
  }
}

// ─── Date Group ────────────────────────────────────────────────────────

class _DateGroup extends StatelessWidget {
  final DateTime date;
  final List<Transaction> transactions;
  final Map<int, Category> categoryMap;

  const _DateGroup({
    required this.date,
    required this.transactions,
    required this.categoryMap,
  });

  @override
  Widget build(BuildContext context) {
    final dayTotal = transactions.fold<double>(
      0,
      (sum, t) => sum + (t.type == 'expense' ? -t.amount : t.amount),
    );

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Date header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  DateFormat('EEEE d MMMM', 'fr_FR').format(date),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.zinc300,
                  ),
                ),
                Text(
                  dayTotal >= 0
                      ? AppConstants.formatAmount(dayTotal)
                      : '-${AppConstants.formatAmountPlain(dayTotal.abs())}',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: dayTotal >= 0
                        ? AppTheme.greenAccent
                        : AppTheme.redAccent,
                  ),
                ),
              ],
            ),
          ),

          // Transactions for this date
          ...transactions.map((t) {
            final cat = categoryMap[t.categoryId];
            return _TransactionCard(
              transaction: t,
              category: cat,
            );
          }),
        ],
      ),
    );
  }
}

// ─── Transaction Card ──────────────────────────────────────────────────

class _TransactionCard extends ConsumerWidget {
  final Transaction transaction;
  final Category? category;

  const _TransactionCard({
    required this.transaction,
    this.category,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isExpense = transaction.type == 'expense';
    final catColor = category != null
        ? Color(category!.color)
        : AppTheme.zinc500;

    return Dismissible(
      key: ValueKey(transaction.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: AppTheme.redAccent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.delete_outline, color: Colors.white),
      ),
      confirmDismiss: (_) async {
        return await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            backgroundColor: AppTheme.zinc900,
            title: const Text('Supprimer ?'),
            content: Text(
              'Supprimer cette transaction de ${AppConstants.formatAmountPlain(transaction.amount)} ?',
              style: const TextStyle(color: AppTheme.zinc300),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(false),
                child: const Text('Annuler'),
              ),
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(true),
                style: TextButton.styleFrom(
                  foregroundColor: AppTheme.redAccent,
                ),
                child: const Text('Supprimer'),
              ),
            ],
          ),
        );
      },
      onDismissed: (_) async {
        HapticFeedback.mediumImpact();
        final dao = ref.read(transactionDaoProvider);
        await dao.deleteEntry(transaction.id);
        ref.invalidate(monthlyTransactionsProvider);
        ref.invalidate(dashboardDataProvider);
        ref.invalidate(recentTransactionsProvider);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Transaction supprimée'),
              action: SnackBarAction(
                label: 'Annuler',
                textColor: AppTheme.amberAccent,
                onPressed: () {
                  // Re-add would require storing the full data
                },
              ),
            ),
          );
        }
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 3),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: AppTheme.zinc900,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.zinc800.withValues(alpha: 0.5)),
        ),
        child: Row(
          children: [
            // Category icon
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: catColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                category != null
                    ? _mapIcon(category!.icon)
                    : Icons.receipt,
                size: 18,
                color: catColor,
              ),
            ),
            const SizedBox(width: 12),

            // Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    transaction.description ?? category?.name ?? 'Transaction',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.zinc200,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (category != null)
                    Text(
                      category!.name,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppTheme.zinc500,
                      ),
                    ),
                ],
              ),
            ),

            // Note indicator
            if (transaction.note != null && transaction.note!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Icon(
                  Icons.notes_rounded,
                  size: 14,
                  color: AppTheme.zinc600,
                ),
              ),

            // Amount
            Text(
              isExpense
                  ? '-${AppConstants.formatAmountPlain(transaction.amount)}'
                  : AppConstants.formatAmount(transaction.amount),
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isExpense ? AppTheme.redAccent : AppTheme.greenAccent,
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(
      duration: 300.ms,
    ).slideX(begin: 0.03, end: 0, duration: 300.ms);
  }

  IconData _mapIcon(String iconName) {
    switch (iconName) {
      case 'restaurant': return Icons.restaurant;
      case 'directions_car': return Icons.directions_car;
      case 'shopping_bag': return Icons.shopping_bag;
      case 'movie': return Icons.movie;
      case 'favorite': return Icons.favorite;
      case 'school': return Icons.school;
      case 'home': return Icons.home;
      case 'bolt': return Icons.bolt;
      case 'work': return Icons.work;
      case 'computer': return Icons.computer;
      case 'card_giftcard': return Icons.card_giftcard;
      case 'more_horiz': return Icons.more_horiz;
      default: return Icons.circle;
    }
  }
}
