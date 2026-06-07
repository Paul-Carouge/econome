import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';

import '../../core/theme/app_theme.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/icon_resolver.dart';
import '../../core/utils/notifications.dart';
import '../../core/services/widget_update_service.dart';
import '../providers/app_providers.dart';
import '../../data/database/app_database.dart';

// ─── Transactions Screen ───────────────────────────────────────────────

class TransactionsScreen extends ConsumerStatefulWidget {
  const TransactionsScreen({super.key});

  @override
  ConsumerState<TransactionsScreen> createState() =>
      _TransactionsScreenState();
}

class _TransactionsScreenState extends ConsumerState<TransactionsScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final month = ref.watch(currentMonthProvider);

    return Scaffold(
      backgroundColor: AppTheme.zinc950,
      appBar: AppBar(
        title: Text(DateFormat('MMMM yyyy', 'fr_FR').format(month)),
        actions: [
          // Export button
          IconButton(
            icon: const Icon(Icons.file_download_outlined),
            tooltip: 'Exporter en CSV',
            onPressed: _exportCsv,
          ),
          // Month navigation
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: () => _changeMonth(-1),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: () => _changeMonth(1),
          ),
        ],
      ),
      body: Column(
        children: [
          // Month total bar
          _MonthTotals(),

          // Search & filters
          _FilterBar(),

          // Transaction list
          Expanded(
            child: _TransactionGroupedList(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          HapticFeedback.lightImpact();
          context.push('/transactions/add');
        },
        backgroundColor: AppTheme.amberAccent,
        foregroundColor: AppTheme.zinc950,
        child: const Icon(Icons.add),
      ),
    );
  }

  void _changeMonth(int delta) {
    HapticFeedback.selectionClick();
    final current = ref.read(currentMonthProvider);
    ref.read(currentMonthProvider.notifier).state =
        DateTime(current.year, current.month + delta, 1);
  }

  Future<void> _exportCsv() async {
    HapticFeedback.lightImpact();
    try {
      final transactions =
          ref.read(monthlyTransactionsProvider).asData?.value ?? [];
      final categories =
          ref.read(allCategoriesProvider).asData?.value ?? [];

      if (transactions.isEmpty) {
        if (context.mounted) {
          showError(context, 'Aucune transaction à exporter');
        }
        return;
      }

      await ref.read(exportServiceProvider).exportToCsv(
            transactions,
            categories,
          );
    } catch (e) {
      if (context.mounted) {
        showError(context, 'Erreur lors de l\'export : $e');
      }
    }
  }
}

// ─── Filter Bar ────────────────────────────────────────────────────────

class _FilterBar extends ConsumerStatefulWidget {
  const _FilterBar();

  @override
  ConsumerState<_FilterBar> createState() => _FilterBarState();
}

