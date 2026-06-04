import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'data/database/app_database.dart';
import 'data/database/database_builder.dart';
import 'data/database/dao/category_dao.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize locale for date formatting
  await initializeDateFormatting('fr_FR', null);

  // Initialize database and seed data
  final db = buildDatabase();
  await _initSeedData(db);
  db.close();

  // Set system UI style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: AppTheme.zinc950,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  runApp(
    const ProviderScope(
      child: BudgethinkApp(),
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

class BudgethinkApp extends ConsumerWidget {
  const BudgethinkApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'Budgethink',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.dark,
      routerConfig: router,
    );
  }
}
