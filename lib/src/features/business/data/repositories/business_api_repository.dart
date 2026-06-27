import 'package:dio/dio.dart';
import 'package:goluto_business/src/features/business/data/mappers/business_api_mappers.dart';
import 'package:goluto_business/src/features/business/domain/entities/branch.dart';
import 'package:goluto_business/src/features/business/domain/entities/dashboard_stats.dart';
import 'package:goluto_business/src/features/business/domain/entities/offer.dart';
import 'package:goluto_business/src/features/business/domain/enums/offer_branch_scope.dart';
import 'package:goluto_business/src/features/business/domain/repositories/business_repository.dart';
import 'package:goluto_business/src/services/dio_service.dart';
import 'package:goluto_business/src/utils/failure.dart';
import 'package:goluto_business/src/utils/typedefs.dart';
import 'package:fpdart/fpdart.dart';

class BusinessApiRepository implements BusinessRepository {
  BusinessApiRepository(this._dio);

  final DioService _dio;

  List<Branch> _cachedBranches = const [];

  FutureEither<T> _request<T>(FutureEither<Response> Function() call) async {
    final responseResult = await call();
    return responseResult.fold(
      (failure) => left(failure),
      (response) {
        try {
          return right(response.data as T);
        } catch (error) {
          return left(ServerFailure('Unexpected server response.', error: error));
        }
      },
    );
  }

  FutureEither<List<Map<String, dynamic>>> _fetchBranchMaps() async {
    final result = await _request<List<dynamic>>(
      () => _dio.get('/business/branches'),
    );
    return result.map((data) => data.cast<Map<String, dynamic>>());
  }

  FutureEither<List<Map<String, dynamic>>> _fetchOfferMaps() async {
    final result = await _request<List<dynamic>>(
      () => _dio.get('/business/offers'),
    );
    return result.map((data) => data.cast<Map<String, dynamic>>());
  }

  List<String> _resolveBranchIds(Offer offer) {
    if (offer.branchScope == OfferBranchScope.allBranches) {
      return _cachedBranches.map((branch) => branch.id).toList();
    }
    return offer.branchIds;
  }

  @override
  FutureEither<List<Branch>> getBranches() async {
    final result = await _fetchBranchMaps();
    return result.map((items) {
      _cachedBranches = items.map(BusinessApiMappers.branchFromJson).toList();
      return List<Branch>.from(_cachedBranches);
    });
  }

  @override
  FutureEither<Branch> getBranch(String id) async {
    final result = await _request<Map<String, dynamic>>(
      () => _dio.get('/business/branches/$id'),
    );
    return result.map(BusinessApiMappers.branchFromJson);
  }

  @override
  FutureEither<Branch> createBranch({
    required String name,
    required String street,
    required String houseNumber,
    required String postalCode,
    required String city,
    required double latitude,
    required double longitude,
  }) async {
    final branch = Branch(
      id: '',
      name: name,
      street: street,
      houseNumber: houseNumber,
      postalCode: postalCode,
      city: city,
      latitude: latitude,
      longitude: longitude,
    );

    final result = await _request<Map<String, dynamic>>(
      () => _dio.post('/business/branches', data: BusinessApiMappers.branchToJson(branch)),
    );

    return result.map((json) {
      final created = BusinessApiMappers.branchFromJson(
        BusinessApiMappers.unwrapEntity(json),
      );
      _cachedBranches = [..._cachedBranches, created];
      return created;
    });
  }

  @override
  FutureEither<Branch> updateBranch(Branch branch) async {
    final result = await _request<Map<String, dynamic>>(
      () => _dio.put(
        '/business/branches/${branch.id}',
        data: BusinessApiMappers.branchToJson(branch),
      ),
    );

    return result.map((json) {
      final updated = BusinessApiMappers.branchFromJson(
        BusinessApiMappers.unwrapEntity(json),
      );
      _cachedBranches = _cachedBranches
          .map((item) => item.id == updated.id ? updated : item)
          .toList();
      return updated;
    });
  }

  @override
  FutureEither<void> deleteBranch(String id) async {
    final result = await _dio.delete('/business/branches/$id');
    return result.map((_) {
      _cachedBranches =
          _cachedBranches.where((branch) => branch.id != id).toList();
      return null;
    });
  }

  @override
  FutureEither<List<Offer>> getOffers() async {
    if (_cachedBranches.isEmpty) {
      await getBranches();
    }

    final result = await _fetchOfferMaps();
    return result.map(
      (items) => items
          .map(
            (json) => BusinessApiMappers.offerFromJson(
              json,
              totalBranches: _cachedBranches.length,
            ),
          )
          .toList(),
    );
  }

  @override
  FutureEither<Offer> getOffer(String id) async {
    if (_cachedBranches.isEmpty) {
      await getBranches();
    }

    final result = await _request<Map<String, dynamic>>(
      () => _dio.get('/business/offers/$id'),
    );

    return result.map(
      (json) => BusinessApiMappers.offerFromJson(
        BusinessApiMappers.unwrapEntity(json),
        totalBranches: _cachedBranches.length,
      ),
    );
  }

  @override
  FutureEither<Offer> createOffer(Offer offer) async {
    if (_cachedBranches.isEmpty) {
      await getBranches();
    }

    final branchIds = _resolveBranchIds(offer);
    final result = await _request<Map<String, dynamic>>(
      () => _dio.post(
        '/business/offers',
        data: BusinessApiMappers.offerToJson(
          offer,
          resolvedBranchIds: branchIds,
        ),
      ),
    );

    return result.map(
      (json) => BusinessApiMappers.offerFromJson(
        BusinessApiMappers.unwrapEntity(json),
        totalBranches: _cachedBranches.length,
      ),
    );
  }

  @override
  FutureEither<Offer> updateOffer(Offer offer) async {
    if (_cachedBranches.isEmpty) {
      await getBranches();
    }

    final branchIds = _resolveBranchIds(offer);
    final result = await _request<Map<String, dynamic>>(
      () => _dio.put(
        '/business/offers/${offer.id}',
        data: BusinessApiMappers.offerToJson(
          offer,
          resolvedBranchIds: branchIds,
        ),
      ),
    );

    return result.map(
      (json) => BusinessApiMappers.offerFromJson(
        BusinessApiMappers.unwrapEntity(json),
        totalBranches: _cachedBranches.length,
      ),
    );
  }

  @override
  FutureEither<void> deleteOffer(String id) async {
    final result = await _dio.delete('/business/offers/$id');
    return result.map((_) {});
  }

  @override
  FutureEither<DashboardStats> getDashboardStats() async {
    final branchesResult = await getBranches();
    final offersResult = await getOffers();

    return branchesResult.fold(
      left,
      (branches) => offersResult.fold(
        left,
        (offers) => right(
          BusinessApiMappers.dashboardStatsFromData(
            branches: branches,
            offers: offers,
          ),
        ),
      ),
    );
  }
}
