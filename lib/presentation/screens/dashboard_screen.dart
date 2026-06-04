import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

import '../../core/theme/app_theme.dart';
import '../../core/constants/app_constants.dart';
import '../providers/app_providers.dart';
import '../../data/database/app_database.dart';

// ─── Dashboard Screen ─────────────────────────────────────────────────

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.zinc950,
      appBar: AppBar(
        title: const Text('Budgethink'),
        actions: [
          IconButton(
            icon: const Icon(Icons.trending_up_outlined),
            onPressed: () => context.push('/impulse'),
            tooltip: 'Anti-Impulsion',
          ),
        ],
      ),
      body: RefreshIndicator(
        color: AppTheme.amberAccent,
        backgroundColor: AppTheme.zinc900,
        onRefresh: () async {
          HapticFeedback.lightImpact();
          ref.invalidate(dashboardDataProvider);
          ref.invalidate(recentTransactionsProvider);
          ref.invalidate(currentBudgetProvider);
          await Future.delayed(600.ms);
        },
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
          children: [
            // ─── Monthly Overview Card ─────────────────────────────
            _MonthlyOverviewCard().animate().fadeIn(
              duration: 400.ms,
            ).slideX(begin: 0.05, end: 0, duration: 400.ms),

            const SizedBox(height: 20),

            // ─── Pie Chart ─────────────────────────────────────────
            const _PieChartSection().animate().fadeIn(
              duration: 400.ms,
              delay: 100.ms,
            ).slideX(begin: 0.05, end: 0, duration: 400.ms, delay: 100.ms),

            const SizedBox(height: 20),

            // ─── Budget Bars ───────────────────────────────────────
            const _BudgetBarsSection().animate().fadeIn(
              duration: 400.ms,
              delay: 200.ms,
            ).slideX(begin: 0.05, end: 0, duration: 400.ms, delay: 200.ms),

            const SizedBox(height: 20),

            // ─── Recent Transactions ───────────────────────────────
            const _RecentTransactionsSection().animate().fadeIn(
              duration: 400.ms,
              delay: 300.ms,
            ).slideX(begin: 0.05, end: 0, duration: 400.ms, delay: 300.ms),
          ],
        ),
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
}

// ─── Weekly Overview Card ──────────────────────────────────────────────

