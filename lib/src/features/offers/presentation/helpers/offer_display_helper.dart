import 'package:goluto_business/src/features/business/domain/entities/business_item.dart';
import 'package:goluto_business/src/features/business/domain/entities/offer.dart';
import 'package:goluto_business/src/features/business/domain/enums/offer_type.dart';
import 'package:goluto_business/src/features/business/domain/enums/usage_limit_type.dart';
import 'package:goluto_business/src/imports/core_imports.dart';

class OfferDisplayHelper {
  OfferDisplayHelper._();

  static String discountLabel(Offer offer, {List<BusinessItem>? items}) {
    if (offer.type == OfferType.billDiscount) {
      return '${offer.discountPercent.toStringAsFixed(0)}% ${'offers.off_entire_bill'.tr()}';
    }

    if (offer.itemDiscounts.isEmpty) {
      return 'offers.product_discount'.tr();
    }

    if (items != null && items.isNotEmpty) {
      final names = offer.itemDiscounts.entries.map((entry) {
        final item = items.where((i) => i.id == entry.key).firstOrNull;
        final name = item?.name ?? entry.key;
        return '$name (${entry.value.toStringAsFixed(0)}%)';
      }).join(', ');
      return names;
    }

    final count = offer.itemDiscounts.length;
    return '${offer.itemDiscounts.values.first.toStringAsFixed(0)}% ${'offers.off_products'.tr(namedArgs: {'count': '$count'})}';
  }

  static String usageLimitLabel(Offer offer) {
    return switch (offer.usageLimitType) {
      UsageLimitType.oneTime => 'offers.limit_one_time'.tr(),
      UsageLimitType.oncePerMonth => 'offers.limit_once_month'.tr(),
      UsageLimitType.twicePerMonth => 'offers.limit_twice_month'.tr(),
      UsageLimitType.custom =>
        'offers.limit_custom_value'.tr(namedArgs: {
          'count': '${offer.customUsageCount ?? 1}',
          'period': 'offers.period_${offer.customUsagePeriod}'.tr(),
        }),
    };
  }
}
