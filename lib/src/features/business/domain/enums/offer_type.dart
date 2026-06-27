enum OfferType {
  item,
  percentageBill,
}

extension OfferTypeX on OfferType {
  String get labelKey => switch (this) {
        OfferType.item => 'offers.type_item',
        OfferType.percentageBill => 'offers.type_bill',
      };

  String get apiValue => switch (this) {
        OfferType.item => 'item',
        OfferType.percentageBill => 'percentage_bill',
      };

  static OfferType fromApi(String value) => switch (value) {
        'item' => OfferType.item,
        _ => OfferType.percentageBill,
      };
}
