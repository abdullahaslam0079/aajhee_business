enum OfferDisplayStatus {
  active,
  paused,
  expired,
}

extension OfferDisplayStatusX on OfferDisplayStatus {
  String get labelKey => switch (this) {
        OfferDisplayStatus.active => 'offers.status_active',
        OfferDisplayStatus.paused => 'offers.status_paused',
        OfferDisplayStatus.expired => 'offers.status_expired',
      };
}
