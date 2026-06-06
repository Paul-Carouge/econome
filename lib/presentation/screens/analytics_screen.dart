import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:econome/core/theme/app_theme.dart';
import 'package:econome/core/constants/app_constants.dart';
import 'package:econome/presentation/providers/app_providers.dart';

// ─── Provider : Monthly trends for last 6 months ─────────────────────

class MonthlyTrendPoint {
  final String month;
  final double income;
  final double expense;
  final double balance;

  const MonthlyTrendPoint({
    required this.month,
    required this.income,
    required this.expense,
    required this.balance,
  });
}

final monthlyTrendsProvider = FutureProvider<List<MonthlyTrendPoint>>((ref) async {
  final repo = ref.read(transactionRepositoryProvider);
  final now = DateTime.now();
  final results = <MonthlyTrendPoint>[];

  for (int i = 5; i >= 0; i--) {
    final month = now.month - i;
    final year = now.year;
    final m = month <= 0 ? month + 12 : month;
    final y = month <= 0 ? year - 1 : year;

    final summary = await repo.getMonthlySummary(m, y);
    summary.when(
      onSuccess: (s) {
        final label = DateFormat('MMM', 'fr_FR').format(DateTime(y, m));
        results.add(MonthlyTrendPoint(
          month: label,
          income: s.income,
          expense: s.expenses,
          balance: s.balance,
        ));
      },
      onFailure: (_) {
        results.add(const MonthlyTrendPoint(
          month: '',
          income: 0,
          expense: 0,
          balance: 0,
        ));
      },
    );
  }

  return results;
});

// ─── Analytics Screen ─────────────────────────────────────────────────

class AnalyticsScreen extends ConsumerWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppTheme.zinc950,
      appBar: AppBar(
        title: const Text('Analyses'),
        actions: [
          Icon(Icons.analytics_outlined, color: AppTheme.zinc500, size: 20),
          const SizedBox(width: 16),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
        children: [
          const _TrendChartCard().animate().fadeIn(
            duration: 400.ms,
          ).slideX(begin: 0.05, end: 0, duration: 400.ms),

          const SizedBox(height: 20),

          const _StatsGrid().animate().fadeIn(
            duration: 400.ms,
            delay: 150.ms,
          ).slideX(begin: 0.05, end: 0, duration: 400.ms, delay: 150.ms),

          const SizedBox(height: 20),

          const _AverageCard().animate().fadeIn(
            duration: 400.ms,
            delay: 250.ms,
          ).slideX(begin: 0.05, end: 0, duration: 400.ms, delay: 250.ms),
        ],
      ),
    );
  }
}

// ─── Trend Chart ──────────────────────────────────────────────────────

class _TrendChartCard extends ConsumerWidget {
  const _TrendChartCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final trendsAsync = ref.watch(monthlyTrendsProvider);

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
                  'Évolution 6 mois',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.zinc100,
                  ),
                ),
                Icon(Icons.trending_up, color: AppTheme.zinc500, size: 20),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                _LegendDot(color: AppTheme.greenAccent, label: 'Revenus'),
                const SizedBox(width: 16),
                _LegendDot(color: AppTheme.redAccent, label: 'Dépenses'),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 220,
              child: trendsAsync.when(
                loading: () => const Center(
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                error: (_, __) => const Center(
                  child: Text(
                    'Données indisponibles',
                    style: TextStyle(color: AppTheme.zinc500),
                  ),
                ),
                data: (trends) {
                  if (trends.isEmpty || trends.every((t) => t.income == 0 && t.expense == 0)) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.bar_chart, color: AppTheme.zinc600, size: 40),
                          const SizedBox(height: 8),
                          const Text(
                            'Pas assez de données\npour afficher la tendance',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: AppTheme.zinc500),
                          ),
                        ],
                      ),
                    );
                  }
                  return LineChart(
                    LineChartData(
                      minY: 0,
                      gridData: FlGridData(
                        show: true,
                        drawVerticalLine: false,
                        horizontalInterval: _calcInterval(trends),
                        getDrawingHorizontalLine: (value) => FlLine(
                          color: AppTheme.zinc800,
                          strokeWidth: 1,
                        ),
                      ),
                      titlesData: FlTitlesData(
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 28,
                            getTitlesWidget: (value, meta) {
                              final idx = value.toInt();
                              if (idx < 0 || idx >= trends.length) return const SizedBox.shrink();
                              return Padding(
                                padding: const EdgeInsets.only(top: 6),
                                child: Text(
                                  trends[idx].month,
                                  style: const TextStyle(
                                    fontSize: 10,
                                    color: AppTheme.zinc500,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 48,
                            getTitlesWidget: (value, meta) {
                              if (value == 0) return const SizedBox.shrink();
                              return Text(
                                AppConstants.formatAmountCompact(value),
                                style: const TextStyle(
                                  fontSize: 9,
                                  color: AppTheme.zinc600,
                                ),
                              );
                            },
                          ),
                        ),
                        topTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        rightTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                      ),
                      borderData: FlBorderData(show: false),
                      lineBarsData: [
                        LineChartBarData(
                          spots: trends
                              .asMap()
                              .entries
                              .map((e) => FlSpot(e.key.toDouble(), e.value.income))
                              .toList(),
                          color: AppTheme.greenAccent,
                          barWidth: 2.5,
                          dotData: FlDotData(
                            show: true,
                            getDotPainter: (spot, percent, barData, index) {
                              return FlDotCirclePainter(
                                radius: 3,
                                color: AppTheme.greenAccent,
                                strokeWidth: 0,
                              );
                            },
                          ),
                          belowBarData: BarAreaData(
                            show: true,
                            color: AppTheme.greenAccent.withValues(alpha: 0.08),
                          ),
                          isCurved: true,
                          curveSmoothness: 0.3,
                        ),
                        LineChartBarData(
                          spots: trends
                              .asMap()
                              .entries
                              .map((e) => FlSpot(e.key.toDouble(), e.value.expense))
                              .toList(),
                          color: AppTheme.redAccent,
                          barWidth: 2.5,
                          dotData: FlDotData(
                            show: true,
                            getDotPainter: (spot, percent, barData, index) {
                              return FlDotCirclePainter(
                                radius: 3,
                                color: AppTheme.redAccent,
                                strokeWidth: 0,
                              );
                            },
                          ),
                          belowBarData: BarAreaData(
                            show: true,
                            color: AppTheme.redAccent.withValues(alpha: 0.08),
                          ),
                          isCurved: true,
                          curveSmoothness: 0.3,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  double _calcInterval(List<MonthlyTrendPoint> trends) {
    final maxVal = trends.fold<double>(0, (m, t) => [m, t.income, t.expense].reduce((a, b) => a > b ? a : b));
    if (maxVal <= 0) return 100;
    if (maxVal <= 500) return 100;
    if (maxVal <= 2000) return 500;
    if (maxVal <= 5000) return 1000;
    return (maxVal / 4).ceilToDouble();
  }
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;
  const _LegendDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10, height: 10,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: AppTheme.zinc400),
        ),
      ],
    );
  }
}

