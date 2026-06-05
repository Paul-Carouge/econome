import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:go_router/go_router.dart';
import 'package:econome/core/theme/app_theme.dart';
import 'package:econome/presentation/screens/onboarding_screen.dart';
import 'package:econome/presentation/screens/dashboard_screen.dart';
import 'package:econome/presentation/screens/transactions_screen.dart';
import 'package:econome/presentation/screens/budgets/budgets_screen.dart';
import 'package:econome/presentation/screens/savings/savings_screen.dart';
import 'package:econome/presentation/screens/settings/settings_screen.dart';
import 'package:econome/presentation/screens/transactions/add_transaction_screen.dart';
import 'package:econome/presentation/screens/savings/add_savings_goal_screen.dart';
import 'package:econome/presentation/screens/impulse/impulse_list_screen.dart';
import 'package:econome/presentation/screens/impulse/add_impulse_screen.dart';
import 'package:econome/data/database/app_database.dart';

part 'provider_app.g.dart';

// ─── Onboarding State ──────────────────────────────────────────────
/// Provider surchargé dans main() avec la valeur réelle depuis SharedPreferences.
@Riverpod(keepAlive: true)
bool onboardingComplete(Ref ref) {
  throw UnimplementedError('Override in main()');
}

// ─── Router ────────────────────────────────────────────────────────
@Riverpod(keepAlive: true)
GoRouter router(Ref ref) {
  final onboardingComplete = ref.watch(onboardingCompleteProvider);
  return _buildRouter(onboardingComplete);
}

GoRouter _buildRouter(bool onboardingComplete) {
  return GoRouter(
    initialLocation: onboardingComplete ? '/home/dashboard' : '/onboarding',
    routes: [
      GoRoute(
        path: '/onboarding',
        name: 'onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      ShellRoute(
        builder: (context, state, child) => _ShellScaffold(child: child),
        routes: [
          GoRoute(
            path: '/home/dashboard',
            name: 'dashboard',
            builder: (context, state) => const DashboardScreen(),
          ),
          GoRoute(
            path: '/home/transactions',
            name: 'transactions',
            builder: (context, state) => const TransactionsScreen(),
          ),
          GoRoute(
            path: '/home/budgets',
            name: 'budgets',
            builder: (context, state) => const BudgetsScreen(),
          ),
          GoRoute(
            path: '/home/savings',
            name: 'savings',
            builder: (context, state) => const SavingsScreen(),
          ),
          GoRoute(
            path: '/home/settings',
            name: 'settings',
            builder: (context, state) => const SettingsScreen(),
          ),
        ],
      ),
      GoRoute(
        path: '/transactions/add',
        name: 'add-transaction',
        builder: (context, state) => const AddTransactionScreen(),
      ),
      GoRoute(
        path: '/savings/add',
        name: 'add-savings',
        builder: (context, state) => const AddSavingsGoalScreen(),
      ),
      GoRoute(
        path: '/savings/edit',
        name: 'edit-savings',
        builder: (context, state) {
          final goal = state.extra as SavingsGoal?;
          return AddSavingsGoalScreen(existingGoal: goal);
        },
      ),
      GoRoute(
        path: '/impulse',
        name: 'impulse',
        builder: (context, state) => const ImpulseListScreen(),
      ),
      GoRoute(
        path: '/impulse/add',
        name: 'add-impulse',
        builder: (context, state) => const AddImpulseScreen(),
      ),
    ],
  );
}

// ─── Shell Scaffold ───────────────────────────────────────────────────
class _ShellScaffold extends StatelessWidget {
  final Widget child;

  const _ShellScaffold({required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: AppTheme.zinc800, width: 1)),
        ),
        child: BottomNavigationBar(
          currentIndex: _calculateSelectedIndex(context),
          onTap: (index) => _onItemTapped(index, context),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.dashboard_outlined),
              activeIcon: Icon(Icons.dashboard),
              label: 'Tableau',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.receipt_long_outlined),
              activeIcon: Icon(Icons.receipt_long),
              label: 'Transactions',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.account_balance_wallet_outlined),
              activeIcon: Icon(Icons.account_balance_wallet),
              label: 'Budgets',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.savings_outlined),
              activeIcon: Icon(Icons.savings),
              label: 'Épargne',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings_outlined),
              activeIcon: Icon(Icons.settings),
              label: 'Réglages',
            ),
          ],
        ),
      ),
    );
  }

  int _calculateSelectedIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    if (location.startsWith('/home/dashboard')) return 0;
    if (location.startsWith('/home/transactions')) return 1;
    if (location.startsWith('/home/budgets')) return 2;
    if (location.startsWith('/home/savings')) return 3;
    if (location.startsWith('/home/settings')) return 4;
    return 0;
  }

  void _onItemTapped(int index, BuildContext context) {
    switch (index) {
      case 0: context.go('/home/dashboard');
      case 1: context.go('/home/transactions');
      case 2: context.go('/home/budgets');
      case 3: context.go('/home/savings');
      case 4: context.go('/home/settings');
    }
  }
}