class _FilterBarState extends ConsumerState<_FilterBar> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Sync with provider on init
    _searchController.text = ref.read(searchTextProvider);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final selectedCategoryId = ref.watch(categoryFilterProvider);
    final selectedType = ref.watch(typeFilterProvider);

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppTheme.zinc800, width: 1),
        ),
      ),
      child: Column(
        children: [
          // ── Search bar ──
          SizedBox(
            height: 44,
            child: TextField(
              controller: _searchController,
              style: const TextStyle(
                fontSize: 14,
                color: AppTheme.zinc200,
              ),
              decoration: InputDecoration(
                hintText: 'Rechercher une transaction…',
                hintStyle: const TextStyle(
                  fontSize: 14,
                  color: AppTheme.zinc500,
                ),
                prefixIcon: const Icon(
                  Icons.search,
                  size: 20,
                  color: AppTheme.zinc500,
                ),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(
                          Icons.clear,
                          size: 18,
                          color: AppTheme.zinc500,
                        ),
                        onPressed: () {
                          _searchController.clear();
                          ref.read(searchTextProvider.notifier).state = '';
                        },
                      )
                    : null,
                filled: true,
                fillColor: AppTheme.zinc900,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: AppTheme.zinc800),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: AppTheme.zinc800),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(
                    color: AppTheme.amberAccent,
                    width: 1.5,
                  ),
                ),
              ),
              onChanged: (value) {
                ref.read(searchTextProvider.notifier).state = value;
                setState(() {}); // rebuild to show/hide clear button
              },
            ),
          ),

          const SizedBox(height: 8),

          // ── Filters row ──
          Row(
            children: [
              // Category filter dropdown
              Expanded(
                child: _buildCategoryDropdown(selectedCategoryId),
              ),
              const SizedBox(width: 8),

              // Type filter chips
              _TypeChip(
                label: 'Tous',
                selected: selectedType == null,
                onTap: () =>
                    ref.read(typeFilterProvider.notifier).state = null,
              ),
              const SizedBox(width: 6),
              _TypeChip(
                label: 'Revenus',
                selected: selectedType == 'income',
                color: AppTheme.greenAccent,
                onTap: () =>
                    ref.read(typeFilterProvider.notifier).state = 'income',
              ),
              const SizedBox(width: 6),
              _TypeChip(
                label: 'Dépenses',
                selected: selectedType == 'expense',
                color: AppTheme.redAccent,
                onTap: () =>
                    ref.read(typeFilterProvider.notifier).state = 'expense',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryDropdown(int? selectedCategoryId) {
    final categoriesAsync = ref.watch(allCategoriesProvider);
    final categories = categoriesAsync.asData?.value ?? [];

    final idx = categories.indexWhere((c) => c.id == selectedCategoryId);
    final selectedCategory = idx >= 0 ? categories[idx] : null;

    return GestureDetector(
      onTap: () => _showCategoryPicker(categories, selectedCategoryId),
      child: Container(
        height: 38,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: AppTheme.zinc900,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: selectedCategoryId != null
                ? AppTheme.amberAccent
                : AppTheme.zinc800,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                selectedCategory?.name ?? 'Catégorie',
                style: TextStyle(
                  fontSize: 13,
                  color: selectedCategoryId != null
                      ? AppTheme.zinc200
                      : AppTheme.zinc500,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 4),
            const Icon(
              Icons.expand_more,
              size: 18,
              color: AppTheme.zinc500,
            ),
          ],
        ),
      ),
    );
  }

  void _showCategoryPicker(
    List<dynamic> categories,
    int? selectedCategoryId,
  ) {
    HapticFeedback.selectionClick();
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.zinc900,
      barrierColor: AppTheme.zinc950.withValues(alpha: 0.6),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Drag handle
              Container(
                margin: const EdgeInsets.only(top: 8),
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: AppTheme.zinc600,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // Title
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Row(
                  children: [
                    const Icon(
                      Icons.filter_list,
                      size: 18,
                      color: AppTheme.amberAccent,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Filtrer par catégorie',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.zinc100,
                      ),
                    ),
                    const Spacer(),
                    // Clear filter button
                    if (selectedCategoryId != null)
                      TextButton(
                        onPressed: () {
                          ref.read(categoryFilterProvider.notifier).state = null;
                          Navigator.of(ctx).pop();
                        },
                        style: TextButton.styleFrom(
                          foregroundColor: AppTheme.amberAccent,
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: const Text(
                          'Effacer',
                          style: TextStyle(fontSize: 13),
                        ),
                      ),
                  ],
                ),
              ),
              const Divider(color: AppTheme.zinc800, height: 1),
              // Categories list
              Flexible(
                child: ListView(
                  shrinkWrap: true,
                  padding: const EdgeInsets.only(bottom: 16),
                  children: [
                    // "All categories" option
                    _CategorySheetTile(
                      icon: Icons.clear_all,
                      color: AppTheme.zinc400,
                      name: 'Toutes les catégories',
                      isSelected: selectedCategoryId == null,
                      onTap: () {
                        ref.read(categoryFilterProvider.notifier).state = null;
                        Navigator.of(ctx).pop();
                      },
                    ),
                    ...categories.map((cat) => _CategorySheetTile(
                          icon: _mapCategoryIcon(cat.icon),
                          color: Color(cat.color),
                          name: cat.name,
                          isSelected: cat.id == selectedCategoryId,
                          onTap: () {
                            ref.read(categoryFilterProvider.notifier).state =
                                cat.id;
                            Navigator.of(ctx).pop();
                          },
                        )),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  IconData _mapCategoryIcon(String iconName) {
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
      default:
        return Icons.circle;
    }
  }
}

// ─── Type Chip ─────────────────────────────────────────────────────────

class _TypeChip extends StatelessWidget {
  final String label;
  final bool selected;
  final Color? color;
  final VoidCallback onTap;

  const _TypeChip({
    required this.label,
    required this.selected,
    this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final chipColor = color ?? AppTheme.amberAccent;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: selected
              ? chipColor.withValues(alpha: 0.15)
              : AppTheme.zinc900,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: selected ? chipColor : AppTheme.zinc800,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: selected ? chipColor : AppTheme.zinc400,
          ),
        ),
      ),
    );
  }
}

