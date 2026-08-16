import 'package:goluto_business/src/features/business/domain/entities/branch.dart';
import 'package:goluto_business/src/features/business/domain/entities/dashboard_stats.dart';
import 'package:goluto_business/src/features/business/domain/entities/offer.dart';
import 'package:goluto_business/src/features/business/domain/entities/offer_branch_stat.dart';
import 'package:goluto_business/src/features/business/domain/enums/offer_branch_scope.dart';
import 'package:goluto_business/src/features/business/domain/enums/offer_type.dart';
import 'package:goluto_business/src/features/business/domain/enums/usage_limit_type.dart';

class BusinessApiMappers {
  BusinessApiMappers._();

  static Branch branchFromJson(Map<String, dynamic> json) {
    return Branch(
      id: json['id'].toString(),
      name: json['name'] as String? ?? '',
      street: json['street'] as String? ?? '',
      houseNumber: json['house_number'] as String? ?? '',
      postalCode: json['postal_code'] as String? ?? '',
      city: json['city'] as String? ?? '',
      latitude: _toDouble(json['latitude']),
      longitude: _toDouble(json['longitude']),
    );
  }

  static Map<String, dynamic> branchToJson(Branch branch) {
    return {
      'name': branch.name,
      'street': branch.street,
      'house_number': branch.houseNumber,
      'postal_code': branch.postalCode,
      'city': branch.city,
      'latitude': branch.latitude.toStringAsFixed(6),
      'longitude': branch.longitude.toStringAsFixed(6),
    };
  }

  static Offer offerFromJson(
    Map<String, dynamic> json, {
    required int totalBranches,
  }) {
    final branches = (json['branches'] as List<dynamic>? ?? [])
        .cast<Map<String, dynamic>>();
    final branchIds = branches.map((b) => b['id'].toString()).toList();
    final branchStats = (json['branch_stats'] as List<dynamic>? ?? [])
        .map((stat) => offerBranchStatFromJson(stat as Map<String, dynamic>))
        .toList();

    final scope = totalBranches > 0 && branchIds.length >= totalBranches
        ? OfferBranchScope.allBranches
        : OfferBranchScope.selectedBranches;

    return Offer(
      id: json['id'].toString(),
      businessId: json['category_id']?.toString() ?? '',
      title: json['title'] as String? ?? '',
      description: _nullableString(json['description']),
      type: OfferTypeX.fromApi(json['offer_type'] as String? ?? ''),
      branchScope: scope,
      branchIds: branchIds,
      discountPercent: _toDouble(json['discount_percent']),
      usageLimitType:
          UsageLimitTypeX.fromApi(json['usage_limit_type'] as String? ?? ''),
      usageLimitCount: json['usage_limit_count'] as int? ?? 1,
      itemName: _nullableString(json['item_name']),
      includedItems: (json['included_items'] as List<dynamic>? ?? [])
          .map((item) => item.toString().trim())
          .where((item) => item.isNotEmpty)
          .toList(),
      originalPrice: _nullableDouble(json['original_price']),
      discountedPrice: _nullableDouble(json['discounted_price']),
      isEnabled: json['is_enabled'] as bool? ?? true,
      isTimeLimited: json['is_time_limited'] as bool? ?? false,
      isActive: json['is_active'] as bool? ?? true,
      startsAt: _nullableDateTime(json['starts_at']),
      endsAt: _nullableDateTime(json['ends_at']),
      qrCode: json['qr_code']?.toString() ?? '',
      createdAt: _nullableDateTime(json['created_at']) ?? DateTime.now(),
      branchStats: branchStats,
      imageUrl: _nullableString(json['image_url']),
    );
  }

  static OfferBranchStat offerBranchStatFromJson(Map<String, dynamic> json) {
    return OfferBranchStat(
      branchId: json['branch_id'].toString(),
      branchName: json['branch_name'] as String? ?? '',
      scanCount: json['scan_count'] as int? ?? 0,
      availCount: json['avail_count'] as int? ?? 0,
    );
  }

