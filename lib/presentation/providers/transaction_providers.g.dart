// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transaction_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$monthlyTransactionsHash() =>
    r'ae53bffdc5e11f715b0511d28bf24d9fec0dd6d2';

/// See also [monthlyTransactions].
@ProviderFor(monthlyTransactions)
final monthlyTransactionsProvider =
    AutoDisposeStreamProvider<List<Transaction>>.internal(
      monthlyTransactions,
      name: r'monthlyTransactionsProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$monthlyTransactionsHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef MonthlyTransactionsRef =
    AutoDisposeStreamProviderRef<List<Transaction>>;
String _$recentTransactionsHash() =>
    r'954c0e4ccbd8390c0ec8ab87f30cf13bcc407465';

/// See also [recentTransactions].
@ProviderFor(recentTransactions)
final recentTransactionsProvider =
    AutoDisposeStreamProvider<List<Transaction>>.internal(
      recentTransactions,
      name: r'recentTransactionsProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$recentTransactionsHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef RecentTransactionsRef = AutoDisposeStreamProviderRef<List<Transaction>>;
String _$currentMonthHash() => r'9bfcc56eabd0922c93e2d216f23773def3a89714';

/// See also [CurrentMonth].
@ProviderFor(CurrentMonth)
final currentMonthProvider =
    AutoDisposeNotifierProvider<CurrentMonth, DateTime>.internal(
      CurrentMonth.new,
      name: r'currentMonthProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$currentMonthHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$CurrentMonth = AutoDisposeNotifier<DateTime>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
