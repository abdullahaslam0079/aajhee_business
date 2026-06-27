import 'package:goluto_business/src/features/business/domain/entities/branch.dart';
import 'package:goluto_business/src/features/business/domain/entities/dashboard_stats.dart';
import 'package:goluto_business/src/features/business/domain/entities/offer.dart';
import 'package:goluto_business/src/utils/typedefs.dart';

abstract class BusinessRepository {
  FutureEither<List<Branch>> getBranches();
  FutureEither<Branch> getBranch(String id);
  FutureEither<Branch> createBranch({
    required String name,
    required String street,
    required String houseNumber,
    required String postalCode,
    required String city,
    required double latitude,
    required double longitude,
  });
  FutureEither<Branch> updateBranch(Branch branch);
  FutureEither<void> deleteBranch(String id);

  FutureEither<List<Offer>> getOffers();
  FutureEither<Offer> getOffer(String id);
  FutureEither<Offer> createOffer(Offer offer);
  FutureEither<Offer> updateOffer(Offer offer);
  FutureEither<void> deleteOffer(String id);

  FutureEither<DashboardStats> getDashboardStats();
}