// ─── Category Sheet Tile ───────────────────────────────────────────────

class _CategorySheetTile extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String name;
  final bool isSelected;
  final VoidCallback onTap;

  const _CategorySheetTile({
    required this.icon,
    required this.color,
    required this.name,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.amberAccent.withValues(alpha: 0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                size: 16,
                color: color,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                name,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  color: isSelected ? AppTheme.zinc100 : AppTheme.zinc300,
                ),
              ),
            ),
            if (isSelected)
              const Icon(
                Icons.check,
                size: 18,
                color: AppTheme.amberAccent,
              ),
          ],
        ),
      ),
    );
  }
}

// ─── Month Totals Bar ──────────────────────────────────────────────────

class _MonthTotals extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final data = ref.watch(dashboardInfoProvider);

    return Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
        decoration: BoxDecoration(
          color: AppTheme.zinc900,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.zinc800),
        ),
        child: Row(
          children: [
            Expanded(
              child: _TotalChip(
                label: 'Revenus',
                amount: data.totalIncome,
                color: AppTheme.greenAccent,
              ),
            ),
            Container(
              width: 1,
              height: 32,
              color: AppTheme.zinc800,
            ),
            Expanded(
              child: _TotalChip(
                label: 'Dépenses',
                amount: data.totalExpenses,
                color: AppTheme.redAccent,
              ),
            ),
            Container(
              width: 1,
              height: 32,
              color: AppTheme.zinc800,
            ),
            Expanded(
              child: _TotalChip(
                label: 'Solde',
                amount: data.balance,
                color:
                    data.balance >= 0 ? AppTheme.greenAccent : AppTheme.redAccent,
              ),
            ),
          ],
        ),
    );
  }
}

class _TotalChip extends StatelessWidget {
  final String label;
  final double amount;
  final Color color;

  const _TotalChip({
    required this.label,
    required this.amount,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: AppTheme.zinc500,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          AppConstants.formatAmountPlain(amount),
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
      ],
    );
  }
}

// ─── Grouped Transactions List ─────────────────────────────────────────

