enum OfferStatus {
  active,
  paused,
  expired,
}

extension OfferStatusX on OfferStatus {
  String get labelKey => switch (this) {
        OfferStatus.active => 'offers.status_active',
        OfferStatus.paused => 'offers.status_paused',
        OfferStatus.expired => 'offers.status_expired',
      };
}
