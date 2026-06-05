import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:econome/data/database/app_database.dart';
import 'package:econome/presentation/providers/database_providers.dart';

// ─── Impulse Providers ────────────────────────────────────────────────
final impulseListProvider = StreamProvider<List<ImpulseItem>>((ref) {
  return ref.watch(impulseDaoProvider).watchAll();
});

final impulseCoolingProvider = StreamProvider<List<ImpulseItem>>((ref) {
  return ref.watch(impulseDaoProvider).watchByStatus('cooling');
});

final impulseActiveCountProvider = FutureProvider<int>((ref) async {
  return ref.watch(impulseDaoProvider).getActiveCount();
});
