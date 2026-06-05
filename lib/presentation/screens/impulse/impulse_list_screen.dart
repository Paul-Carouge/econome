import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:econome/core/theme/app_theme.dart';
import 'package:econome/data/database/app_database.dart';
import 'package:econome/presentation/providers/app_providers.dart';
import 'package:econome/core/utils/notifications.dart';
import 'package:econome/core/services/notification_service.dart';

// ─── Main Impulse Screen ───────────────────────────────────────────────

class ImpulseListScreen extends ConsumerStatefulWidget {
  const ImpulseListScreen({super.key});

  @override
  ConsumerState<ImpulseListScreen> createState() => _ImpulseListScreenState();
}

class _ImpulseListScreenState extends ConsumerState<ImpulseListScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Anti-Impulsion'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => context.push('/impulse/add'),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppTheme.amberAccent,
          labelColor: AppTheme.amberAccent,
          unselectedLabelColor: AppTheme.zinc500,
          tabs: const [
            Tab(text: 'En attente'),
            Tab(text: 'Approuvés'),
            Tab(text: 'Ignorés'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          _StatusTab(status: 'cooling'),
          _StatusTab(status: 'approved'),
          _StatusTab(status: 'dismissed'),
        ],
      ),
    );
  }
}

// ─── Status Tab ───────────────────────────────────────────────────────

class _StatusTab extends ConsumerWidget {
  final String status;
  const _StatusTab({required this.status});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final itemsAsync = ref.watch(impulseListProvider);

