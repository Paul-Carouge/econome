import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_confetti/flutter_confetti.dart';
import 'package:econome/core/theme/app_theme.dart';
import 'package:econome/core/utils/icon_resolver.dart';
import 'package:econome/core/constants/app_constants.dart';
import 'package:econome/presentation/providers/app_providers.dart';
import 'package:econome/data/database/app_database.dart';
import 'package:econome/core/utils/notifications.dart';

class SavingsScreen extends ConsumerWidget {
  const SavingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final savingsAsync = ref.watch(savingsListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Épargne'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => context.push('/savings/add'),
          ),
        ],
      ),
      body: savingsAsync.when(
        data: (goals) {
          if (goals.isEmpty) {
            return _EmptySavings();
          }
          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
            itemCount: goals.length,
            itemBuilder: (context, index) {
              final goal = goals[index];
              return _SavingsGoalCard(
                goal: goal,
                onTap: () => _showContributeSheet(context, ref, goal),
                onEdit: () => context.push('/savings/edit', extra: goal),
                onDelete: () => _confirmDelete(context, ref, goal),
              );
            },
          );
        },
        loading: () => const _SavingsListSkeleton(),
        error: (e, _) => Center(
          child: Text(
            'Erreur: $e',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.redAccent,
                ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/savings/add'),
        backgroundColor: AppTheme.amberAccent,
        foregroundColor: AppTheme.zinc950,
        icon: const Icon(Icons.add),
        label: const Text('Nouvel objectif'),
      ),
    );
  }

  Future<void> _showContributeSheet(BuildContext context, WidgetRef ref, SavingsGoal goal) async {
    final amountController = TextEditingController();
    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
            left: 24, right: 24, top: 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40, height: 4,
                  decoration: BoxDecoration(
                    color: AppTheme.zinc700,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Contribuer à',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 4),
              Text(
                goal.name,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(
                '${AppConstants.formatAmountPlain(goal.currentAmount)} / ${AppConstants.formatAmountPlain(goal.targetAmount)}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 20),
              TextField(
                controller: amountController,
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Montant',
                  prefixText: '€ ',
                ),
                autofocus: true,
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () {
                    final amount = double.tryParse(amountController.text.replaceAll(',', '.'));
                    if (amount == null || amount <= 0) return;
                    ref.read(savingsDaoProvider).addContribution(goal.id, amount);
                    Navigator.of(ctx).pop(true); // pop with true = confetti!
                  },
                  child: const Text('Ajouter'),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );

    if (result == true && context.mounted) {
      HapticFeedback.heavyImpact();
      Confetti.launch(
        context,
        options: ConfettiOptions(
          particleCount: 60,
          colors: const [
            AppTheme.amberAccent,
            AppTheme.amberLight,
            AppTheme.greenAccent,
            AppTheme.zinc300,
            Color(0xFFF97316),
          ],
          spread: 120,
          startVelocity: 40,
        ),
      );
    }
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref, SavingsGoal goal) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Supprimer l\'objectif'),
        content: Text('Êtes-vous sûr de vouloir supprimer « ${goal.name} » ?\n\nCette action est irréversible.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Annuler'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: AppTheme.redAccent,
            ),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await ref.read(savingsDaoProvider).deleteEntry(goal.id);
      if (context.mounted) {
        HapticFeedback.heavyImpact();
        showSuccess(context, 'Objectif supprimé');
      }
    }
  }
}

// ─── Savings Goal Card ─────────────────────────────────────────────────

class _SavingsGoalCard extends StatelessWidget {
  final SavingsGoal goal;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _SavingsGoalCard({
    required this.goal,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final progress = goal.targetAmount > 0
        ? (goal.currentAmount / goal.targetAmount).clamp(0.0, 1.0)
        : 0.0;
    final remaining = (goal.targetAmount - goal.currentAmount).clamp(0.0, double.infinity);
    final isCompleted = goal.isCompleted || goal.currentAmount >= goal.targetAmount;
    final deadline = goal.deadline != null ? DateTime.tryParse(goal.deadline!) : null;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: isCompleted ? null : onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Color(goal.color).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      resolveCategoryIcon(goal.icon),
                      color: Color(goal.color),
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                goal.name,
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                            ),
                            if (isCompleted)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppTheme.greenAccent.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  'Atteint',
                                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                        color: AppTheme.greenAccent,
                                      ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${AppConstants.formatAmountPlain(goal.currentAmount)} / ${AppConstants.formatAmountPlain(goal.targetAmount)}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  PopupMenuButton<String>(
                    icon: Icon(
                      Icons.more_horiz,
                      color: AppTheme.zinc400,
                    ),
                    onSelected: (value) {
                      switch (value) {
                        case 'edit': onEdit();
                        case 'delete': onDelete();
                      }
                    },
                    itemBuilder: (ctx) => [
                      const PopupMenuItem(
                        value: 'edit',
                        child: ListTile(
                          leading: Icon(Icons.edit_outlined),
                          title: Text('Modifier'),
                          contentPadding: EdgeInsets.zero,
                          visualDensity: VisualDensity.compact,
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: ListTile(
                          leading: Icon(Icons.delete_outline, color: AppTheme.redAccent),
                          title: Text('Supprimer', style: TextStyle(color: AppTheme.redAccent)),
                          contentPadding: EdgeInsets.zero,
                          visualDensity: VisualDensity.compact,
                        ),
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
                  color: isCompleted ? AppTheme.greenAccent : AppTheme.amberAccent,
                ),
              ),
              const SizedBox(height: 6),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${(progress * 100).toStringAsFixed(1)}%',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: isCompleted ? AppTheme.greenAccent : AppTheme.amberAccent,
                        ),
                  ),
                  if (!isCompleted)
                    Text(
                      'Reste ${AppConstants.formatAmountPlain(remaining)}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  if (deadline != null)
                    Text(
                      'Avant le ${AppConstants.formatDate(deadline)}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                ],
              ),
              if (goal.notes != null && goal.notes!.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  goal.notes!,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.zinc500,
                        fontStyle: FontStyle.italic,
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

// ─── Empty State ───────────────────────────────────────────────────────

class _EmptySavings extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.savings_outlined,
            size: 64,
            color: AppTheme.zinc600,
          ),
          const SizedBox(height: 16),
          Text(
            'Aucun objectif d\'épargne',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: AppTheme.zinc400,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Créez votre premier objectif\nd\'épargne dès maintenant !',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}

// ─── Skeleton ──────────────────────────────────────────────────────────

class _SavingsListSkeleton extends StatelessWidget {
  const _SavingsListSkeleton();

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
      itemCount: 3,
      itemBuilder: (_, _) => Card(
        margin: const EdgeInsets.only(bottom: 12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 38, height: 38,
                    decoration: BoxDecoration(
                      color: AppTheme.zinc800,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          height: 16, width: 120,
                          decoration: BoxDecoration(
                            color: AppTheme.zinc800,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Container(
                          height: 12, width: 160,
                          decoration: BoxDecoration(
                            color: AppTheme.zinc800,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ],
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
    );
  }
}
