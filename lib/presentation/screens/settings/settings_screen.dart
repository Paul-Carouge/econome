import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:budgethink/core/theme/app_theme.dart';
import 'package:budgethink/core/constants/app_constants.dart';
import 'package:budgethink/presentation/providers/app_providers.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Réglages'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ─── About Section ───────────────────────────────────────────
          _SectionHeader(title: 'À propos'),
          const SizedBox(height: 8),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: AppTheme.amberAccent.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(
                      Icons.savings,
                      color: AppTheme.amberAccent,
                      size: 36,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    AppConstants.appName,
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    AppConstants.appTagline,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppTheme.zinc400,
                          fontStyle: FontStyle.italic,
                        ),
                  ),
                  const SizedBox(height: 16),
                  _InfoRow(label: 'Version', value: '1.0.0'),
                  const SizedBox(height: 4),
                  _InfoRow(label: 'Développé avec', value: 'Flutter & Dart'),
                  const SizedBox(height: 4),
                  _InfoRow(label: 'Base de données', value: 'Drift (SQLite)'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // ─── Data Section ────────────────────────────────────────────
          _SectionHeader(title: 'Données'),
          const SizedBox(height: 8),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppTheme.redAccent.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.delete_forever_outlined, color: AppTheme.redAccent, size: 20),
                  ),
                  title: const Text('Réinitialiser toutes les données'),
                  subtitle: const Text('Supprime tous les budgets, transactions et objectifs'),
                  onTap: () => _confirmReset(context, ref),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // ─── About / Credits Section ─────────────────────────────────
          _SectionHeader(title: 'Crédits'),
          const SizedBox(height: 8),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Budgethink vous aide à suivre vos finances personnelles '
                    'et à prendre de meilleures décisions d\'achat.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Fait avec ❤️ pour une meilleure gestion financière.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.zinc500,
                        ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  void _confirmReset(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Réinitialiser toutes les données'),
        content: const Text(
          'Cette action supprimera toutes vos données '
          '(budgets, transactions et objectifs d\'épargne). '
          'Cette action est irréversible.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Annuler'),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.of(ctx).pop();
              await _resetData(ref);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Données réinitialisées')),
                );
              }
            },
            style: FilledButton.styleFrom(
              backgroundColor: AppTheme.redAccent,
              foregroundColor: AppTheme.zinc50,
            ),
            child: const Text('Réinitialiser'),
          ),
        ],
      ),
    );
  }

  Future<void> _resetData(WidgetRef ref) async {
    final db = ref.read(databaseProvider);
    await db.transaction(() async {
      await db.delete(db.savingsGoals).go();
      await db.delete(db.budgets).go();
      await db.delete(db.transactions).go();
    });
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: AppTheme.zinc400,
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppTheme.zinc500,
              ),
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.zinc300,
              ),
        ),
      ],
    );
  }
}