class _TransactionGroupedList extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactions = ref.watch(filteredTransactionsProvider);
    final categoriesAsync = ref.watch(allCategoriesProvider);
    final isStreamLoading = ref.watch(monthlyTransactionsProvider).isLoading;

    // Détermine s'il s'agit d'un chargement post-initial (changement de mois)
    // vs chargement initial (première ouverture). On vérifie si le cache existe.
    final hasCache = ref.watch(monthlyTransactionsProvider).asData?.value != null;

    if (transactions.isEmpty && !isStreamLoading) {
      // Check if filters are active
      final searchText = ref.watch(searchTextProvider);
      final categoryId = ref.watch(categoryFilterProvider);
      final type = ref.watch(typeFilterProvider);
      final hasFilters = searchText.isNotEmpty ||
          categoryId != null ||
          type != null;

      // Check if there are any transactions at all
      final allTransactions =
          ref.watch(monthlyTransactionsProvider).asData?.value ?? [];

      if (allTransactions.isEmpty) {
        return const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.receipt_long_outlined,
                color: AppTheme.zinc600,
                size: 48,
              ),
              SizedBox(height: 12),
              Text(
                'Aucune transaction ce mois',
                style: TextStyle(
                  fontSize: 16,
                  color: AppTheme.zinc500,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'Appuyez sur + pour en ajouter une',
                style: TextStyle(
                  fontSize: 13,
                  color: AppTheme.zinc600,
                ),
              ),
            ],
          ),
        );
      }

      if (hasFilters) {
        return const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.search_off,
                color: AppTheme.zinc600,
                size: 48,
              ),
              SizedBox(height: 12),
              Text(
                'Aucun résultat',
                style: TextStyle(
                  fontSize: 16,
                  color: AppTheme.zinc500,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'Essayez de modifier vos filtres',
                style: TextStyle(
                  fontSize: 13,
                  color: AppTheme.zinc600,
                ),
              ),
            ],
          ),
        );
      }
    }

    // Si les transactions sont vides et qu'on est en chargement initial (pas de cache),
    // on montre un indicateur de chargement
    if (transactions.isEmpty && isStreamLoading && !hasCache) {
      return const Center(
        child: CircularProgressIndicator(
          color: AppTheme.amberAccent,
          strokeWidth: 2,
        ),
      );
    }

    final catMap = <int, Category>{};
    final catList = categoriesAsync.value ?? [];
    for (final c in catList) {
      catMap[c.id] = c;
    }

    // Group by date
    final grouped = <String, List<Transaction>>{};
    for (final t in transactions) {
      grouped.putIfAbsent(t.date, () => []).add(t);
    }

    // Sort dates descending
    final dates = grouped.keys.toList()
      ..sort((a, b) => b.compareTo(a));

    return Column(
      children: [
        // Subtle loading indicator during month change
        if (isStreamLoading && hasCache)
          SizedBox(
            width: double.infinity,
            height: 2,
            child: LinearProgressIndicator(
              backgroundColor: AppTheme.zinc800,
              valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.amberAccent),
            ),
          ),

        // Content with smooth cross-fade on data change
        Expanded(
          child: AnimatedSwitcher(
            duration: 200.ms,
            switchInCurve: Curves.easeOut,
            switchOutCurve: Curves.easeIn,
            transitionBuilder: (child, animation) {
              return FadeTransition(
                opacity: animation,
                child: child,
              );
            },
            child: _buildList(context, ref, grouped, dates, catMap),
          ),
        ),
      ],
    );
  }

  Widget _buildList(
    BuildContext context,
    WidgetRef ref,
    Map<String, List<Transaction>> grouped,
    List<String> dates,
    Map<int, Category> catMap,
  ) {
    return RefreshIndicator(
      key: ValueKey(dates.isNotEmpty ? dates.first : 'empty'),
      color: AppTheme.amberAccent,
      backgroundColor: AppTheme.zinc900,
      onRefresh: () async {
        HapticFeedback.lightImpact();
        ref.invalidate(monthlyTransactionsProvider);
        ref.invalidate(dashboardInfoProvider);
        await Future.delayed(600.ms);
      },
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
        itemCount: dates.length,
        itemBuilder: (context, index) {
          final dateStr = dates[index];
          final items = grouped[dateStr]!;
          final date = DateTime.tryParse(dateStr) ?? DateTime.now();

          return _DateGroup(
            date: date,
            transactions: items,
            categoryMap: catMap,
          );
        },
      ),
    );
  }
}

// ─── Date Group ────────────────────────────────────────────────────────

class _DateGroup extends StatelessWidget {
  final DateTime date;
  final List<Transaction> transactions;
  final Map<int, Category> categoryMap;

  const _DateGroup({
    required this.date,
    required this.transactions,
    required this.categoryMap,
  });

