import 'package:aajhee_business/src/features/business/data/repositories/business_api_repository.dart';
import 'package:aajhee_business/src/features/business/domain/entities/branch.dart';
import 'package:aajhee_business/src/features/business/domain/entities/dashboard_stats.dart';
import 'package:aajhee_business/src/features/business/domain/entities/offer.dart';
import 'package:aajhee_business/src/features/business/domain/repositories/business_repository.dart';
import 'package:aajhee_business/src/services/dio_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'business_providers.g.dart';

@Riverpod(keepAlive: true)
BusinessRepository businessRepository(Ref ref) {
  return BusinessApiRepository(DioService.instance);
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
    required String street,
    required String houseNumber,
    required String postalCode,
    required String city,
    required double latitude,
    required double longitude,
  }) async {
    final result = await ref.read(businessRepositoryProvider).createBranch(
          name: name,
          street: street,
          houseNumber: houseNumber,
          postalCode: postalCode,
          city: city,
          latitude: latitude,
          longitude: longitude,
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

  Future<Offer?> createOffer(Offer offer) async {
    final result =
        await ref.read(businessRepositoryProvider).createOffer(offer);
    return result.fold(
      (_) => null,
      (created) {
        ref.invalidateSelf();
        ref.invalidate(dashboardStatsProvider);
        return created;
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
