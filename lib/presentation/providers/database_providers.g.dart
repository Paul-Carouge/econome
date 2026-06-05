// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(database)
final databaseProvider = DatabaseProvider._();

final class DatabaseProvider
    extends $FunctionalProvider<AppDatabase, AppDatabase, AppDatabase>
    with $Provider<AppDatabase> {
  DatabaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'databaseProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$databaseHash();

  @$internal
  @override
  $ProviderElement<AppDatabase> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  AppDatabase create(Ref ref) {
    return database(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AppDatabase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AppDatabase>(value),
    );
  }
}

String _$databaseHash() => r'6802853ae22fe3cb84bd6d30be3fb3cba292c405';

@ProviderFor(categoryDao)
final categoryDaoProvider = CategoryDaoProvider._();

final class CategoryDaoProvider
    extends $FunctionalProvider<CategoryDao, CategoryDao, CategoryDao>
    with $Provider<CategoryDao> {
  CategoryDaoProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'categoryDaoProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$categoryDaoHash();

  @$internal
  @override
  $ProviderElement<CategoryDao> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  CategoryDao create(Ref ref) {
    return categoryDao(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CategoryDao value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CategoryDao>(value),
    );
  }
}

String _$categoryDaoHash() => r'd60cddfaad7c88639a4de66ec6dc52a245e446ef';

@ProviderFor(transactionDao)
final transactionDaoProvider = TransactionDaoProvider._();

final class TransactionDaoProvider
    extends $FunctionalProvider<TransactionDao, TransactionDao, TransactionDao>
    with $Provider<TransactionDao> {
  TransactionDaoProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'transactionDaoProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$transactionDaoHash();

  @$internal
  @override
  $ProviderElement<TransactionDao> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  TransactionDao create(Ref ref) {
    return transactionDao(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(TransactionDao value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<TransactionDao>(value),
    );
  }
}

String _$transactionDaoHash() => r'b2f665f2dc5391e5fb5c35b237cdaf15db37e807';

@ProviderFor(budgetDao)
final budgetDaoProvider = BudgetDaoProvider._();

final class BudgetDaoProvider
    extends $FunctionalProvider<BudgetDao, BudgetDao, BudgetDao>
    with $Provider<BudgetDao> {
  BudgetDaoProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'budgetDaoProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$budgetDaoHash();

  @$internal
  @override
  $ProviderElement<BudgetDao> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  BudgetDao create(Ref ref) {
    return budgetDao(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(BudgetDao value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<BudgetDao>(value),
    );
  }
}

String _$budgetDaoHash() => r'60ef6922920757ec80409825b203e2450b9c1dc3';

@ProviderFor(savingsDao)
final savingsDaoProvider = SavingsDaoProvider._();

final class SavingsDaoProvider
    extends $FunctionalProvider<SavingsDao, SavingsDao, SavingsDao>
    with $Provider<SavingsDao> {
  SavingsDaoProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'savingsDaoProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$savingsDaoHash();

  @$internal
  @override
  $ProviderElement<SavingsDao> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  SavingsDao create(Ref ref) {
    return savingsDao(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SavingsDao value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SavingsDao>(value),
    );
  }
}

String _$savingsDaoHash() => r'a9021834498420a69de0653629f7c4c275c5804b';

@ProviderFor(impulseDao)
final impulseDaoProvider = ImpulseDaoProvider._();

final class ImpulseDaoProvider
    extends $FunctionalProvider<ImpulseDao, ImpulseDao, ImpulseDao>
    with $Provider<ImpulseDao> {
  ImpulseDaoProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'impulseDaoProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$impulseDaoHash();

  @$internal
  @override
  $ProviderElement<ImpulseDao> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  ImpulseDao create(Ref ref) {
    return impulseDao(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ImpulseDao value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ImpulseDao>(value),
    );
  }
}

String _$impulseDaoHash() => r'18720e3ddff456e71d64cc06cbefecabcd7139ec';

@ProviderFor(categoryRepository)
final categoryRepositoryProvider = CategoryRepositoryProvider._();

final class CategoryRepositoryProvider
    extends
        $FunctionalProvider<
          CategoryRepository,
          CategoryRepository,
          CategoryRepository
        >
    with $Provider<CategoryRepository> {
  CategoryRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'categoryRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$categoryRepositoryHash();

  @$internal
  @override
  $ProviderElement<CategoryRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  CategoryRepository create(Ref ref) {
    return categoryRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CategoryRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CategoryRepository>(value),
    );
  }
}

String _$categoryRepositoryHash() =>
    r'3e5434d83256c5ee951999232b75345c955b4e50';

@ProviderFor(transactionRepository)
final transactionRepositoryProvider = TransactionRepositoryProvider._();

final class TransactionRepositoryProvider
    extends
        $FunctionalProvider<
          TransactionRepository,
          TransactionRepository,
          TransactionRepository
        >
    with $Provider<TransactionRepository> {
  TransactionRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'transactionRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$transactionRepositoryHash();

  @$internal
  @override
  $ProviderElement<TransactionRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  TransactionRepository create(Ref ref) {
    return transactionRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(TransactionRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<TransactionRepository>(value),
    );
  }
}

String _$transactionRepositoryHash() =>
    r'e9a88426f85f49433002481537bbf69b47f025c6';

@ProviderFor(budgetRepository)
final budgetRepositoryProvider = BudgetRepositoryProvider._();

final class BudgetRepositoryProvider
    extends
        $FunctionalProvider<
          BudgetRepository,
          BudgetRepository,
          BudgetRepository
        >
    with $Provider<BudgetRepository> {
  BudgetRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'budgetRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$budgetRepositoryHash();

  @$internal
  @override
  $ProviderElement<BudgetRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  BudgetRepository create(Ref ref) {
    return budgetRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(BudgetRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<BudgetRepository>(value),
    );
  }
}

String _$budgetRepositoryHash() => r'c46d38dee05aa290da1d93d71e0360110ac5378c';

@ProviderFor(savingsRepository)
final savingsRepositoryProvider = SavingsRepositoryProvider._();

final class SavingsRepositoryProvider
    extends
        $FunctionalProvider<
          SavingsRepository,
          SavingsRepository,
          SavingsRepository
        >
    with $Provider<SavingsRepository> {
  SavingsRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'savingsRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$savingsRepositoryHash();

  @$internal
  @override
  $ProviderElement<SavingsRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  SavingsRepository create(Ref ref) {
    return savingsRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SavingsRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SavingsRepository>(value),
    );
  }
}

String _$savingsRepositoryHash() => r'44fce41deda995d256e353f0c6ce38aeaf3b8df8';

@ProviderFor(impulseRepository)
final impulseRepositoryProvider = ImpulseRepositoryProvider._();

final class ImpulseRepositoryProvider
    extends
        $FunctionalProvider<
          ImpulseRepository,
          ImpulseRepository,
          ImpulseRepository
        >
    with $Provider<ImpulseRepository> {
  ImpulseRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'impulseRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$impulseRepositoryHash();

  @$internal
  @override
  $ProviderElement<ImpulseRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ImpulseRepository create(Ref ref) {
    return impulseRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ImpulseRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ImpulseRepository>(value),
    );
  }
}

String _$impulseRepositoryHash() => r'36cdb214b7a65d8a6b7ded60859b7629fbf6653f';