  @override
  Widget build(BuildContext context) {
    final dayTotal = transactions.fold<double>(
      0,
      (sum, t) => sum + (t.type == 'expense' ? -t.amount : t.amount),
    );

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Date header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  DateFormat('EEEE d MMMM', 'fr_FR').format(date),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.zinc300,
                  ),
                ),
                Text(
                  dayTotal >= 0
                      ? AppConstants.formatAmount(dayTotal)
                      : '-${AppConstants.formatAmountPlain(dayTotal.abs())}',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: dayTotal >= 0
                        ? AppTheme.greenAccent
                        : AppTheme.redAccent,
                  ),
                ),
              ],
            ),
          ),

          // Transactions for this date
          ...transactions.map((t) {
            final cat = categoryMap[t.categoryId];
            return _TransactionCard(
              transaction: t,
              category: cat,
            );
          }),
        ],
      ),
    );
  }
}

// ─── Transaction Card ──────────────────────────────────────────────────

class _TransactionCard extends ConsumerWidget {
  final Transaction transaction;
  final Category? category;

  const _TransactionCard({
    required this.transaction,
    this.category,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isExpense = transaction.type == 'expense';
    final catColor = category != null
        ? Color(category!.color)
        : AppTheme.zinc500;

    return Dismissible(
      key: ValueKey(transaction.id),
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
              'Supprimer cette transaction de ${AppConstants.formatAmountPlain(transaction.amount)} ?',
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
        final repo = ref.read(transactionRepositoryProvider);
        final result = await repo.deleteEntry(transaction.id);
        ref.invalidate(monthlyTransactionsProvider);
        ref.invalidate(dashboardInfoProvider);
        ref.invalidate(recentTransactionsProvider);
        if (context.mounted) {
          result.when(
            onSuccess: (_) async {
              // Mettre à jour tous les widgets d'accueil
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

                    bool overBudget = false;
                    budgetResult.when(
                      onSuccess: (budget) {
                        if (budget != null && budget.totalBudget > 0) {
                          budgetLabel = 'Budget : ${WidgetUpdateService.formatAmount(budget.totalBudget)}';
                          budgetSpentStr = '${s.expenses.toStringAsFixed(0)} €';
                          budgetTotalStr = '${budget.totalBudget.toStringAsFixed(0)} €';
                          budgetPct = WidgetUpdateService.formatPercent(s.expenses / budget.totalBudget);
                          overBudget = s.expenses > budget.totalBudget;
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
                      overBudget: overBudget,
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

              showSuccess(
                context,
                'Transaction supprimée',
                actionLabel: 'Annuler',
                onAction: () {
                  // Re-add would require storing the full data
                },
              );
            },
            onFailure: (error) {
              showError(context, 'Erreur: ${error.message}');
            },
          );
        }
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 3),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: AppTheme.zinc900,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.zinc800.withValues(alpha: 0.5)),
        ),
        child: Row(
          children: [
            // Category icon
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: catColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                category != null
                    ? resolveCategoryIcon(category!.icon)
                    : Icons.receipt,
                size: 18,
                color: catColor,
              ),
            ),
            const SizedBox(width: 12),

            // Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    transaction.description ?? category?.name ?? 'Transaction',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.zinc200,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (category != null)
                    Text(
                      category!.name,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppTheme.zinc500,
                      ),
                    ),
                ],
              ),
            ),

            // Note indicator
            if (transaction.note != null && transaction.note!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Icon(
                  Icons.notes_rounded,
                  size: 14,
                  color: AppTheme.zinc600,
                ),
              ),

            // Amount
            Text(
              isExpense
                  ? '-${AppConstants.formatAmountPlain(transaction.amount)}'
                  : AppConstants.formatAmount(transaction.amount),
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isExpense ? AppTheme.redAccent : AppTheme.greenAccent,
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(
      duration: 300.ms,
    ).slideX(begin: 0.03, end: 0, duration: 300.ms);
  }
}
