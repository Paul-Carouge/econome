import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../core/theme/app_theme.dart';
import '../../data/database/seed_data.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, dynamic>> _slides = CategorySeed.onboardingSlides;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _completeOnboarding() async {
    HapticFeedback.lightImpact();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_complete', true);
    if (mounted) {
      context.go('/home/dashboard');
    }
  }

  void _nextPage() {
    if (_currentPage < _slides.length - 1) {
      _pageController.nextPage(
        duration: 400.ms,
        curve: Curves.easeInOut,
      );
    } else {
      _completeOnboarding();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.zinc950,
      body: SafeArea(
        child: Column(
          children: [
            // Skip button
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.only(top: 16, right: 20),
                child: TextButton(
                  onPressed: _completeOnboarding,
                  child: Text(
                    'Passer',
                    style: TextStyle(
                      color: AppTheme.zinc400,
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),

            // Pages
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  HapticFeedback.selectionClick();
                  setState(() => _currentPage = index);
                },
                itemCount: _slides.length,
                itemBuilder: (context, index) {
                  final slide = _slides[index];
                  return _OnboardingPage(
                    icon: slide['icon'] as String,
                    title: slide['title'] as String,
                    subtitle: slide['subtitle'] as String,
                    color: Color(slide['color'] as int),
                    index: index,
                  );
                },
              ),
            ),

            // Dots + Button
            Padding(
              padding: const EdgeInsets.only(
                left: 32,
                right: 32,
                bottom: 48,
              ),
              child: Column(
                children: [
                  // Dots
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(_slides.length, (i) {
                      final isActive = i == _currentPage;
                      return AnimatedContainer(
                        duration: 300.ms,
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: isActive ? 28 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4),
                          color: isActive
                              ? AppTheme.amberAccent
                              : AppTheme.zinc700,
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 32),

                  // Next / Start button
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: FilledButton(
                      onPressed: _nextPage,
                      style: FilledButton.styleFrom(
                        backgroundColor: AppTheme.amberAccent,
                        foregroundColor: AppTheme.zinc950,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        textStyle: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      child: Text(
                        _currentPage < _slides.length - 1
                            ? 'Continuer'
                            : 'Commencer',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OnboardingPage extends StatelessWidget {
  final String icon;
  final String title;
  final String subtitle;
  final Color color;
  final int index;

  const _OnboardingPage({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon circle
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withValues(alpha: 0.12),
            ),
            child: Icon(
              _mapIcon(icon),
              size: 56,
              color: color,
            ),
          ).animate().fadeIn(
            duration: 500.ms,
            delay: (index * 150).ms,
          ).scale(
            begin: const Offset(0.8, 0.8),
            end: const Offset(1, 1),
            duration: 500.ms,
            delay: (index * 150).ms,
            curve: Curves.easeOutBack,
          ),
          const SizedBox(height: 40),

          // Title
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w700,
              color: AppTheme.zinc100,
              letterSpacing: -0.02,
            ),
          ).animate().fadeIn(
            duration: 400.ms,
            delay: (index * 150 + 200).ms,
          ).moveY(
            begin: 20,
            end: 0,
            duration: 400.ms,
            delay: (index * 150 + 200).ms,
            curve: Curves.easeOut,
          ),
          const SizedBox(height: 16),

          // Subtitle
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 16,
              color: AppTheme.zinc400,
              height: 1.5,
            ),
          ).animate().fadeIn(
            duration: 400.ms,
            delay: (index * 150 + 350).ms,
          ).moveY(
            begin: 20,
            end: 0,
            duration: 400.ms,
            delay: (index * 150 + 350).ms,
            curve: Curves.easeOut,
          ),
        ],
      ),
    );
  }

  IconData _mapIcon(String iconName) {
    switch (iconName) {
      case 'savings':
        return Icons.savings;
      case 'receipt_long':
        return Icons.receipt_long;
      case 'trending_up':
        return Icons.trending_up;
      case 'timer':
        return Icons.timer;
      default:
        return Icons.circle;
    }
  }
}
