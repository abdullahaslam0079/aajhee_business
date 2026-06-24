import 'package:equatable/equatable.dart';
import 'package:goluto_business/src/features/business/domain/enums/offer_branch_scope.dart';
import 'package:goluto_business/src/features/business/domain/enums/offer_status.dart';
import 'package:goluto_business/src/features/business/domain/enums/offer_type.dart';
import 'package:goluto_business/src/features/business/domain/enums/usage_limit_type.dart';

class Offer extends Equatable {
  const Offer({
    required this.id,
    required this.businessId,
    required this.title,
    required this.type,
    required this.discountPercent,
    required this.branchScope,
    required this.usageLimitType,
    required this.qrToken,
    required this.createdAt,
    this.description,
    this.branchIds = const [],
    this.itemDiscounts = const {},
    this.customUsageCount,
    this.customUsagePeriod = 'month',
    this.validFrom,
    this.validUntil,
    this.status = OfferStatus.active,
    this.scanCount = 0,
    this.redemptionCount = 0,
  });

  final String id;
  final String businessId;
  final String title;
  final String? description;
  final OfferType type;
  final OfferStatus status;
  final OfferBranchScope branchScope;
  final List<String> branchIds;

  /// Item ID → discount % (product offers only).
  final Map<String, double> itemDiscounts;

  /// Bill-level discount when [type] is [OfferType.billDiscount].
  final double discountPercent;
  final UsageLimitType usageLimitType;
  final int? customUsageCount;
  final String customUsagePeriod;
  final DateTime? validFrom;
  final DateTime? validUntil;
  final int scanCount;
  final int redemptionCount;
  final String qrToken;
  final DateTime createdAt;

  bool get appliesToAllBranches => branchScope == OfferBranchScope.allBranches;

  List<String> get itemIds => itemDiscounts.keys.toList();

  Offer copyWith({
    String? id,
    String? businessId,
    String? title,
    String? description,
    OfferType? type,
    OfferStatus? status,
    OfferBranchScope? branchScope,
    List<String>? branchIds,
    Map<String, double>? itemDiscounts,
    double? discountPercent,
    UsageLimitType? usageLimitType,
    int? customUsageCount,
    String? customUsagePeriod,
    DateTime? validFrom,
    DateTime? validUntil,
    int? scanCount,
    int? redemptionCount,
    String? qrToken,
    DateTime? createdAt,
  }) {
    return Offer(
      id: id ?? this.id,
      businessId: businessId ?? this.businessId,
      title: title ?? this.title,
      description: description ?? this.description,
      type: type ?? this.type,
      status: status ?? this.status,
      branchScope: branchScope ?? this.branchScope,
      branchIds: branchIds ?? this.branchIds,
      itemDiscounts: itemDiscounts ?? this.itemDiscounts,
      discountPercent: discountPercent ?? this.discountPercent,
      usageLimitType: usageLimitType ?? this.usageLimitType,
      customUsageCount: customUsageCount ?? this.customUsageCount,
      customUsagePeriod: customUsagePeriod ?? this.customUsagePeriod,
      validFrom: validFrom ?? this.validFrom,
      validUntil: validUntil ?? this.validUntil,
      scanCount: scanCount ?? this.scanCount,
      redemptionCount: redemptionCount ?? this.redemptionCount,
      qrToken: qrToken ?? this.qrToken,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        businessId,
        title,
        description,
        type,
        status,
        branchScope,
        branchIds,
        itemDiscounts,
        discountPercent,
        usageLimitType,
        customUsageCount,
        customUsagePeriod,
        validFrom,
        validUntil,
        scanCount,
        redemptionCount,
        qrToken,
        createdAt,
      ];
}
