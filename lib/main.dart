import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/theme/app_theme.dart';
import 'data/database/app_database.dart';
import 'data/database/database_builder.dart';
import 'data/database/dao/category_dao.dart';
import 'presentation/providers/provider_app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await initializeDateFormatting('fr_FR', null);

  // Initialisation DB + seed data
  final db = buildDatabase();
  await _initSeedData(db);
  db.close();

  // Vérifier si l'onboarding a déjà été complété
  final prefs = await SharedPreferences.getInstance();
  final onboardingComplete = prefs.getBool('onboarding_complete') ?? false;

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: AppTheme.zinc950,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  runApp(
    ProviderScope(
      overrides: [
        onboardingCompleteProvider.overrideWithValue(onboardingComplete),
      ],
      child: const EconomeApp(),
    ),
  );
}

Future<void> _initSeedData(AppDatabase db) async {
  try {
    final categoryDao = CategoryDao(db);
    await categoryDao.insertDefaults();
  } catch (e) {
    debugPrint('Seed data error: $e');
  }
}

class EconomeApp extends ConsumerWidget {
  const EconomeApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'Économe',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.dark,
      routerConfig: router,
    );
  }
}