class _MonthlyOverviewCard extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboardAsync = ref.watch(dashboardDataProvider);

    return dashboardAsync.when(
      loading: () => _buildShimmerCard(),
      error: (err, _) => Card(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Text(
            'Erreur de chargement',
            style: TextStyle(color: AppTheme.zinc400),
          ),
        ),
      ),
      data: (data) => Card(
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppTheme.zinc900,
                AppTheme.zinc900,
                AppTheme.amberAccent.withValues(alpha: 0.04),
              ],
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Month + year
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    DateFormat('MMMM yyyy', 'fr_FR')
                        .format(DateTime(data.year, data.month)),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.zinc300,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: data.balance >= 0
                          ? AppTheme.greenAccent.withValues(alpha: 0.12)
                          : AppTheme.redAccent.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      data.balance >= 0 ? 'Équilibré' : 'En déficit',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: data.balance >= 0
                            ? AppTheme.greenAccent
                            : AppTheme.redAccent,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Balance
              Text(
                AppConstants.formatAmount(data.balance),
                style: TextStyle(
                  fontSize: 34,
                  fontWeight: FontWeight.w700,
                  color: data.balance >= 0
                      ? AppTheme.greenAccent
                      : AppTheme.redAccent,
                  letterSpacing: -0.03,
                ),
              ),
              const SizedBox(height: 20),

              // Income / Expense bars
              Row(
                children: [
                  Expanded(
                    child: _MiniStatCard(
                      label: 'Revenus',
                      amount: data.totalIncome,
                      color: AppTheme.greenAccent,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _MiniStatCard(
                      label: 'Dépenses',
                      amount: data.totalExpenses,
                      color: AppTheme.redAccent,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildShimmerCard() {
    return Card(
      child: Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 140,
              height: 16,
              decoration: BoxDecoration(
                color: AppTheme.zinc800,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(height: 20),
            Container(
              width: 180,
              height: 34,
              decoration: BoxDecoration(
                color: AppTheme.zinc800,
                borderRadius: BorderRadius.circular(6),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: Container(
                    height: 56,
                    decoration: BoxDecoration(
                      color: AppTheme.zinc800,
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    height: 56,
                    decoration: BoxDecoration(
                      color: AppTheme.zinc800,
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MiniStatCard extends StatelessWidget {
  final String label;
  final double amount;
  final Color color;

  const _MiniStatCard({
    required this.label,
    required this.amount,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.zinc800.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.zinc700.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: AppTheme.zinc400,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            AppConstants.formatAmountPlain(amount),
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Pie Chart Section ─────────────────────────────────────────────────

class _PieChartSection extends ConsumerWidget {
  const _PieChartSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(expenseCategoriesProvider);
    final dashboardAsync = ref.watch(dashboardDataProvider);
    final monthlyTx = ref.watch(monthlyTransactionsProvider);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Dépenses par catégorie',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.zinc100,
                  ),
                ),
                Icon(Icons.pie_chart, color: AppTheme.zinc500, size: 20),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 200,
              child: categoriesAsync.when(
                loading: () => const Center(
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                error: (_, _) => const Center(
                  child: Text(
                    'Aucune donnée',
                    style: TextStyle(color: AppTheme.zinc500),
                  ),
                ),
                data: (categories) {
                  if (categories.isEmpty) {
                    return const Center(
                      child: Text(
                        'Aucune catégorie',
                        style: TextStyle(color: AppTheme.zinc500),
                      ),
                    );
                  }
                  return _PieChart(
                    categories: categories,
                    dashboardAsync: dashboardAsync,
                    monthlyTransactions: monthlyTx.asData?.value ?? [],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PieChart extends StatelessWidget {
  final List<Category> categories;
  final AsyncValue<DashboardData> dashboardAsync;
  final List<Transaction> monthlyTransactions;

  const _PieChart({
    required this.categories,
    required this.dashboardAsync,
    required this.monthlyTransactions,
  });

  /// Compute per-category spending from monthly transactions.
  Map<int, double> _computeCategorySpending() {
    final map = <int, double>{};
    for (final t in monthlyTransactions) {
      if (t.type == 'expense') {
        map[t.categoryId] = (map[t.categoryId] ?? 0) + t.amount;
      }
    }
    return map;
  }

  @override
  Widget build(BuildContext context) {
    return dashboardAsync.when(
      loading: () => const Center(
        child: CircularProgressIndicator(strokeWidth: 2),
      ),
      error: (_, _) => const Center(
        child: Text(
          'Aucune donnée',
          style: TextStyle(color: AppTheme.zinc500),
        ),
      ),
      data: (data) {
        if (data.totalExpenses <= 0) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.savings, color: AppTheme.zinc600, size: 40),
                const SizedBox(height: 8),
                const Text(
                  'Aucune dépense ce mois',
                  style: TextStyle(color: AppTheme.zinc500),
                ),
              ],
            ),
          );
        }

        final categorySpending = _computeCategorySpending();

        return Row(
          children: [
            SizedBox(
              width: 140,
              height: 140,
              child: PieChart(
                PieChartData(
                  sectionsSpace: 2,
                  centerSpaceRadius: 30,
                  sections: _buildSections(categories, data, categorySpending),
                  borderData: FlBorderData(show: false),
                ),
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: _buildLegend(categories, categorySpending, data.totalExpenses),
              ),
            ),
          ],
        );
      },
    );
  }

  List<PieChartSectionData> _buildSections(
    List<Category> categories,
    DashboardData data,
    Map<int, double> categorySpending,
  ) {
    final total = data.totalExpenses;
    if (total <= 0) return [];

    final colors = [
      AppTheme.amberAccent,
      AppTheme.greenAccent,
      const Color(0xFF3B82F6),
      const Color(0xFF8B5CF6),
      const Color(0xFFEC4899),
      AppTheme.zinc600,
    ];

    // Sort categories by actual spending, take top 5
    final sorted = categories
        .map((c) => (cat: c, spent: categorySpending[c.id] ?? 0.0))
        .where((e) => e.spent > 0)
        .toList()
      ..sort((a, b) => b.spent.compareTo(a.spent));

    final top5 = sorted.take(5).toList();
    final top5Spent = top5.fold<double>(0, (sum, e) => sum + e.spent);
    final autresSpent = total - top5Spent;

    final sections = <PieChartSectionData>[];
    for (int i = 0; i < top5.length; i++) {
      final pct = top5[i].spent / total;
      sections.add(PieChartSectionData(
        color: colors[i % 5],
        value: pct * 100,
        title: '${(pct * 100).round()}%',
        radius: 38,
        titleStyle: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: AppTheme.zinc950,
        ),
      ));
    }

    // Add "Autres" section if there are remaining categories with spending
    if (autresSpent > 0 && (sorted.length > 5 || categories.any((c) => (categorySpending[c.id] ?? 0) > 0 && !top5.any((e) => e.cat.id == c.id)))) {
      final pct = autresSpent / total;
      sections.add(PieChartSectionData(
        color: colors[5],
        value: pct * 100,
        title: '${(pct * 100).round()}%',
        radius: 38,
        titleStyle: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: AppTheme.zinc950,
        ),
      ));
    }

    return sections;
  }

  List<Widget> _buildLegend(
    List<Category> categories,
    Map<int, double> categorySpending,
    double totalExpenses,
  ) {
    final colors = [
      AppTheme.amberAccent,
      AppTheme.greenAccent,
      const Color(0xFF3B82F6),
      const Color(0xFF8B5CF6),
      const Color(0xFFEC4899),
      AppTheme.zinc600,
    ];

    // Same sorting as sections for consistency
    final sorted = categories
        .map((c) => (cat: c, spent: categorySpending[c.id] ?? 0.0))
        .where((e) => e.spent > 0)
        .toList()
      ..sort((a, b) => b.spent.compareTo(a.spent));

    final top5 = sorted.take(5).toList();
    final top5Spent = top5.fold<double>(0, (sum, e) => sum + e.spent);
    final autresSpent = totalExpenses - top5Spent;

    final items = <Widget>[];
    for (int i = 0; i < top5.length; i++) {
      items.add(Padding(
        padding: const EdgeInsets.symmetric(vertical: 3),
        child: Row(
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: colors[i % 5],
                borderRadius: BorderRadius.circular(3),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                '${top5[i].cat.name} (${AppConstants.formatAmountPlain(top5[i].spent)})',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppTheme.zinc300,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ));
    }

    // Add "Autres" if needed
    if (autresSpent > 0 && (sorted.length > 5 || categories.any((c) => (categorySpending[c.id] ?? 0) > 0 && !top5.any((e) => e.cat.id == c.id)))) {
      items.add(Padding(
        padding: const EdgeInsets.symmetric(vertical: 3),
        child: Row(
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: colors[5],
                borderRadius: BorderRadius.circular(3),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Autres (${AppConstants.formatAmountPlain(autresSpent)})',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppTheme.zinc300,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ));
    }

    return items;
  }
}

// ─── Budget Bars Section ───────────────────────────────────────────────

class _BudgetBarsSection extends ConsumerWidget {
  const _BudgetBarsSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final budgetAsync = ref.watch(currentBudgetProvider);
    final categoriesAsync = ref.watch(expenseCategoriesProvider);
    final monthlyTx = ref.watch(monthlyTransactionsProvider);
    final monthlyTransactions = monthlyTx.asData?.value ?? [];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Budgets',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.zinc100,
                  ),
                ),
                TextButton(
                  onPressed: () => context.push('/home/budgets'),
                  child: const Text(
                    'Voir tout',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppTheme.amberAccent,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            budgetAsync.when(
              loading: () => _buildBudgetShimmer(),
              error: (_, _) => const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Text(
                  'Aucun budget défini',
                  style: TextStyle(color: AppTheme.zinc500),
                ),
              ),
              data: (budget) {
                if (budget == null) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Text(
                      'Aucun budget défini pour ce mois',
                      style: TextStyle(color: AppTheme.zinc500),
                    ),
                  );
                }

                return categoriesAsync.when(
                  loading: () => _buildBudgetShimmer(),
                  error: (_, _) => const SizedBox.shrink(),
                  data: (categories) {
                    final expenseCategories =
                        categories.where((c) => c.type == 'expense').toList();
                    if (expenseCategories.isEmpty) {
                      return const SizedBox.shrink();
                    }

                    // Compute actual per-category spending from transactions
                    final Map<int, double> actualSpending = {};
                    for (final t in monthlyTransactions) {
                      if (t.type == 'expense') {
                        actualSpending[t.categoryId] =
                            (actualSpending[t.categoryId] ?? 0) + t.amount;
                      }
                    }

                    // Show up to 4 budget bars
                    final display =
                        expenseCategories.length > 4
                            ? expenseCategories.sublist(0, 4)
                            : expenseCategories;

                    return Column(
                      children: display.map((cat) {
                        final catBudget = cat.budget ?? 0;
                        final actualSpent = actualSpending[cat.id] ?? 0.0;
                        return _BudgetBar(
                          categoryName: cat.name,
                          icon: cat.icon,
                          color: Color(cat.color),
                          budget: catBudget > 0
                              ? catBudget
                              : budget.totalBudget / display.length,
                          spent: actualSpent,
                        );
                      }).toList(),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBudgetShimmer() {
    return Column(
      children: List.generate(
        3,
        (_) => Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 100,
                height: 12,
                decoration: BoxDecoration(
                  color: AppTheme.zinc800,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                height: 8,
                decoration: BoxDecoration(
                  color: AppTheme.zinc800,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BudgetBar extends StatelessWidget {
  final String categoryName;
  final String icon;
  final Color color;
  final double budget;
  final double spent;

  const _BudgetBar({
    required this.categoryName,
    required this.icon,
    required this.color,
    required this.budget,
    required this.spent,
  });

  @override
  Widget build(BuildContext context) {
    final ratio = budget > 0 ? (spent / budget).clamp(0.0, 1.0) : 0.0;
    final isOver = ratio >= 1.0;
    final displayColor = isOver ? AppTheme.redAccent : color;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    _mapIcon(icon),
                    size: 16,
                    color: color.withValues(alpha: 0.8),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    categoryName,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppTheme.zinc300,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              Text(
                '${AppConstants.formatAmountPlain(spent)} / ${AppConstants.formatAmountPlain(budget)}',
                style: const TextStyle(
                  fontSize: 11,
                  color: AppTheme.zinc500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: ratio,
              backgroundColor: AppTheme.zinc800,
              valueColor: AlwaysStoppedAnimation<Color>(displayColor),
              minHeight: 8,
            ),
          ),
        ],
      ),
    );
  }

  IconData _mapIcon(String iconName) {
    switch (iconName) {
      case 'restaurant':
        return Icons.restaurant;
      case 'directions_car':
        return Icons.directions_car;
      case 'shopping_bag':
        return Icons.shopping_bag;
      case 'movie':
        return Icons.movie;
      case 'favorite':
        return Icons.favorite;
      case 'school':
        return Icons.school;
      case 'home':
        return Icons.home;
      case 'bolt':
        return Icons.bolt;
      case 'work':
        return Icons.work;
      case 'computer':
        return Icons.computer;
      case 'card_giftcard':
        return Icons.card_giftcard;
      case 'more_horiz':
        return Icons.more_horiz;
      default:
        return Icons.circle;
    }
  }
}

// ─── Recent Transactions Section ───────────────────────────────────────

class _RecentTransactionsSection extends ConsumerWidget {
  const _RecentTransactionsSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recentAsync = ref.watch(recentTransactionsProvider);
    final categoriesAsync = ref.watch(allCategoriesProvider);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Transactions récentes',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.zinc100,
                  ),
                ),
                TextButton(
                  onPressed: () => context.push('/home/transactions'),
                  child: const Text(
                    'Voir tout',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppTheme.amberAccent,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            recentAsync.when(
              loading: () => const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Center(
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
              error: (_, _) => const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Center(
                  child: Text(
                    'Erreur de chargement',
                    style: TextStyle(color: AppTheme.zinc500),
                  ),
                ),
              ),
              data: (transactions) {
                if (transactions.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 24),
                    child: Center(
                      child: Column(
                        children: [
                          Icon(
                            Icons.receipt_long_outlined,
                            color: AppTheme.zinc600,
                            size: 36,
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Aucune transaction',
                            style: TextStyle(color: AppTheme.zinc500),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                final catMap = <int, Category>{};
                final catList = categoriesAsync.valueOrNull ?? [];
                for (final c in catList) {
                  catMap[c.id] = c;
                }

                return Column(
                  children: transactions.map((t) {
                    final category = catMap[t.categoryId];
                    return _TransactionRow(
                      transaction: t,
                      category: category,
                    );
                  }).toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _TransactionRow extends StatelessWidget {
  final Transaction transaction;
  final Category? category;

  const _TransactionRow({
    required this.transaction,
    this.category,
  });

  @override
  Widget build(BuildContext context) {
    final isExpense = transaction.type == 'expense';
    final catColor = category != null
        ? Color(category!.color)
        : AppTheme.zinc500;

    final date = DateTime.tryParse(transaction.date) ?? DateTime.now();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          // Icon
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: catColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              category != null
                  ? _mapCatIcon(category!.icon)
                  : Icons.receipt,
              size: 20,
              color: catColor,
            ),
          ),
          const SizedBox(width: 12),

          // Info
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
                const SizedBox(height: 2),
                Text(
                  DateFormat('dd/MM', 'fr_FR').format(date),
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppTheme.zinc500,
                  ),
                ),
              ],
            ),
          ),

          // Amount
          Text(
            isExpense ? '-${AppConstants.formatAmountPlain(transaction.amount)}' : AppConstants.formatAmount(transaction.amount),
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isExpense ? AppTheme.redAccent : AppTheme.greenAccent,
            ),
          ),
        ],
      ),
    );
  }

  IconData _mapCatIcon(String iconName) {
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
