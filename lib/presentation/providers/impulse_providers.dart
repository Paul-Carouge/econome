import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:econome/data/database/app_database.dart';
import 'package:econome/presentation/providers/database_providers.dart';

part 'impulse_providers.g.dart';

// ─── Impulse Providers ────────────────────────────────────────────────
@riverpod
Stream<List<ImpulseItem>> impulseList(ImpulseListRef ref) {
  return ref.watch(impulseDaoProvider).watchAll();
}

@riverpod
Stream<List<ImpulseItem>> impulseCooling(ImpulseCoolingRef ref) {
  return ref.watch(impulseDaoProvider).watchByStatus('cooling');
}

@riverpod
Future<int> impulseActiveCount(ImpulseActiveCountRef ref) async {
  return ref.watch(impulseDaoProvider).getActiveCount();
}
