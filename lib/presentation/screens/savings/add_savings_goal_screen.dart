import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:drift/drift.dart';
import 'package:budgethink/core/theme/app_theme.dart';
import 'package:budgethink/core/constants/app_constants.dart';
import 'package:budgethink/core/utils/notifications.dart';
import 'package:budgethink/presentation/providers/app_providers.dart';
import 'package:budgethink/data/database/app_database.dart';

class AddSavingsGoalScreen extends ConsumerStatefulWidget {
  const AddSavingsGoalScreen({super.key});

  @override
  ConsumerState<AddSavingsGoalScreen> createState() => _AddSavingsGoalScreenState();
}

class _AddSavingsGoalScreenState extends ConsumerState<AddSavingsGoalScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _targetController = TextEditingController();
  final _deadlineController = TextEditingController();
  final _notesController = TextEditingController();
  String _selectedIcon = 'savings';
  int _selectedColor = 0xFFF59E0B;
  DateTime? _selectedDeadline;
  bool _isSaving = false;

  static const List<String> _iconOptions = [
    'savings', 'home', 'directions_car', 'school', 'favorite',
    'flight', 'shopping_cart', 'card_giftcard', 'star', 'account_balance',
  ];

  static const List<int> _colorOptions = [
    0xFFF59E0B, // Amber
    0xFF22C55E, // Green
    0xFF3B82F6, // Blue
    0xFFEF4444, // Red
    0xFFA855F7, // Purple
    0xFFEC4899, // Pink
    0xFF14B8A6, // Teal
    0xFFF97316, // Orange
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _targetController.dispose();
    _deadlineController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickDeadline() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDeadline ?? now.add(const Duration(days: 30)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 365 * 10)),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: Theme.of(ctx).colorScheme.copyWith(
                primary: AppTheme.amberAccent,
                onPrimary: AppTheme.zinc950,
              ),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() {
        _selectedDeadline = picked;
        _deadlineController.text = AppConstants.formatDate(picked);
      });
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final name = _nameController.text.trim();
    final targetText = _targetController.text.replaceAll(',', '.');
    final targetAmount = double.tryParse(targetText);

    if (targetAmount == null || targetAmount <= 0) {
      showInfo(context, 'Montant cible invalide');
      return;
    }

    setState(() => _isSaving = true);

    try {
      final now = DateTime.now();
      await ref.read(savingsDaoProvider).insert(SavingsGoalsCompanion(
        name: Value(name),
        targetAmount: Value(targetAmount),
        currentAmount: const Value(0.0),
        deadline: Value(_selectedDeadline?.toIso8601String()),
        icon: Value(_selectedIcon),
        color: Value(_selectedColor),
        notes: Value(_notesController.text.trim().isEmpty ? null : _notesController.text.trim()),
        createdAt: Value(now.toIso8601String()),
        isCompleted: const Value(false),
      ));

      if (mounted) {
        showSuccess(context, 'Objectif créé !');
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        showError(context, 'Erreur: $e');
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nouvel objectif'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.pop(),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // ─── Name ──────────────────────────────────────────────────
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Nom de l\'objectif',
                hintText: 'Ex: Voyage au Japon',
              ),
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Requis' : null,
              textCapitalization: TextCapitalization.sentences,
            ),
            const SizedBox(height: 16),

            // ─── Target Amount ─────────────────────────────────────────
            TextFormField(
              controller: _targetController,
              decoration: const InputDecoration(
                labelText: 'Montant cible',
                prefixText: '€ ',
                hintText: '5000',
              ),
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              validator: (v) {
                if (v == null || v.isEmpty) return 'Requis';
                final amount = double.tryParse(v.replaceAll(',', '.'));
                if (amount == null || amount <= 0) return 'Montant invalide';
                return null;
              },
            ),
            const SizedBox(height: 16),

            // ─── Deadline ──────────────────────────────────────────────
            TextFormField(
              controller: _deadlineController,
              decoration: const InputDecoration(
                labelText: 'Date limite (optionnelle)',
                hintText: 'Sélectionner une date',
                suffixIcon: Icon(Icons.calendar_today),
              ),
              readOnly: true,
              onTap: _pickDeadline,
            ),
            const SizedBox(height: 24),

            // ─── Icon Picker ────────────────────────────────────────────
            Text(
              'Icône',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _iconOptions.map((iconName) {
                final isSelected = _selectedIcon == iconName;
                return GestureDetector(
                  onTap: () => setState(() => _selectedIcon = iconName),
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppTheme.amberAccent.withValues(alpha: 0.15)
                          : AppTheme.zinc800,
                      borderRadius: BorderRadius.circular(12),
                      border: isSelected
                          ? Border.all(color: AppTheme.amberAccent, width: 2)
                          : null,
                    ),
                    child: Icon(
                      AppConstants.categoryIcons[iconName] ?? Icons.savings,
                      color: isSelected ? AppTheme.amberAccent : AppTheme.zinc400,
                      size: 22,
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),

            // ─── Color Picker ──────────────────────────────────────────
            Text(
              'Couleur',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _colorOptions.map((color) {
                final isSelected = _selectedColor == color;
                return GestureDetector(
                  onTap: () => setState(() => _selectedColor = color),
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: Color(color),
                      borderRadius: BorderRadius.circular(10),
                      border: isSelected
                          ? Border.all(color: AppTheme.amberAccent, width: 2.5)
                          : null,
                      boxShadow: isSelected
                          ? [BoxShadow(
                              color: Color(color).withValues(alpha: 0.4),
                              blurRadius: 8,
                              spreadRadius: 1,
                            )]
                          : null,
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),

            // ─── Notes ─────────────────────────────────────────────────
            TextFormField(
              controller: _notesController,
              decoration: const InputDecoration(
                labelText: 'Notes (optionnelle)',
                hintText: 'Pour quoi économisez-vous ?',
              ),
              maxLines: 3,
              textCapitalization: TextCapitalization.sentences,
            ),
            const SizedBox(height: 32),

            // ─── Save Button ──────────────────────────────────────────
            SizedBox(
              width: double.infinity,
              height: 52,
              child: FilledButton(
                onPressed: _isSaving ? null : _save,
                child: _isSaving
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: AppTheme.zinc950,
                        ),
                      )
                    : const Text('Créer l\'objectif'),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