// ─── Stats Grid ───────────────────────────────────────────────────────

class _StatsGrid extends ConsumerWidget {
  const _StatsGrid();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final info = ref.watch(dashboardInfoProvider);
    final totalTx = ref.watch(monthlyTransactionsProvider);
    final txCount = totalTx.asData?.value.length ?? 0;
    final avgTransaction = txCount > 0 ? (info.totalExpenses / txCount) : 0.0;
    final savingsRate = info.totalIncome > 0
        ? ((info.totalIncome - info.totalExpenses) / info.totalIncome * 100)
        : 0.0;

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
                  'Statistiques du mois',
                  style: TextStyle(
                    fontSize: 16, fontWeight: FontWeight.w600,
                    color: AppTheme.zinc100,
                  ),
                ),
                Icon(Icons.grid_view, color: AppTheme.zinc500, size: 20),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(child: _StatTile(
                  icon: Icons.receipt_long,
                  label: 'Transactions',
                  value: '$txCount',
                  color: AppTheme.amberAccent,
                )),
                const SizedBox(width: 12),
                Expanded(child: _StatTile(
                  icon: Icons.trending_down,
                  label: 'Moy. dépense',
                  value: AppConstants.formatAmountCompact(avgTransaction),
                  color: AppTheme.orangeAccent,
                )),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _StatTile(
                  icon: Icons.savings,
                  label: "Taux d'épargne",
                  value: '${savingsRate.toStringAsFixed(1)}%',
                  color: savingsRate >= 0 ? AppTheme.greenAccent : AppTheme.redAccent,
                )),
                const SizedBox(width: 12),
                Expanded(child: _StatTile(
                  icon: Icons.account_balance_wallet,
                  label: 'Solde',
                  value: AppConstants.formatAmountCompact(info.balance),
                  color: info.balance >= 0 ? AppTheme.greenAccent : AppTheme.redAccent,
                )),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.zinc800.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.zinc700.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 16),
              const SizedBox(width: 6),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 11, color: AppTheme.zinc400,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 18, fontWeight: FontWeight.w700, color: color,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Average / Projection Card ───────────────────────────────────────

class _AverageCard extends ConsumerWidget {
  const _AverageCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final info = ref.watch(dashboardInfoProvider);
    final budgetAsync = ref.watch(currentBudgetProvider);

    final daysInMonth = DateTime(info.year, info.month + 1, 0).day;
    final dailyAvg = daysInMonth > 0 ? info.totalExpenses / daysInMonth : 0.0;
    final projectedTotal = dailyAvg * daysInMonth;
    final budget = budgetAsync.asData?.value;

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
                  'Projections',
                  style: TextStyle(
                    fontSize: 16, fontWeight: FontWeight.w600,
                    color: AppTheme.zinc100,
                  ),
                ),
                Icon(Icons.calendar_month, color: AppTheme.zinc500, size: 20),
              ],
            ),
            const SizedBox(height: 20),
            _ProjectionRow(
              label: 'Moyenne quotidienne',
              value: AppConstants.formatAmountCompact(dailyAvg),
              icon: Icons.calendar_view_day,
              color: AppTheme.amberAccent,
            ),
            const SizedBox(height: 12),
            _ProjectionRow(
              label: 'Projection fin de mois',
              value: AppConstants.formatAmountCompact(projectedTotal),
              icon: Icons.north_east,
              color: projectedTotal <= (budget?.totalBudget ?? double.infinity)
                  ? AppTheme.greenAccent
                  : AppTheme.redAccent,
            ),
            if (budget != null && budget.totalBudget > 0) ...[
              const SizedBox(height: 12),
              _ProjectionRow(
                label: 'Budget mensuel',
                value: AppConstants.formatAmountCompact(budget.totalBudget),
                icon: Icons.account_balance_wallet,
                color: AppTheme.amberAccent,
              ),
              const SizedBox(height: 12),
              _ProjectionRow(
                label: 'Restant budget',
                value: AppConstants.formatAmountCompact(budget.totalBudget - info.totalExpenses),
                icon: Icons.trending_flat,
                color: (budget.totalBudget - info.totalExpenses) >= 0
                    ? AppTheme.greenAccent
                    : AppTheme.redAccent,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ProjectionRow extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _ProjectionRow({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.zinc800.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 13, color: AppTheme.zinc400,
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 15, fontWeight: FontWeight.w700, color: color,
            ),
          ),
        ],
      ),
    );
  }
}
