import 'package:goluto_business/src/features/business/domain/entities/branch.dart';
import 'package:goluto_business/src/features/business/domain/entities/business_item.dart';
import 'package:goluto_business/src/features/business/domain/entities/dashboard_stats.dart';
import 'package:goluto_business/src/features/business/domain/entities/offer.dart';
import 'package:goluto_business/src/utils/typedefs.dart';

abstract class BusinessRepository {
  FutureEither<List<Branch>> getBranches();
  FutureEither<Branch> getBranch(String id);
  FutureEither<Branch> createBranch({
    required String name,
    String? address,
    String? city,
  });
  FutureEither<Branch> updateBranch(Branch branch);
  FutureEither<void> deleteBranch(String id);

  FutureEither<List<BusinessItem>> getItems();
  FutureEither<BusinessItem> getItem(String id);
  FutureEither<BusinessItem> createItem({
    required String name,
    required double price,
    String? description,
    String? category,
  });
  FutureEither<BusinessItem> updateItem(BusinessItem item);
  FutureEither<void> deleteItem(String id);

  FutureEither<List<Offer>> getOffers();
  FutureEither<Offer> getOffer(String id);
  FutureEither<Offer> createOffer(Offer offer);
  FutureEither<Offer> updateOffer(Offer offer);
  FutureEither<void> deleteOffer(String id);

  FutureEither<DashboardStats> getDashboardStats();
}
