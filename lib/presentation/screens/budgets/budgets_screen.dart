import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' hide Column;
import 'package:econome/core/theme/app_theme.dart';
import 'package:econome/core/constants/app_constants.dart';
import 'package:econome/presentation/providers/app_providers.dart';
import 'package:econome/data/database/app_database.dart';

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
              data: (budget) => _BudgetSummaryCard(
                budget: budget,
                onTap: () => _showBudgetDialog(context, ref, budget),
              ),
              loading: () => const _SummarySkeleton(),
              error: (e, _) => _ErrorCard(message: 'Erreur budget: $e'),
            ),
            const SizedBox(height: 24),

            // ─── Info Card ─────────────────────────────────────────────
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: AppTheme.amberAccent, size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Le budget mensuel est comparé à vos dépenses totales sur le tableau de bord. Il vous aide à voir si vous dépassez vos limites.',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppTheme.zinc400,
                            ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // ─── Per-Category Budgets ──────────────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Budgets par catégorie',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                TextButton.icon(
                  onPressed: () => _showBudgetDialog(context, ref, null),
                  icon: const Icon(Icons.edit, size: 18),
                  label: const Text('Définir'),
                ),
              ],
            ),
            const SizedBox(height: 12),

            categoriesAsync.when(
              data: (categories) {
                if (categories.isEmpty) {
                  return _EmptyBudgets();
                }
                return Column(
                  children: categories
                      .map((cat) => _CategoryBudgetCard(
                            category: cat,
                            transactions: monthlyTx.asData?.value ?? [],
                            onTap: () =>
                                _showCategoryBudgetDialog(context, ref, cat),
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

  // ─── Monthly Budget Dialog ─────────────────────────────────────────
  void _showBudgetDialog(BuildContext context, WidgetRef ref, Budget? existing) {
    final controller = TextEditingController(
      text: existing != null
          ? existing.totalBudget.toStringAsFixed(0)
          : '',
    );

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.zinc900,
        title: const Text('Budget mensuel'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            hintText: 'Montant',
            hintStyle: const TextStyle(color: AppTheme.zinc500),
            filled: true,
            fillColor: AppTheme.zinc800,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
          style: const TextStyle(color: AppTheme.zinc100),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () async {
              final text = controller.text.trim();
              if (text.isEmpty) return;
              final amount = double.tryParse(text);
              if (amount == null || amount <= 0) return;

              final now = DateTime.now();
              final dao = ref.read(budgetDaoProvider);
              await dao.upsert(BudgetsCompanion(
                totalBudget: Value(amount),
                month: Value(now.month),
                year: Value(now.year),
                createdAt: Value(now.toIso8601String()),
              ));
              ref.invalidate(currentBudgetProvider);
              if (ctx.mounted) Navigator.pop(ctx);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.amberAccent,
              foregroundColor: AppTheme.zinc950,
            ),
            child: const Text('Enregistrer'),
          ),
        ],
      ),
    );
  }

  // ─── Category Budget Dialog ────────────────────────────────────────
  void _showCategoryBudgetDialog(
      BuildContext context, WidgetRef ref, Category category) {
    final controller = TextEditingController(
      text: category.budget != null && category.budget! > 0
          ? category.budget!.toStringAsFixed(0)
          : '',
    );

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.zinc900,
        title: Text('Budget — ${category.name}'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            hintText: 'Montant du budget',
            hintStyle: const TextStyle(color: AppTheme.zinc500),
            filled: true,
            fillColor: AppTheme.zinc800,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
          style: const TextStyle(color: AppTheme.zinc100),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Annuler'),
          ),
          if (category.budget != null && category.budget! > 0)
            TextButton(
              onPressed: () async {
                final dao = ref.read(categoryDaoProvider);
                await dao.updateEntry(
                  category.id,
                  CategoriesCompanion(budget: Value(null)),
                );
                ref.invalidate(expenseCategoriesProvider);
                if (ctx.mounted) Navigator.pop(ctx);
              },
              child: const Text('Supprimer',
                  style: TextStyle(color: AppTheme.redAccent)),
            ),
          ElevatedButton(
            onPressed: () async {
              final text = controller.text.trim();
              if (text.isEmpty) return;
              final amount = double.tryParse(text);
              if (amount == null || amount <= 0) return;

              final dao = ref.read(categoryDaoProvider);
              await dao.updateEntry(
                category.id,
                CategoriesCompanion(budget: Value(amount)),
              );
              ref.invalidate(expenseCategoriesProvider);
              if (ctx.mounted) Navigator.pop(ctx);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.amberAccent,
              foregroundColor: AppTheme.zinc950,
            ),
            child: const Text('Enregistrer'),
          ),
        ],
      ),
    );
  }
}

// ─── Summary Card ──────────────────────────────────────────────────────

class _BudgetSummaryCard extends StatelessWidget {
  final Budget? budget;
  final VoidCallback onTap;

  const _BudgetSummaryCard({required this.budget, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final totalBudget = budget?.totalBudget ?? 0.0;
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
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
                          style: Theme.of(context)
                              .textTheme
                              .displaySmall
                              ?.copyWith(
                                color: AppTheme.zinc100,
                              ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.edit, color: AppTheme.zinc500, size: 20),
                ],
              ),
              if (totalBudget <= 0) ...[
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: onTap,
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('Définir un budget mensuel'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.amberAccent,
                      side: const BorderSide(color: AppTheme.amberAccent),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ],
          ),
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
  final VoidCallback onTap;

  const _CategoryBudgetCard({
    required this.category,
    required this.transactions,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final budgetAmount = category.budget ?? 0;
    final spent = transactions
        .where((t) => t.categoryId == category.id && t.type == 'expense')
        .fold<double>(0, (sum, t) => sum + t.amount);
    final progress =
        budgetAmount > 0 ? (spent / budgetAmount).clamp(0.0, 1.0) : 0.0;
    final isOverBudget = spent > budgetAmount && budgetAmount > 0;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    AppConstants.categoryIcons[category.icon] ??
                        Icons.category,
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
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(
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
                  color:
                      isOverBudget ? AppTheme.redAccent : AppTheme.amberAccent,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                '${(progress * 100).toStringAsFixed(0)}% utilisé',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color:
                          isOverBudget ? AppTheme.redAccent : AppTheme.zinc400,
                    ),
              ),
            ],
          ),
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
              'Appuyez sur "Définir" ci-dessus pour ajouter un budget par catégorie.',
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
      children: List.generate(
        3,
        (_) => Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        color: AppTheme.zinc800,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Container(
                        height: 16,
                        width: 100,
                        decoration: BoxDecoration(
                          color: AppTheme.zinc800,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                    Container(
                      height: 16,
                      width: 80,
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
        ),
      ),
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
