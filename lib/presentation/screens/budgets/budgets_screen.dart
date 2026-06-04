import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:budgethink/core/theme/app_theme.dart';
import 'package:budgethink/core/constants/app_constants.dart';
import 'package:budgethink/presentation/providers/app_providers.dart';
import 'package:budgethink/data/database/app_database.dart';

class BudgetsScreen extends ConsumerWidget {
  const BudgetsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final budgetAsync = ref.watch(currentBudgetProvider);
    final categoriesAsync = ref.watch(expenseCategoriesProvider);
    final monthlyTx = ref.watch(monthlyTransactionsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Budgets')),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(currentBudgetProvider);
          ref.invalidate(expenseCategoriesProvider);
        },
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // ─── Total Budget Summary Card ──────────────────────────────
            budgetAsync.when(
              data: (budget) => _BudgetSummaryCard(budget: budget),
              loading: () => const _SummarySkeleton(),
              error: (e, _) => _ErrorCard(message: 'Erreur budget: $e'),
            ),
            const SizedBox(height: 24),

            // ─── Per-Category Budgets ──────────────────────────────────
            Text(
              'Budgets par catégorie',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),

            categoriesAsync.when(
              data: (categories) {
                final withBudgets = categories.where((c) => c.budget != null && c.budget! > 0).toList();
                if (withBudgets.isEmpty) {
                  return _EmptyBudgets();
                }
                return Column(
                  children: withBudgets
                      .map((cat) => _CategoryBudgetCard(
                            category: cat,
                            transactions: monthlyTx.asData?.value ?? [],
                          ))
                      .toList(),
                );
              },
              loading: () => const _CategoryListSkeleton(),
              error: (e, _) => _ErrorCard(message: 'Erreur catégories: $e'),
            ),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }
}

// ─── Summary Card ──────────────────────────────────────────────────────

class _BudgetSummaryCard extends StatelessWidget {
  final Budget? budget;

  const _BudgetSummaryCard({required this.budget});

  @override
  Widget build(BuildContext context) {
    final totalBudget = budget?.totalBudget ?? 0.0;
    // Monthly total spent from categories — we'll compute from categories budget data
    return Card(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppTheme.amberAccent.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.account_balance_wallet,
                    color: AppTheme.amberAccent,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Budget mensuel',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        totalBudget > 0
                            ? AppConstants.formatAmountPlain(totalBudget)
                            : 'Non défini',
                        style: Theme.of(context).textTheme.displaySmall?.copyWith(
                              color: AppTheme.zinc100,
                            ),
                      ),
                    ],
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

class _SummarySkeleton extends StatelessWidget {
  const _SummarySkeleton();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 20,
              width: 120,
              decoration: BoxDecoration(
                color: AppTheme.zinc800,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(height: 12),
            Container(
              height: 32,
              width: 180,
              decoration: BoxDecoration(
                color: AppTheme.zinc800,
                borderRadius: BorderRadius.circular(6),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Category Budget Card ──────────────────────────────────────────────

class _CategoryBudgetCard extends StatelessWidget {
  final Category category;
  final List<Transaction> transactions;

  const _CategoryBudgetCard({
    required this.category,
    required this.transactions,
  });

  @override
  Widget build(BuildContext context) {
    final budgetAmount = category.budget ?? 0;
    final spent = transactions
        .where((t) =>
            t.categoryId == category.id && t.type == 'expense')
        .fold<double>(0, (sum, t) => sum + t.amount);
    final progress = budgetAmount > 0 ? (spent / budgetAmount).clamp(0.0, 1.0) : 0.0;
    final isOverBudget = spent > budgetAmount && budgetAmount > 0;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  AppConstants.categoryIcons[category.icon] ?? Icons.category,
                  color: Color(category.color),
                  size: 20,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    category.name,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      AppConstants.formatAmountPlain(spent),
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: isOverBudget
                                ? AppTheme.redAccent
                                : AppTheme.zinc100,
                          ),
                    ),
                    Text(
                      '/ ${AppConstants.formatAmountPlain(budgetAmount)}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 8,
                backgroundColor: AppTheme.zinc800,
                color: isOverBudget ? AppTheme.redAccent : AppTheme.amberAccent,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              '${(progress * 100).toStringAsFixed(0)}% utilisé',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: isOverBudget ? AppTheme.redAccent : AppTheme.zinc400,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Empty & Error States ──────────────────────────────────────────────

class _EmptyBudgets extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            Icon(
              Icons.tune,
              size: 48,
              color: AppTheme.zinc600,
            ),
            const SizedBox(height: 12),
            Text(
              'Aucun budget défini',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppTheme.zinc400,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              'Modifiez une catégorie depuis la section\ntransactions pour définir un budget.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryListSkeleton extends StatelessWidget {
  const _CategoryListSkeleton();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(3, (_) => Card(
        margin: const EdgeInsets.only(bottom: 12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 20, height: 20,
                    decoration: BoxDecoration(
                      color: AppTheme.zinc800,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Container(
                      height: 16, width: 100,
                      decoration: BoxDecoration(
                        color: AppTheme.zinc800,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                  Container(
                    height: 16, width: 80,
                    decoration: BoxDecoration(
                      color: AppTheme.zinc800,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                height: 8,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppTheme.zinc800,
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
            ],
          ),
        ),
      )),
    );
  }
}

class _ErrorCard extends StatelessWidget {
  final String message;

  const _ErrorCard({required this.message});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const Icon(Icons.error_outline, color: AppTheme.redAccent),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.redAccent,
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
