import 'package:equatable/equatable.dart';

class BranchPerformance extends Equatable {
  const BranchPerformance({
    required this.branchId,
    required this.branchName,
    required this.scanCount,
    required this.uniqueUsers,
    required this.redemptionCount,
  });

  final String branchId;
  final String branchName;
  final int scanCount;
  final int uniqueUsers;
  final int redemptionCount;

  @override
  List<Object?> get props =>
      [branchId, branchName, scanCount, uniqueUsers, redemptionCount];
}

class DashboardStats extends Equatable {
  const DashboardStats({
    required this.totalBranches,
    required this.totalOffers,
    required this.activeOffers,
    required this.totalScans,
    required this.totalRedemptions,
    required this.uniqueUsers,
    required this.branchPerformance,
    this.topBranch,
  });

  final int totalBranches;
  final int totalOffers;
  final int activeOffers;
  final int totalScans;
  final int totalRedemptions;
  final int uniqueUsers;
  final BranchPerformance? topBranch;
  final List<BranchPerformance> branchPerformance;

  @override
  List<Object?> get props => [
        totalBranches,
        totalOffers,
        activeOffers,
        totalScans,
        totalRedemptions,
        uniqueUsers,
        topBranch,
        branchPerformance,
      ];
}
