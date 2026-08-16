enum OfferType {
  item,
  percentageBill,
  deal,
}

extension OfferTypeX on OfferType {
  String get labelKey => switch (this) {
        OfferType.item => 'offers.type_item',
        OfferType.percentageBill => 'offers.type_bill',
        OfferType.deal => 'offers.type_deal',
      };

  String get apiValue => switch (this) {
        OfferType.item => 'item',
        OfferType.percentageBill => 'percentage_bill',
        OfferType.deal => 'deal',
      };

  bool get usesCompareAtPrice => this == OfferType.item;

  bool get usesDealPrice =>
      this == OfferType.item || this == OfferType.deal;

  static OfferType fromApi(String value) => switch (value) {
        'item' => OfferType.item,
        'deal' => OfferType.deal,
        _ => OfferType.percentageBill,
      };
}