    return itemsAsync.when(
      data: (allItems) {
        final items = allItems.where((i) => i.status == status).toList();
        if (items.isEmpty) {
          return _EmptyState(status: status);
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: items.length,
          itemBuilder: (context, index) => _ImpulseCard(
            item: items[index],
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => _ErrorState(message: e.toString()),
    );
  }
}

// ─── Impulse Card ───────────────────────────────────────────────────────

class _ImpulseCard extends ConsumerWidget {
  final ImpulseItem item;

  const _ImpulseCard({
    required this.item,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isApproved = item.status == 'approved';
    final isDismissed = item.status == 'dismissed';
    final isCooling = item.status == 'cooling';
    final showActions = isCooling || isApproved;

    final opacity = isDismissed ? 0.5 : 1.0;

    // Check if cooling period is still active
    final coolingEnd = DateTime.tryParse(item.coolingUntil);
    final isCoolingActive =
        isCooling && coolingEnd != null && DateTime.now().isBefore(coolingEnd);

    return Dismissible(
      key: ValueKey(item.id),
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
              'Supprimer "${item.name}" (${item.amount.toStringAsFixed(2)} €) ?',
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
        await ref.read(impulseRepositoryProvider).deleteEntry(item.id);
      },
      child: Opacity(
        opacity: opacity,
        child: Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header row
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: isApproved
                            ? AppTheme.greenAccent.withValues(alpha: 0.15)
                            : isDismissed
                                ? AppTheme.redAccent.withValues(alpha: 0.15)
                                : AppTheme.amberAccent.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        isApproved
                            ? Icons.check_circle
                            : isDismissed
                                ? Icons.cancel
                                : Icons.timer,
                        color: isApproved
                            ? AppTheme.greenAccent
                            : isDismissed
                                ? AppTheme.redAccent
                                : AppTheme.amberAccent,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.name,
                            style: Theme.of(context).textTheme.titleMedium,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          if (item.link != null && item.link!.isNotEmpty)
                            Text(
                              item.link!,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    color: AppTheme.amberAccent,
                                  ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                        ],
                      ),
                    ),
                    Text(
                      '${item.amount.toStringAsFixed(2)} €',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: isApproved
                                ? AppTheme.greenAccent
                                : isDismissed
                                    ? AppTheme.zinc500
                                    : AppTheme.amberAccent,
                          ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: Icon(
                        Icons.delete_outline,
                        size: 20,
                        color: AppTheme.zinc500,
                      ),
                      onPressed: () => _handleDelete(context, ref),
                      tooltip: 'Supprimer',
                    ),
                  ],
                ),

                // Notes
                if (item.notes != null && item.notes!.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    item.notes!,
                    style: Theme.of(context).textTheme.bodySmall,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],

                // Cooling countdown
                if (isCooling) ...[
                  const SizedBox(height: 12),
                  _CoolingTimer(coolingUntil: item.coolingUntil),
                ],

                // Status badges
                if (isApproved && item.approvedAt != null) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.check, size: 14, color: AppTheme.greenAccent),
                      const SizedBox(width: 4),
                      Text(
                        'Approuvé le ${_formatDate(item.approvedAt!)}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppTheme.greenAccent,
                            ),
                      ),
                    ],
                  ),
                ],

                if (isDismissed && item.dismissedAt != null) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.cancel, size: 14, color: AppTheme.zinc500),
                      const SizedBox(width: 4),
                      Text(
                        'Ignoré le ${_formatDate(item.dismissedAt!)}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppTheme.zinc500,
                            ),
                      ),
                    ],
                  ),
                ],

                // Action buttons
                if (showActions) ...[
                  const SizedBox(height: 12),
                  if (isCooling)
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => _handleDismiss(context, ref),
                            icon: const Icon(Icons.close, size: 18),
                            label: const Text('Ignorer'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppTheme.zinc400,
                              side: const BorderSide(color: AppTheme.zinc700),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: FilledButton.icon(
                            onPressed: isCoolingActive
                                ? null
                                : () => _handleApprove(context, ref),
                            icon: const Icon(Icons.check, size: 18),
                            label: const Text('Approuver'),
                          ),
                        ),
                      ],
                    ),
                  if (isApproved)
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () => _handleAddTransaction(context),
                        icon: const Icon(Icons.add, size: 18),
                        label: const Text('Ajouter comme transaction'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppTheme.amberAccent,
                          side: const BorderSide(color: AppTheme.amberAccent),
                        ),
                      ),
                    ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _handleApprove(BuildContext context, WidgetRef ref) async {
    // Check if cooling period has elapsed
    final coolingEnd = DateTime.tryParse(item.coolingUntil);
    if (coolingEnd != null) {
      final now = DateTime.now();
      if (now.isBefore(coolingEnd)) {
        final remaining = coolingEnd.difference(now);
        if (context.mounted) {
          showInfo(
              context, 'Encore ${remaining.inHours}h de période de refroidissement');
        }
        return;
      }
    }

    // 3-step dissuasion dialog
    if (!context.mounted) return;
    final step1 = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.zinc900,
        title: const Icon(Icons.psychology, size: 40, color: AppTheme.amberAccent),
        content: const Text(
          'En avez-vous vraiment besoin ?\nRéfléchissez à l\'utilité réelle de cet achat.',
          style: TextStyle(color: AppTheme.zinc300),
          textAlign: TextAlign.center,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Annuler'),
          ),
          FilledButton(
            onPressed: () {
              HapticFeedback.mediumImpact();
              Navigator.of(ctx).pop(true);
            },
            child: const Text('J\'y ai réfléchi'),
          ),
        ],
      ),
    );

    if (step1 != true || !context.mounted) return;

    final step2 = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.zinc900,
        title: const Icon(Icons.inventory_2, size: 40, color: AppTheme.amberAccent),
        content: const Text(
          'Avez-vous déjà quelque chose qui peut le remplacer ?',
          style: TextStyle(color: AppTheme.zinc300),
          textAlign: TextAlign.center,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Annuler'),
          ),
          FilledButton(
            onPressed: () {
              HapticFeedback.mediumImpact();
              Navigator.of(ctx).pop(true);
            },
            child: const Text('Je n\'ai pas d\'équivalent'),
          ),
        ],
      ),
    );

    if (step2 != true || !context.mounted) return;

    final step3 = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.zinc900,
        title: const Icon(Icons.schedule, size: 40, color: AppTheme.amberAccent),
        content: const Text(
          'Pouvez-vous attendre encore 24h ?',
          style: TextStyle(color: AppTheme.zinc300),
          textAlign: TextAlign.center,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Non, j\'attends'),
          ),
          FilledButton(
            onPressed: () {
              HapticFeedback.mediumImpact();
              Navigator.of(ctx).pop(true);
            },
            child: const Text('Je veux vraiment l\'acheter'),
          ),
        ],
      ),
    );

    if (step3 != true || !context.mounted) return;

    // All 3 steps passed — proceed with approval
    final result = await ref.read(impulseRepositoryProvider).updateStatus(item.id, 'approved');
    if (context.mounted) {
      result.when(
        onSuccess: (_) {
          // Cancel the cooling-end notification since it's been resolved
          cancelCoolingReminder(item.id);
          showSuccess(context, 'Achat approuvé !');
        },
        onFailure: (error) {
          showError(context, 'Erreur: ${error.message}');
        },
      );
    }
  }

  void _handleDismiss(BuildContext context, WidgetRef ref) async {
    final result = await ref.read(impulseRepositoryProvider).updateStatus(item.id, 'dismissed');
    if (context.mounted) {
      result.when(
        onSuccess: (_) {
          // Cancel the cooling-end notification since it's been resolved
          cancelCoolingReminder(item.id);
          showInfo(context, 'Achat ignoré');
        },
        onFailure: (error) {
          showError(context, 'Erreur: ${error.message}');
        },
      );
    }
  }

  void _handleDelete(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.zinc900,
        title: const Text('Supprimer ?'),
        content: Text(
          'Supprimer "${item.name}" (${item.amount.toStringAsFixed(2)} €) ?',
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

    if (confirmed == true) {
      HapticFeedback.mediumImpact();
      // Cancel any pending cooling notification for this item
      cancelCoolingReminder(item.id);
      final result = await ref.read(impulseRepositoryProvider).deleteEntry(item.id);
      if (context.mounted) {
        result.when(
          onSuccess: (_) {
            showSuccess(context, 'Achat supprimé');
          },
          onFailure: (error) {
            showError(context, 'Erreur: ${error.message}');
          },
        );
      }
    }
  }

  void _handleAddTransaction(BuildContext context) {
    context.push('/transactions/add', extra: {
      'prefill_amount': item.amount,
      'prefill_description': item.name,
      'prefill_category_id': item.categoryId,
      'prefill_notes': item.notes,
    });
  }

  String _formatDate(String isoDate) {
    try {
      final dt = DateTime.parse(isoDate);
      return '${dt.day.toString().padLeft(2, '0')}/'
          '${dt.month.toString().padLeft(2, '0')}/'
          '${dt.year}';
    } catch (_) {
      return isoDate;
    }
  }
}

