import 'package:goluto_business/src/features/business/data/repositories/business_repository_impl.dart';
import 'package:goluto_business/src/features/business/domain/entities/branch.dart';
import 'package:goluto_business/src/features/business/domain/entities/business_item.dart';
import 'package:goluto_business/src/features/business/domain/entities/dashboard_stats.dart';
import 'package:goluto_business/src/features/business/domain/entities/offer.dart';
import 'package:goluto_business/src/features/business/domain/repositories/business_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'business_providers.g.dart';

@Riverpod(keepAlive: true)
BusinessRepository businessRepository(Ref ref) {
  return BusinessRepositoryImpl.instance;
}

@Riverpod(keepAlive: true)
class BranchesList extends _$BranchesList {
  @override
  Future<List<Branch>> build() => _load();

  Future<List<Branch>> _load() async {
    final result = await ref.read(businessRepositoryProvider).getBranches();
    return result.getOrElse((_) => []);
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = AsyncData(await _load());
  }

  Future<bool> createBranch({
    required String name,
    String? address,
    String? city,
  }) async {
    final result = await ref.read(businessRepositoryProvider).createBranch(
          name: name,
          address: address,
          city: city,
        );
    return result.fold(
      (_) => false,
      (_) {
        ref.invalidateSelf();
        ref.invalidate(dashboardStatsProvider);
        return true;
      },
    );
  }

  Future<bool> updateBranch(Branch branch) async {
    final result =
        await ref.read(businessRepositoryProvider).updateBranch(branch);
    return result.fold(
      (_) => false,
      (_) {
        ref.invalidateSelf();
        ref.invalidate(dashboardStatsProvider);
        return true;
      },
    );
  }

  Future<bool> deleteBranch(String id) async {
    final result =
        await ref.read(businessRepositoryProvider).deleteBranch(id);
    return result.fold(
      (_) => false,
      (_) {
        ref.invalidateSelf();
        ref.invalidate(offersListProvider);
        ref.invalidate(dashboardStatsProvider);
        return true;
      },
    );
  }
}

@Riverpod(keepAlive: true)
class ItemsList extends _$ItemsList {
  @override
  Future<List<BusinessItem>> build() => _load();

  Future<List<BusinessItem>> _load() async {
    final result = await ref.read(businessRepositoryProvider).getItems();
    return result.getOrElse((_) => []);
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = AsyncData(await _load());
  }

  Future<bool> createItem({
    required String name,
    required double price,
    String? description,
    String? category,
  }) async {
    final result = await ref.read(businessRepositoryProvider).createItem(
          name: name,
          price: price,
          description: description,
          category: category,
        );
    return result.fold(
      (_) => false,
      (_) {
        ref.invalidateSelf();
        return true;
      },
    );
  }

  Future<bool> updateItem(BusinessItem item) async {
    final result = await ref.read(businessRepositoryProvider).updateItem(item);
    return result.fold(
      (_) => false,
      (_) {
        ref.invalidateSelf();
        return true;
      },
    );
  }

  Future<bool> deleteItem(String id) async {
    final result = await ref.read(businessRepositoryProvider).deleteItem(id);
    return result.fold(
      (_) => false,
      (_) {
        ref.invalidateSelf();
        ref.invalidate(offersListProvider);
        return true;
      },
    );
  }
}

@Riverpod(keepAlive: true)
class OffersList extends _$OffersList {
  @override
  Future<List<Offer>> build() => _load();

  Future<List<Offer>> _load() async {
    final result = await ref.read(businessRepositoryProvider).getOffers();
    return result.getOrElse((_) => []);
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = AsyncData(await _load());
  }

  Future<bool> createOffer(Offer offer) async {
    final result =
        await ref.read(businessRepositoryProvider).createOffer(offer);
    return result.fold(
      (_) => false,
      (_) {
        ref.invalidateSelf();
        ref.invalidate(dashboardStatsProvider);
        return true;
      },
    );
  }

  Future<bool> updateOffer(Offer offer) async {
    final result =
        await ref.read(businessRepositoryProvider).updateOffer(offer);
    return result.fold(
      (_) => false,
      (_) {
        ref.invalidateSelf();
        ref.invalidate(offerDetailProvider(offer.id));
        ref.invalidate(dashboardStatsProvider);
        return true;
      },
    );
  }

  Future<bool> deleteOffer(String id) async {
    final result =
        await ref.read(businessRepositoryProvider).deleteOffer(id);
    return result.fold(
      (_) => false,
      (_) {
        ref.invalidateSelf();
        ref.invalidate(dashboardStatsProvider);
        return true;
      },
    );
  }
}

@riverpod
Future<Offer?> offerDetail(Ref ref, String offerId) async {
  final result =
      await ref.read(businessRepositoryProvider).getOffer(offerId);
  return result.fold((_) => null, (offer) => offer);
}

@Riverpod(keepAlive: true)
class DashboardStatsNotifier extends _$DashboardStatsNotifier {
  @override
  Future<DashboardStats> build() => _load();

  Future<DashboardStats> _load() async {
    final result =
        await ref.read(businessRepositoryProvider).getDashboardStats();
    return result.getOrElse(
      (_) => const DashboardStats(
        totalBranches: 0,
        totalOffers: 0,
        activeOffers: 0,
        totalScans: 0,
        totalRedemptions: 0,
        uniqueUsers: 0,
        branchPerformance: [],
      ),
    );
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = AsyncData(await _load());
  }
}
