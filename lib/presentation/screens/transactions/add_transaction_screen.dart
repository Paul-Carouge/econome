import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:drift/drift.dart' hide Column;
import 'package:econome/core/theme/app_theme.dart';
import 'package:econome/data/database/app_database.dart';
import 'package:econome/presentation/providers/app_providers.dart';
import 'package:econome/core/utils/notifications.dart';
import 'package:econome/core/services/widget_update_service.dart';
import 'package:econome/core/utils/icon_resolver.dart';

// ─── Add Transaction Screen ────────────────────────────────────────────

class AddTransactionScreen extends ConsumerStatefulWidget {
  const AddTransactionScreen({super.key});

  @override
  ConsumerState<AddTransactionScreen> createState() =>
      _AddTransactionScreenState();
}

class _AddTransactionScreenState extends ConsumerState<AddTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _notesController = TextEditingController();

  String _type = 'expense';
  int? _selectedCategoryId;
  DateTime _selectedDate = DateTime.now();
  bool _isSubmitting = false;
  bool _initialized = false;

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(allCategoriesProvider);

    // Apply prefill data once
    if (!_initialized) {
      _initialized = true;
      final extra = GoRouterState.of(context).extra;
      if (extra is Map<String, dynamic>) {
        final prefillAmount = extra['prefill_amount'] as double?;
        final prefillDescription = extra['prefill_description'] as String?;
        final prefillCategoryId = extra['prefill_category_id'] as int?;
        final prefillNotes = extra['prefill_notes'] as String?;

        if (prefillAmount != null) {
          _amountController.text = prefillAmount.toString();
        }
        if (prefillDescription != null) {
          _descriptionController.text = prefillDescription;
        }
        if (prefillCategoryId != null) {
          _selectedCategoryId = prefillCategoryId;
        }
        if (prefillNotes != null) {
          _notesController.text = prefillNotes;
        }
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ajouter une transaction'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Type toggle
              Text(
                'Type',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: AppTheme.zinc400,
                    ),
              ),
              const SizedBox(height: 8),
              SegmentedButton<String>(
                segments: const [
                  ButtonSegment(
                    value: 'expense',
                    label: Text('Dépense'),
                    icon: Icon(Icons.trending_down),
                  ),
                  ButtonSegment(
                    value: 'income',
                    label: Text('Revenu'),
                    icon: Icon(Icons.trending_up),
                  ),
                ],
                selected: {_type},
                onSelectionChanged: (value) {
                  setState(() => _type = value.first);
                },
                style: ButtonStyle(
                  backgroundColor: WidgetStateProperty.resolveWith((states) {
                    if (states.contains(WidgetState.selected)) {
                      return AppTheme.amberAccent.withValues(alpha: 0.15);
                    }
                    return AppTheme.zinc800;
                  }),
                  foregroundColor: WidgetStateProperty.resolveWith((states) {
                    if (states.contains(WidgetState.selected)) {
                      return AppTheme.amberAccent;
                    }
                    return AppTheme.zinc400;
                  }),
                  shape: WidgetStateProperty.all(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Amount
              TextFormField(
                controller: _amountController,
                decoration: InputDecoration(
                  labelText: 'Montant (€)',
                  hintText: 'ex: 49.99',
                  prefixIcon: Icon(
                    _type == 'expense'
                        ? Icons.remove_circle_outline
                        : Icons.add_circle_outline,
                    color: _type == 'expense'
                        ? AppTheme.redAccent
                        : AppTheme.greenAccent,
                  ),
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

              // Description
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  hintText: 'ex: Courses au supermarché',
                  prefixIcon: Icon(Icons.description),
                ),
                textCapitalization: TextCapitalization.sentences,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Veuillez entrer une description';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Date picker
              InkWell(
                onTap: _pickDate,
                borderRadius: BorderRadius.circular(12),
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Date',
                    prefixIcon: Icon(Icons.calendar_today),
                  ),
                  child: Text(
                    '${_selectedDate.day.toString().padLeft(2, '0')}/'
                    '${_selectedDate.month.toString().padLeft(2, '0')}/'
                    '${_selectedDate.year}',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Category
              categoriesAsync.when(
                data: (cats) => _buildCategoryPicker(cats),
                loading: () => const SizedBox(
                  height: 100,
                  child:
                      Center(child: CircularProgressIndicator(strokeWidth: 2)),
                ),
                error: (_, _) => const SizedBox.shrink(),
              ),
              const SizedBox(height: 16),

              // Notes
              TextFormField(
                controller: _notesController,
                decoration: const InputDecoration(
                  labelText: 'Notes (optionnel)',
                  hintText: 'Informations supplémentaires',
                  prefixIcon: Icon(Icons.notes),
                ),
                maxLines: 3,
                textCapitalization: TextCapitalization.sentences,
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
                    : const Text('Ajouter la transaction'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryPicker(List<Category> categories) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Catégorie *',
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
                    color:
                        isSelected ? AppTheme.zinc950 : Color(cat.color),
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
        if (_selectedCategoryId == null)
          Padding(
            padding: const EdgeInsets.only(top: 4, left: 12),
            child: Text(
              'Veuillez sélectionner une catégorie',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.zinc500,
                  ),
            ),
          ),
      ],
    );
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
                  primary: AppTheme.amberAccent,
                  onPrimary: AppTheme.zinc950,
                  surface: AppTheme.zinc900,
                  onSurface: AppTheme.zinc100,
                ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedCategoryId == null) {
      showInfo(context, 'Veuillez sélectionner une catégorie');
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final dateStr =
          '${_selectedDate.year.toString().padLeft(4, '0')}-'
          '${_selectedDate.month.toString().padLeft(2, '0')}-'
          '${_selectedDate.day.toString().padLeft(2, '0')}';

      final result = await ref.read(transactionRepositoryProvider).insert(
            TransactionsCompanion(
              amount: Value(double.parse(
                  _amountController.text.replaceAll(',', '.'))),
              description: Value(_descriptionController.text.trim()),
              date: Value(dateStr),
              categoryId: Value(_selectedCategoryId!),
              type: Value(_type),
              note: _notesController.text.trim().isNotEmpty
                  ? Value(_notesController.text.trim())
                  : const Value(null),
              createdAt: Value(DateTime.now().toIso8601String()),
            ),
          );

      if (context.mounted) {
        result.when(
          onSuccess: (_) {
            showSuccess(context, 'Transaction ajoutée');

            // Mettre à jour le widget d'accueil
            _updateHomeWidget();

            // Pop all the way back
            final routeState = GoRouterState.of(context);
            if (routeState.uri.toString().startsWith('/impulse')) {
              context.go('/impulse');
            } else {
              context.pop();
            }
          },
          onFailure: (error) {
            showError(context, 'Erreur : ${error.message}');
          },
        );
      }
    } catch (e) {
      if (context.mounted) {
        showError(context, 'Erreur : $e');
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Future<void> _updateHomeWidget() async {
    try {
      final now = DateTime.now();
      final txRepo = ref.read(transactionRepositoryProvider);
      final budgetRepo = ref.read(budgetRepositoryProvider);
      final savingsRepo = ref.read(savingsRepositoryProvider);

      final summary = await txRepo.getMonthlySummary(now.month, now.year);
      final budgetResult = await budgetRepo.getByMonth(now.month, now.year);
      final recent = await txRepo.getRecent(3);
      final savingsResult = await savingsRepo.getAll();

      String savingsName = '';
      String savingsCurrent = '';
      String savingsTarget = '';
      String savingsPct = '0';

      savingsResult.when(
        onSuccess: (goals) {
          if (goals.isNotEmpty) {
            final topGoal = goals.first;
            savingsName = topGoal.name;
            savingsCurrent = WidgetUpdateService.formatAmount(topGoal.currentAmount);
            savingsTarget = WidgetUpdateService.formatAmount(topGoal.targetAmount);
            savingsPct = WidgetUpdateService.formatPercent(
              topGoal.targetAmount > 0
                  ? topGoal.currentAmount / topGoal.targetAmount
                  : 0.0,
            );
          }
        },
        onFailure: (_) {},
      );

      summary.when(
        onSuccess: (s) async {
          String budgetLabel = '';
          String budgetSpentStr = '';
          String budgetTotalStr = '—';
          String budgetPct = '0';

          budgetResult.when(
            onSuccess: (budget) {
              if (budget != null && budget.totalBudget > 0) {
                budgetLabel = 'Budget : ${WidgetUpdateService.formatAmount(budget.totalBudget)}';
                budgetSpentStr = '${s.expenses.toStringAsFixed(0)} €';
                budgetTotalStr = '${budget.totalBudget.toStringAsFixed(0)} €';
                budgetPct = WidgetUpdateService.formatPercent(s.expenses / budget.totalBudget);
              }
            },
            onFailure: (_) {},
          );

          final txs = recent.when<List<String>>(
            onSuccess: (list) => list
                .map((t) => WidgetUpdateService.formatTransaction(
                      t.description ?? '',
                      t.amount,
                      t.type,
                    ))
                .toList(),
            onFailure: (_) => [],
          );

          await WidgetUpdateService.updateAll(
            balance: WidgetUpdateService.formatAmount(s.balance),
            balanceColor: WidgetUpdateService.colorForBalance(s.balance),
            budgetLabel: budgetLabel,
            budgetSpent: budgetSpentStr,
            budgetTotal: budgetTotalStr,
            budgetPct: budgetPct,
            recentTransactions: txs,
            savingsName: savingsName,
            savingsCurrent: savingsCurrent,
            savingsTarget: savingsTarget,
            savingsPct: savingsPct,
          );
        },
        onFailure: (_) {},
      );
    } catch (_) {}
  }
}
