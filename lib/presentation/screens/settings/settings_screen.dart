import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:econome/core/theme/app_theme.dart';
import 'package:econome/core/constants/app_constants.dart';
import 'package:econome/core/utils/notifications.dart';
import 'package:econome/presentation/providers/app_providers.dart';

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
          // ─── App Info Card ──────────────────────────────────────────
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: AppTheme.amberAccent.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: const Icon(
                      Icons.savings,
                      color: AppTheme.amberAccent,
                      size: 40,
                    ),
                  ),
                  const SizedBox(height: 14),
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
                  const SizedBox(height: 18),
                  _InfoRow(label: 'Version', value: 'v${AppConstants.appVersion}'),
                  const SizedBox(height: 4),
                  _InfoRow(label: 'Développeur', value: AppConstants.appAuthor),
                  const SizedBox(height: 4),
                  _InfoRow(label: 'Stack', value: 'Flutter, Riverpod, Drift'),
                  const SizedBox(height: 4),
                  _InfoRow(label: 'Stockage', value: '100% local (SQLite)'),
                  const SizedBox(height: 4),
                  _InfoRow(label: 'Licence', value: 'MIT — Open Source'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // ─── Features Section ─────────────────────────────────────────
          _SectionHeader(title: 'Fonctionnalités'),
          const SizedBox(height: 8),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _FeatureRow(Icons.dashboard, 'Tableau de bord mensuel'),
                  const SizedBox(height: 10),
                  _FeatureRow(Icons.receipt_long, 'Transactions — revenus et dépenses'),
                  const SizedBox(height: 10),
                  _FeatureRow(Icons.account_balance_wallet, 'Budget mensuel avec suivi visuel'),
                  const SizedBox(height: 10),
                  _FeatureRow(Icons.savings, 'Objectifs d\'épargne'),
                  const SizedBox(height: 10),
                  _FeatureRow(Icons.auto_awesome, 'Anti-achat impulsif avec cooling period'),
                  const SizedBox(height: 10),
                  _FeatureRow(Icons.search, 'Recherche et filtres'),
                  const SizedBox(height: 10),
                  _FeatureRow(Icons.file_download, 'Export CSV des transactions'),
                  const SizedBox(height: 10),
                  _FeatureRow(Icons.notifications_active, 'Notifications de fin de cooling'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // ─── Links Section ───────────────────────────────────────────
          _SectionHeader(title: 'Liens'),
          const SizedBox(height: 8),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppTheme.zinc800,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.code, color: AppTheme.zinc100, size: 20),
                  ),
                  title: const Text('GitHub — Code source'),
                  subtitle: const Text('github.com/Paul-Carouge'),
                  onTap: () => launchUrl(Uri.parse('https://github.com/Paul-Carouge')),
                ),
                const Divider(height: 1, indent: 56, color: AppTheme.zinc800),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppTheme.zinc800,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.download, color: AppTheme.zinc100, size: 20),
                  ),
                  title: const Text('Télécharger l\'APK'),
                  subtitle: const Text('Dernière release sur GitHub'),
                  onTap: () => launchUrl(Uri.parse('https://github.com/Paul-Carouge/econome/releases')),
                ),
                const Divider(height: 1, indent: 56, color: AppTheme.zinc800),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppTheme.zinc800,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.business, color: AppTheme.zinc100, size: 20),
                  ),
                  title: const Text('LinkedIn — Paul Carouge'),
                  subtitle: const Text('linkedin.com/in/pcarouge'),
                  onTap: () => launchUrl(Uri.parse('https://linkedin.com/in/pcarouge')),
                ),
              ],
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

          // ─── Credits Section ─────────────────────────────────────────
          _SectionHeader(title: 'Crédits'),
          const SizedBox(height: 8),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${AppConstants.appName} v${AppConstants.appVersion}',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: AppTheme.zinc200,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Conçue et développée par ${AppConstants.appAuthor}.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    AppConstants.appDescription,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.zinc400,
                        ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '© ${DateTime.now().year} Paul Carouge — MIT License',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.zinc500,
                          fontStyle: FontStyle.italic,
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
                showSuccess(context, 'Données réinitialisées');
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
    await clearAllData(db);
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

class _FeatureRow extends StatelessWidget {
  final IconData icon;
  final String label;

  const _FeatureRow(this.icon, this.label);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: AppTheme.amberAccent, size: 18),
        const SizedBox(width: 10),
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.zinc300,
              ),
        ),
      ],
    );
  }
}
