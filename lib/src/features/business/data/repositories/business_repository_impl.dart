import 'dart:math';

import 'package:goluto_business/src/features/business/domain/entities/branch.dart';
import 'package:goluto_business/src/features/business/domain/entities/business_item.dart';
import 'package:goluto_business/src/features/business/domain/entities/dashboard_stats.dart';
import 'package:goluto_business/src/features/business/domain/entities/offer.dart';
import 'package:goluto_business/src/features/business/domain/enums/offer_branch_scope.dart';
import 'package:goluto_business/src/features/business/domain/enums/offer_status.dart';
import 'package:goluto_business/src/features/business/domain/enums/offer_type.dart';
import 'package:goluto_business/src/features/business/domain/enums/usage_limit_type.dart';
import 'package:goluto_business/src/features/business/domain/repositories/business_repository.dart';
import 'package:goluto_business/src/utils/failure.dart';
import 'package:goluto_business/src/utils/typedefs.dart';
import 'package:fpdart/fpdart.dart';

/// In-memory repository with seed data until the backend API is ready.
class BusinessRepositoryImpl implements BusinessRepository {
  BusinessRepositoryImpl._();

  static final BusinessRepositoryImpl instance = BusinessRepositoryImpl._();

  static const _businessId = 'biz_demo_001';
  final _random = Random();

  final List<Branch> _branches = [
    const Branch(
      id: 'branch_001',
      businessId: _businessId,
      name: 'Mitte Flagship',
      address: 'Friedrichstraße 123',
      city: 'Berlin',
      scanCount: 842,
      uniqueUsers: 312,
    ),
    const Branch(
      id: 'branch_002',
      businessId: _businessId,
      name: 'Kreuzberg Corner',
      address: 'Oranienstraße 45',
      city: 'Berlin',
      scanCount: 615,
      uniqueUsers: 248,
    ),
    const Branch(
      id: 'branch_003',
      businessId: _businessId,
      name: 'Prenzlauer Pop-up',
      address: 'Kastanienallee 12',
      city: 'Berlin',
      scanCount: 389,
      uniqueUsers: 176,
    ),
  ];

  final List<BusinessItem> _items = [
    const BusinessItem(
      id: 'item_001',
      businessId: _businessId,
      name: 'Margherita Pizza',
      price: 12.99,
      category: 'Pizza',
      description: 'Classic tomato, mozzarella & basil',
    ),
    const BusinessItem(
      id: 'item_002',
      businessId: _businessId,
      name: 'Caesar Salad',
      price: 9.50,
      category: 'Salads',
    ),
    const BusinessItem(
      id: 'item_003',
      businessId: _businessId,
      name: 'Espresso',
      price: 3.20,
      category: 'Drinks',
    ),
    const BusinessItem(
      id: 'item_004',
      businessId: _businessId,
      name: 'Chocolate Brownie',
      price: 5.80,
      category: 'Desserts',
    ),
    const BusinessItem(
      id: 'item_005',
      businessId: _businessId,
      name: 'Pasta Carbonara',
      price: 14.50,
      category: 'Pasta',
    ),
  ];

  final List<Offer> _offers = [
    Offer(
      id: 'offer_001',
      businessId: _businessId,
      title: 'Pizza & Pasta Combo',
      description: '15% off selected mains',
      type: OfferType.productDiscount,
      itemDiscounts: const {'item_001': 15, 'item_005': 15},
      discountPercent: 0,
      branchScope: OfferBranchScope.allBranches,
      usageLimitType: UsageLimitType.oncePerMonth,
      qrToken: 'tok_offer_001',
      createdAt: DateTime(2026, 5, 1),
      scanCount: 420,
      redemptionCount: 198,
    ),
    Offer(
      id: 'offer_002',
      businessId: _businessId,
      title: '10% Off Entire Bill',
      description: 'Flat 10% discount on your total bill',
      type: OfferType.billDiscount,
      discountPercent: 10,
      branchScope: OfferBranchScope.selectedBranches,
      branchIds: const ['branch_001', 'branch_002'],
      usageLimitType: UsageLimitType.oneTime,
      qrToken: 'tok_offer_002',
      createdAt: DateTime(2026, 5, 15),
      scanCount: 310,
      redemptionCount: 145,
    ),
    Offer(
      id: 'offer_003',
      businessId: _businessId,
      title: 'Weekend Dessert Special',
      description: '20% off brownie at Prenzlauer branch',
      type: OfferType.productDiscount,
      itemDiscounts: const {'item_004': 20},
      discountPercent: 0,
      branchScope: OfferBranchScope.selectedBranches,
      branchIds: const ['branch_003'],
      usageLimitType: UsageLimitType.twicePerMonth,
      qrToken: 'tok_offer_003',
      createdAt: DateTime(2026, 6, 1),
      status: OfferStatus.active,
      scanCount: 156,
      redemptionCount: 89,
    ),
    Offer(
      id: 'offer_004',
      businessId: _businessId,
      title: 'VIP – 5 Uses / Month',
      description: 'Custom loyalty offer for repeat customers',
      type: OfferType.billDiscount,
      discountPercent: 5,
      branchScope: OfferBranchScope.allBranches,
      usageLimitType: UsageLimitType.custom,
      customUsageCount: 5,
      customUsagePeriod: 'month',
      qrToken: 'tok_offer_004',
      createdAt: DateTime(2026, 6, 10),
      scanCount: 78,
      redemptionCount: 42,
    ),
  ];

  int _branchCounter = 4;
  int _offerCounter = 5;
  int _itemCounter = 6;

