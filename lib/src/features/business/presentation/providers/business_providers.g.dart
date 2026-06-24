// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'business_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(businessRepository)
final businessRepositoryProvider = BusinessRepositoryProvider._();

final class BusinessRepositoryProvider extends $FunctionalProvider<
    BusinessRepository,
    BusinessRepository,
    BusinessRepository> with $Provider<BusinessRepository> {
  BusinessRepositoryProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'businessRepositoryProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$businessRepositoryHash();

  @$internal
  @override
  $ProviderElement<BusinessRepository> $createElement(
          $ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  BusinessRepository create(Ref ref) {
    return businessRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(BusinessRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<BusinessRepository>(value),
    );
  }
}

String _$businessRepositoryHash() =>
    r'f9e1c33b33d2cbe483193007c8f51e0f08188eb3';

@ProviderFor(BranchesList)
final branchesListProvider = BranchesListProvider._();

final class BranchesListProvider
    extends $AsyncNotifierProvider<BranchesList, List<Branch>> {
  BranchesListProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'branchesListProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$branchesListHash();

  @$internal
  @override
  BranchesList create() => BranchesList();
}

String _$branchesListHash() => r'982ff830b6980739a9e00f733bc1b6c86e362662';

abstract class _$BranchesList extends $AsyncNotifier<List<Branch>> {
  FutureOr<List<Branch>> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<List<Branch>>, List<Branch>>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<AsyncValue<List<Branch>>, List<Branch>>,
        AsyncValue<List<Branch>>,
        Object?,
        Object?>;
    return element.handleCreate(ref, build);
  }
}

@ProviderFor(ItemsList)
final itemsListProvider = ItemsListProvider._();

final class ItemsListProvider
    extends $AsyncNotifierProvider<ItemsList, List<BusinessItem>> {
  ItemsListProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'itemsListProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$itemsListHash();

  @$internal
  @override
  ItemsList create() => ItemsList();
}

String _$itemsListHash() => r'82ce6bdd7757f06d3fbbf970e494449121b5dc48';

abstract class _$ItemsList extends $AsyncNotifier<List<BusinessItem>> {
  FutureOr<List<BusinessItem>> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref as $Ref<AsyncValue<List<BusinessItem>>, List<BusinessItem>>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<AsyncValue<List<BusinessItem>>, List<BusinessItem>>,
        AsyncValue<List<BusinessItem>>,
        Object?,
        Object?>;
    return element.handleCreate(ref, build);
  }
}

@ProviderFor(OffersList)
final offersListProvider = OffersListProvider._();

final class OffersListProvider
    extends $AsyncNotifierProvider<OffersList, List<Offer>> {
  OffersListProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'offersListProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$offersListHash();

  @$internal
  @override
  OffersList create() => OffersList();
}

String _$offersListHash() => r'58d9dcb723597ab5f4b3c14dbff186068835865a';

abstract class _$OffersList extends $AsyncNotifier<List<Offer>> {
  FutureOr<List<Offer>> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<List<Offer>>, List<Offer>>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<AsyncValue<List<Offer>>, List<Offer>>,
        AsyncValue<List<Offer>>,
        Object?,
        Object?>;
    return element.handleCreate(ref, build);
  }
}

@ProviderFor(offerDetail)
final offerDetailProvider = OfferDetailFamily._();

final class OfferDetailProvider
    extends $FunctionalProvider<AsyncValue<Offer?>, Offer?, FutureOr<Offer?>>
    with $FutureModifier<Offer?>, $FutureProvider<Offer?> {
  OfferDetailProvider._(
      {required OfferDetailFamily super.from, required String super.argument})
      : super(
          retry: null,
          name: r'offerDetailProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$offerDetailHash();

  @override
  String toString() {
    return r'offerDetailProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<Offer?> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<Offer?> create(Ref ref) {
    final argument = this.argument as String;
    return offerDetail(
      ref,
      argument,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is OfferDetailProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$offerDetailHash() => r'8ca5dae95eacff852a068a89dafff375b4e281f7';

final class OfferDetailFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<Offer?>, String> {
  OfferDetailFamily._()
      : super(
          retry: null,
          name: r'offerDetailProvider',
          dependencies: null,
          $allTransitiveDependencies: null,
          isAutoDispose: true,
        );

  OfferDetailProvider call(
    String offerId,
  ) =>
      OfferDetailProvider._(argument: offerId, from: this);

  @override
  String toString() => r'offerDetailProvider';
}

@ProviderFor(DashboardStatsNotifier)
final dashboardStatsProvider = DashboardStatsNotifierProvider._();

final class DashboardStatsNotifierProvider
    extends $AsyncNotifierProvider<DashboardStatsNotifier, DashboardStats> {
  DashboardStatsNotifierProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'dashboardStatsProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$dashboardStatsNotifierHash();

  @$internal
  @override
  DashboardStatsNotifier create() => DashboardStatsNotifier();
}

String _$dashboardStatsNotifierHash() =>
    r'baa42fab031cfc4f7144e364d3940f7dd10471d0';

abstract class _$DashboardStatsNotifier extends $AsyncNotifier<DashboardStats> {
  FutureOr<DashboardStats> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<DashboardStats>, DashboardStats>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<AsyncValue<DashboardStats>, DashboardStats>,
        AsyncValue<DashboardStats>,
        Object?,
        Object?>;
    return element.handleCreate(ref, build);
  }
}