// ─── Cooling Timer ─────────────────────────────────────────────────────

class _CoolingTimer extends StatefulWidget {
  final String coolingUntil;
  const _CoolingTimer({required this.coolingUntil});

  @override
  State<_CoolingTimer> createState() => _CoolingTimerState();
}

class _CoolingTimerState extends State<_CoolingTimer> {
  late DateTime _target;

  @override
  void initState() {
    super.initState();
    _target = DateTime.parse(widget.coolingUntil);
    _startTimer();
  }

  void _startTimer() {
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() {});
        _startTimer();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final remaining = _target.difference(DateTime.now());

    if (remaining.isNegative) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: AppTheme.greenAccent.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.check_circle, size: 14, color: AppTheme.greenAccent),
            const SizedBox(width: 6),
            Text(
              'Période d\'attente terminée',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.greenAccent,
                    fontWeight: FontWeight.w500,
                  ),
            ),
          ],
        ),
      );
    }

    final hours = remaining.inHours;
    final minutes = remaining.inMinutes.remainder(60);
    final seconds = remaining.inSeconds.remainder(60);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppTheme.amberAccent.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.amberAccent.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Icon(Icons.timer, size: 16, color: AppTheme.amberAccent),
          const SizedBox(width: 8),
          Text(
            'Temps restant : ',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppTheme.zinc400,
                ),
          ),
          Text(
            '${hours.toString().padLeft(2, '0')}:'
            '${minutes.toString().padLeft(2, '0')}:'
            '${seconds.toString().padLeft(2, '0')}',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.amberAccent,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'monospace',
                ),
          ),
        ],
      ),
    );
  }
}

// ─── Shared Widgets ────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  final String status;

  const _EmptyState({required this.status});

  @override
  Widget build(BuildContext context) {
    final String message;
    final String subtitle;
    final IconData icon;

    switch (status) {
      case 'cooling':
        icon = Icons.timer_outlined;
        message = 'Aucun achat en attente';
        subtitle = 'Ajoutez un achat impulsif pour appliquer la règle des 24h';
      case 'approved':
        icon = Icons.check_circle_outline;
        message = 'Aucun achat approuvé';
        subtitle = 'Les achats que vous approuvez apparaîtront ici';
      default:
        icon = Icons.cancel_outlined;
        message = 'Aucun achat ignoré';
        subtitle = 'Les achats que vous ignorez apparaîtront ici';
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 64, color: AppTheme.zinc600),
            const SizedBox(height: 16),
            Text(
              message,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppTheme.zinc400,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  const _ErrorState({required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 48, color: AppTheme.redAccent),
            const SizedBox(height: 12),
            Text(
              'Une erreur est survenue',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppTheme.redAccent,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
