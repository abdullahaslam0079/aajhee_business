import 'package:equatable/equatable.dart';

class OfferBranchStat extends Equatable {
  const OfferBranchStat({
    required this.branchId,
    required this.branchName,
    required this.scanCount,
    required this.availCount,
  });

  final String branchId;
  final String branchName;
  final int scanCount;
  final int availCount;

  @override
  List<Object?> get props => [branchId, branchName, scanCount, availCount];
}
