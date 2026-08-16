import 'package:goluto_business/src/features/business/domain/entities/offer.dart';
import 'package:goluto_business/src/features/business/domain/enums/offer_type.dart';
import 'package:goluto_business/src/features/business/domain/enums/usage_limit_type.dart';
import 'package:goluto_business/src/imports/core_imports.dart';

class OfferDisplayHelper {
  OfferDisplayHelper._();

  static String discountLabel(Offer offer) {
    if (offer.type == OfferType.percentageBill) {
      return '${offer.discountPercent.toStringAsFixed(0)}% ${'offers.off_entire_bill'.tr()}';
    }

    if (offer.type == OfferType.deal) {
      final items = offer.includedItems.isNotEmpty
          ? offer.includedItems.join(', ')
          : offer.title;
      if (offer.originalPrice != null && offer.discountedPrice != null) {
        return '$items (${offer.discountedPrice!.toStringAsFixed(2)}€ / ${offer.originalPrice!.toStringAsFixed(2)}€)';
      }
      return items;
    }

    if (offer.itemName != null && offer.itemName!.isNotEmpty) {
      if (offer.originalPrice != null && offer.discountedPrice != null) {
        return '${offer.itemName!} (${offer.discountedPrice!.toStringAsFixed(2)}€ / ${offer.originalPrice!.toStringAsFixed(2)}€)';
      }
      return offer.itemName!;
    }

    return '${offer.discountPercent.toStringAsFixed(0)}% ${'offers.product_discount'.tr()}';
  }

  static String usageLimitLabel(Offer offer) {
    if (offer.usageLimitType.requiresCount) {
      return 'offers.limit_custom_value'.tr(namedArgs: {
        'count': '${offer.usageLimitCount}',
        'period': _periodLabel(offer.usageLimitType),
      });
    }
    return offer.usageLimitType.labelKey.tr();
  }

  static String _periodLabel(UsageLimitType type) {
    return switch (type) {
      UsageLimitType.oncePerWeek || UsageLimitType.nTimesPerWeek =>
        'offers.period_week'.tr(),
      UsageLimitType.oncePerMonth || UsageLimitType.nTimesPerMonth =>
        'offers.period_month'.tr(),
      UsageLimitType.nTimesTotal => 'offers.period_total'.tr(),
      _ => 'offers.period_month'.tr(),
    };
  }
}
