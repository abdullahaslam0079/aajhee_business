enum OfferType {
  productDiscount,
  billDiscount,
}

extension OfferTypeX on OfferType {
  String get labelKey => switch (this) {
        OfferType.productDiscount => 'offers.type_product',
        OfferType.billDiscount => 'offers.type_bill',
      };
}
