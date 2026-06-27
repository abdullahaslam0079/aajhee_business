import 'package:equatable/equatable.dart';
import 'package:goluto_business/src/features/business/domain/entities/offer_branch_stat.dart';
import 'package:goluto_business/src/features/business/domain/enums/offer_branch_scope.dart';
import 'package:goluto_business/src/features/business/domain/enums/offer_display_status.dart';
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
    required this.qrCode,
    required this.createdAt,
    this.description,
    this.branchIds = const [],
    this.usageLimitCount = 1,
    this.itemName,
    this.originalPrice,
    this.discountedPrice,
    this.isEnabled = true,
    this.isTimeLimited = false,
    this.isActive = true,
    this.startsAt,
    this.endsAt,
    this.branchStats = const [],
    this.imageUrl,
  });

  final String id;
  final String businessId;
  final String title;
  final String? description;
  final OfferType type;
  final OfferBranchScope branchScope;
  final List<String> branchIds;
  final double discountPercent;
  final UsageLimitType usageLimitType;
  final int usageLimitCount;
  final String? itemName;
  final double? originalPrice;
  final double? discountedPrice;
  final bool isEnabled;
  final bool isTimeLimited;
  final bool isActive;
  final DateTime? startsAt;
  final DateTime? endsAt;
  final String qrCode;
  final DateTime createdAt;
  final List<OfferBranchStat> branchStats;
  final String? imageUrl;

  int get scanCount =>
      branchStats.fold<int>(0, (sum, stat) => sum + stat.scanCount);

  int get redemptionCount =>
      branchStats.fold<int>(0, (sum, stat) => sum + stat.availCount);

  OfferDisplayStatus get displayStatus {
    if (!isEnabled) return OfferDisplayStatus.paused;
    if (!isActive) return OfferDisplayStatus.expired;
    return OfferDisplayStatus.active;
  }

  bool get appliesToAllBranches => branchScope == OfferBranchScope.allBranches;

  Offer copyWith({
    String? id,
    String? businessId,
    String? title,
    String? description,
    OfferType? type,
    OfferBranchScope? branchScope,
    List<String>? branchIds,
    double? discountPercent,
    UsageLimitType? usageLimitType,
    int? usageLimitCount,
    String? itemName,
    double? originalPrice,
    double? discountedPrice,
    bool? isEnabled,
    bool? isTimeLimited,
    bool? isActive,
    DateTime? startsAt,
    DateTime? endsAt,
    String? qrCode,
    DateTime? createdAt,
    List<OfferBranchStat>? branchStats,
    String? imageUrl,
  }) {
    return Offer(
      id: id ?? this.id,
      businessId: businessId ?? this.businessId,
      title: title ?? this.title,
      description: description ?? this.description,
      type: type ?? this.type,
      branchScope: branchScope ?? this.branchScope,
      branchIds: branchIds ?? this.branchIds,
      discountPercent: discountPercent ?? this.discountPercent,
      usageLimitType: usageLimitType ?? this.usageLimitType,
      usageLimitCount: usageLimitCount ?? this.usageLimitCount,
      itemName: itemName ?? this.itemName,
      originalPrice: originalPrice ?? this.originalPrice,
      discountedPrice: discountedPrice ?? this.discountedPrice,
      isEnabled: isEnabled ?? this.isEnabled,
      isTimeLimited: isTimeLimited ?? this.isTimeLimited,
      isActive: isActive ?? this.isActive,
      startsAt: startsAt ?? this.startsAt,
      endsAt: endsAt ?? this.endsAt,
      qrCode: qrCode ?? this.qrCode,
      createdAt: createdAt ?? this.createdAt,
      branchStats: branchStats ?? this.branchStats,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }

  @override
  List<Object?> get props => [
        id,
        businessId,
        title,
        description,
        type,
        branchScope,
        branchIds,
        discountPercent,
        usageLimitType,
        usageLimitCount,
        itemName,
        originalPrice,
        discountedPrice,
        isEnabled,
        isTimeLimited,
        isActive,
        startsAt,
        endsAt,
        qrCode,
        createdAt,
        branchStats,
        imageUrl,
      ];
}