  String _newBranchId() => 'branch_${_branchCounter++}';
  String _newOfferId() => 'offer_${_offerCounter++}';
  String _newItemId() => 'item_${_itemCounter++}';
  String _newToken() =>
      'tok_${DateTime.now().millisecondsSinceEpoch}_${_random.nextInt(9999)}';

  @override
  FutureEither<List<Branch>> getBranches() async {
    return right(List<Branch>.from(_branches));
  }

  @override
  FutureEither<Branch> getBranch(String id) async {
    final branch = _branches.where((b) => b.id == id).firstOrNull;
    if (branch == null) {
      return left(ServerFailure('Branch not found'));
    }
    return right(branch);
  }

  @override
  FutureEither<Branch> createBranch({
    required String name,
    String? address,
    String? city,
  }) async {
    final branch = Branch(
      id: _newBranchId(),
      businessId: _businessId,
      name: name,
      address: address,
      city: city,
    );
    _branches.add(branch);
    return right(branch);
  }

  @override
  FutureEither<Branch> updateBranch(Branch branch) async {
    final index = _branches.indexWhere((b) => b.id == branch.id);
    if (index == -1) {
      return left(ServerFailure('Branch not found'));
    }
    _branches[index] = branch;
    return right(branch);
  }

  @override
  FutureEither<void> deleteBranch(String id) async {
    final index = _branches.indexWhere((b) => b.id == id);
    if (index == -1) {
      return left(ServerFailure('Branch not found'));
    }
    _branches.removeAt(index);
    for (var i = 0; i < _offers.length; i++) {
      final offer = _offers[i];
      if (offer.branchIds.contains(id)) {
        _offers[i] = offer.copyWith(
          branchIds: offer.branchIds.where((bid) => bid != id).toList(),
        );
      }
    }
    return right(null);
  }

  @override
  FutureEither<List<BusinessItem>> getItems() async {
    return right(List<BusinessItem>.from(_items));
  }

  @override
  FutureEither<BusinessItem> getItem(String id) async {
    final item = _items.where((i) => i.id == id).firstOrNull;
    if (item == null) {
      return left(ServerFailure('Item not found'));
    }
    return right(item);
  }

  @override
  FutureEither<BusinessItem> createItem({
    required String name,
    required double price,
    String? description,
    String? category,
  }) async {
    final item = BusinessItem(
      id: _newItemId(),
      businessId: _businessId,
      name: name,
      price: price,
      description: description,
      category: category,
    );
    _items.add(item);
    return right(item);
  }

  @override
  FutureEither<BusinessItem> updateItem(BusinessItem item) async {
    final index = _items.indexWhere((i) => i.id == item.id);
    if (index == -1) {
      return left(ServerFailure('Item not found'));
    }
    _items[index] = item;
    return right(item);
  }

  @override
  FutureEither<void> deleteItem(String id) async {
    final index = _items.indexWhere((i) => i.id == id);
    if (index == -1) {
      return left(ServerFailure('Item not found'));
    }
    _items.removeAt(index);
    for (var i = 0; i < _offers.length; i++) {
      final offer = _offers[i];
      if (offer.itemDiscounts.containsKey(id)) {
        final updated = Map<String, double>.from(offer.itemDiscounts)
          ..remove(id);
        _offers[i] = offer.copyWith(itemDiscounts: updated);
      }
    }
    return right(null);
  }

  @override
  FutureEither<List<Offer>> getOffers() async {
    return right(List<Offer>.from(_offers));
  }

  @override
  FutureEither<Offer> getOffer(String id) async {
    final offer = _offers.where((o) => o.id == id).firstOrNull;
    if (offer == null) {
      return left(ServerFailure('Offer not found'));
    }
    return right(offer);
  }

  @override
  FutureEither<Offer> createOffer(Offer offer) async {
    final created = offer.copyWith(
      id: _newOfferId(),
      businessId: _businessId,
      qrToken: _newToken(),
      createdAt: DateTime.now(),
    );
    _offers.add(created);
    return right(created);
  }

  @override
  FutureEither<Offer> updateOffer(Offer offer) async {
    final index = _offers.indexWhere((o) => o.id == offer.id);
    if (index == -1) {
      return left(ServerFailure('Offer not found'));
    }
    _offers[index] = offer;
    return right(offer);
  }

  @override
  FutureEither<void> deleteOffer(String id) async {
    final index = _offers.indexWhere((o) => o.id == id);
    if (index == -1) {
      return left(ServerFailure('Offer not found'));
    }
    _offers.removeAt(index);
    return right(null);
  }

  @override
  FutureEither<DashboardStats> getDashboardStats() async {
    final totalScans = _offers.fold<int>(0, (sum, o) => sum + o.scanCount);
    final totalRedemptions =
        _offers.fold<int>(0, (sum, o) => sum + o.redemptionCount);
    final activeOffers =
        _offers.where((o) => o.status == OfferStatus.active).length;

    final branchPerformance = _branches
        .map(
          (b) => BranchPerformance(
            branchId: b.id,
            branchName: b.name,
            scanCount: b.scanCount,
            uniqueUsers: b.uniqueUsers,
            redemptionCount: (b.scanCount * 0.42).round(),
          ),
        )
        .toList()
      ..sort((a, b) => b.uniqueUsers.compareTo(a.uniqueUsers));

    final uniqueUsers =
        _branches.fold<int>(0, (sum, b) => sum + b.uniqueUsers);

    return right(
      DashboardStats(
        totalBranches: _branches.length,
        totalOffers: _offers.length,
        activeOffers: activeOffers,
        totalScans: totalScans,
        totalRedemptions: totalRedemptions,
        uniqueUsers: uniqueUsers,
        topBranch: branchPerformance.isNotEmpty ? branchPerformance.first : null,
        branchPerformance: branchPerformance,
      ),
    );
  }
}