  static Map<String, dynamic> offerToJson(
    Offer offer, {
    required List<String> resolvedBranchIds,
  }) {
    final payload = <String, dynamic>{
      'offer_type': offer.type.apiValue,
      'title': offer.title,
      'description': offer.description ?? '',
      'usage_limit_type': offer.usageLimitType.apiValue,
      'usage_limit_count': offer.usageLimitCount,
      'branch_ids': resolvedBranchIds.map(int.parse).toList(),
      'is_enabled': offer.isEnabled,
      'is_time_limited': offer.isTimeLimited,
    };

    switch (offer.type) {
      case OfferType.percentageBill:
        payload['discount_percent'] = offer.discountPercent.toStringAsFixed(2);
      case OfferType.item:
        payload['item_name'] = offer.itemName ?? '';
        payload['original_price'] = offer.originalPrice?.toStringAsFixed(2);
        payload['discounted_price'] = offer.discountedPrice?.toStringAsFixed(2);
      case OfferType.deal:
        payload['included_items'] = offer.includedItems;
        payload['original_price'] = offer.originalPrice?.toStringAsFixed(2);
        payload['discounted_price'] = offer.discountedPrice?.toStringAsFixed(2);
    }

    if (offer.isTimeLimited) {
      if (offer.startsAt != null) {
        payload['starts_at'] = offer.startsAt!.toUtc().toIso8601String();
      }
      if (offer.endsAt != null) {
        payload['ends_at'] = offer.endsAt!.toUtc().toIso8601String();
      }
    }

    return payload;
  }

  static DashboardStats dashboardStatsFromData({
    required List<Branch> branches,
    required List<Offer> offers,
  }) {
    final activeOffers = offers.where((o) => o.isActive && o.isEnabled).length;
    final totalScans =
        offers.fold<int>(0, (sum, offer) => sum + offer.scanCount);
    final totalRedemptions =
        offers.fold<int>(0, (sum, offer) => sum + offer.redemptionCount);

    final branchAggregates = <String, BranchPerformance>{};

    for (final offer in offers) {
      for (final stat in offer.branchStats) {
        final existing = branchAggregates[stat.branchId];
        if (existing == null) {
          branchAggregates[stat.branchId] = BranchPerformance(
            branchId: stat.branchId,
            branchName: stat.branchName,
            scanCount: stat.scanCount,
            uniqueUsers: stat.scanCount,
            redemptionCount: stat.availCount,
          );
        } else {
          branchAggregates[stat.branchId] = BranchPerformance(
            branchId: existing.branchId,
            branchName: existing.branchName,
            scanCount: existing.scanCount + stat.scanCount,
            uniqueUsers: existing.uniqueUsers + stat.scanCount,
            redemptionCount: existing.redemptionCount + stat.availCount,
          );
        }
      }
    }

    for (final branch in branches) {
      branchAggregates.putIfAbsent(
        branch.id,
        () => BranchPerformance(
          branchId: branch.id,
          branchName: branch.name,
          scanCount: 0,
          uniqueUsers: 0,
          redemptionCount: 0,
        ),
      );
    }

    final branchPerformance = branchAggregates.values.toList()
      ..sort((a, b) => b.scanCount.compareTo(a.scanCount));

    return DashboardStats(
      totalBranches: branches.length,
      totalOffers: offers.length,
      activeOffers: activeOffers,
      totalScans: totalScans,
      totalRedemptions: totalRedemptions,
      uniqueUsers: totalScans,
      topBranch: branchPerformance.isNotEmpty ? branchPerformance.first : null,
      branchPerformance: branchPerformance,
    );
  }

  static Map<String, dynamic> unwrapEntity(Map<String, dynamic> json) {
    if (json.containsKey('id')) return json;
    for (final key in ['business', 'offer', 'branch']) {
      final nested = json[key];
      if (nested is Map<String, dynamic> && nested.containsKey('id')) {
        return nested;
      }
    }
    return json;
  }

  static double _toDouble(dynamic value) {
    if (value == null) return 0;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString()) ?? 0;
  }

  static double? _nullableDouble(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString());
  }

  static String? _nullableString(dynamic value) {
    if (value == null) return null;
    final text = value.toString().trim();
    return text.isEmpty ? null : text;
  }

  static DateTime? _nullableDateTime(dynamic value) {
    if (value == null) return null;
    return DateTime.tryParse(value.toString());
  }
}
