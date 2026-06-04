import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:drift/drift.dart' hide Column;
import 'package:econome/core/theme/app_theme.dart';
import 'package:econome/data/database/app_database.dart';
import 'package:econome/presentation/providers/app_providers.dart';
import 'package:econome/core/utils/notifications.dart';

// ─── Cooldown Duration Helper ───────────────────────────────────────────

Duration calculateCooldownDuration(double amount) {
  if (amount < 10) {
    return const Duration(hours: 48);
  } else if (amount < 50) {
    return const Duration(hours: 72);
  } else if (amount < 200) {
    return const Duration(hours: 120);
  } else {
    return const Duration(hours: 168);
  }
}

int calculateCooldownDays(double amount) {
  if (amount < 10) return 2;
  if (amount < 50) return 3;
  if (amount < 200) return 5;
  return 7;
}

// ─── Icon Name Resolution ──────────────────────────────────────────────

IconData resolveCategoryIcon(String iconName) {
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
    case 'savings':
      return Icons.savings;
    default:
      return Icons.category;
  }
}

// ─── Add Impulse Screen ────────────────────────────────────────────────

class AddImpulseScreen extends ConsumerStatefulWidget {
  const AddImpulseScreen({super.key});

  @override
  ConsumerState<AddImpulseScreen> createState() => _AddImpulseScreenState();
}

class _AddImpulseScreenState extends ConsumerState<AddImpulseScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _amountController = TextEditingController();
  final _linkController = TextEditingController();
  final _notesController = TextEditingController();
  int? _selectedCategoryId;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _amountController.addListener(_onAmountChanged);
  }

  void _onAmountChanged() {
    setState(() {}); // rebuild to show updated cooldown info text
  }

  @override
  void dispose() {
    _amountController.removeListener(_onAmountChanged);
    _nameController.dispose();
    _amountController.dispose();
    _linkController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(expenseCategoriesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ajouter un achat impulsif'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Name
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nom de l\'achat',
                  hintText: 'ex: Nouveau smartphone',
                  prefixIcon: Icon(Icons.shopping_bag),
                ),
                textCapitalization: TextCapitalization.sentences,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Veuillez entrer un nom';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Amount
              TextFormField(
                controller: _amountController,
                decoration: const InputDecoration(
                  labelText: 'Montant (€)',
                  hintText: 'ex: 49.99',
                  prefixIcon: Icon(Icons.euro),
                ),
                keyboardType: const TextInputType.numberWithOptions(
                    decimal: true, signed: false),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Veuillez entrer un montant';
                  }
                  final amount = double.tryParse(value.replaceAll(',', '.'));
                  if (amount == null || amount <= 0) {
                    return 'Montant invalide';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Category
              categoriesAsync.when(
                data: (cats) => _buildCategoryPicker(cats),
                loading: () => const SizedBox(
                  height: 80,
                  child:
                      Center(child: CircularProgressIndicator(strokeWidth: 2)),
                ),
                error: (_, _) => const SizedBox.shrink(),
              ),
              const SizedBox(height: 16),

              // Link
              TextFormField(
                controller: _linkController,
                decoration: const InputDecoration(
                  labelText: 'Lien (optionnel)',
                  hintText: 'ex: https://...',
                  prefixIcon: Icon(Icons.link),
                ),
                keyboardType: TextInputType.url,
              ),
              const SizedBox(height: 16),

              // Notes
              TextFormField(
                controller: _notesController,
                decoration: const InputDecoration(
                  labelText: 'Notes (optionnel)',
                  hintText: 'Pourquoi cet achat ?',
                  prefixIcon: Icon(Icons.notes),
                ),
                maxLines: 3,
                textCapitalization: TextCapitalization.sentences,
              ),
              const SizedBox(height: 24),

              // Info card
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.amberAccent.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppTheme.amberAccent.withValues(alpha: 0.2),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline,
                        size: 20, color: AppTheme.amberAccent),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildCoolingInfoText(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Submit
              FilledButton(
                onPressed: _isSubmitting ? null : _handleSubmit,
                child: _isSubmitting
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppTheme.zinc950,
                        ),
                      )
                    : const Text('Ajouter à la liste d\'attente'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryPicker(List<Category> categories) {
    if (categories.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Catégorie (optionnelle)',
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: AppTheme.zinc400,
              ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: categories.map((cat) {
            final isSelected = _selectedCategoryId == cat.id;
            return ChoiceChip(
              selected: isSelected,
              label: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    resolveCategoryIcon(cat.icon),
                    size: 16,
                    color: isSelected
                        ? AppTheme.zinc950
                        : Color(cat.color),
                  ),
                  const SizedBox(width: 6),
                  Text(cat.name),
                ],
              ),
              selectedColor: AppTheme.amberAccent,
              backgroundColor: AppTheme.zinc800,
              labelStyle: TextStyle(
                color: isSelected ? AppTheme.zinc950 : AppTheme.zinc300,
                fontSize: 13,
              ),
              onSelected: (selected) {
                setState(() {
                  _selectedCategoryId = selected ? cat.id : null;
                });
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildCoolingInfoText() {
    final amountText = _amountController.text.trim().replaceAll(',', '.');
    final amount = double.tryParse(amountText);
    final days = (amount != null && amount > 0)
        ? calculateCooldownDays(amount)
        : null;

    return Text(
      days != null
          ? 'La période de refroidissement est de $days jours pour ce montant.'
          : 'La période de refroidissement dépend du montant saisi.',
      style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: AppTheme.amberAccent,
          ),
    );
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      final now = DateTime.now();
      final amount = double.parse(
          _amountController.text.replaceAll(',', '.'));
      final coolingUntil = now.add(calculateCooldownDuration(amount));

      await ref.read(impulseDaoProvider).insert(
            ImpulseItemsCompanion(
              name: Value(_nameController.text.trim()),
              amount: Value(double.parse(
                  _amountController.text.replaceAll(',', '.'))),
              categoryId: _selectedCategoryId != null
                  ? Value(_selectedCategoryId!)
                  : const Value(null),
              link: _linkController.text.trim().isNotEmpty
                  ? Value(_linkController.text.trim())
                  : const Value(null),
              notes: _notesController.text.trim().isNotEmpty
                  ? Value(_notesController.text.trim())
                  : const Value(null),
              createdAt: Value(now.toIso8601String()),
              coolingUntil: Value(coolingUntil.toIso8601String()),
              status: const Value('cooling'),
            ),
          );

      if (context.mounted) {
        showSuccess(context, 'Achat ajouté à la liste d\'attente');
        context.pop();
      }
    } catch (e) {
      if (context.mounted) {
        showError(context, 'Erreur : $e');
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }
}
