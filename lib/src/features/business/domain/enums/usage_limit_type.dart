enum UsageLimitType {
  oneTime,
  oncePerMonth,
  twicePerMonth,
  custom,
}

extension UsageLimitTypeX on UsageLimitType {
  String get labelKey => switch (this) {
        UsageLimitType.oneTime => 'offers.limit_one_time',
        UsageLimitType.oncePerMonth => 'offers.limit_once_month',
        UsageLimitType.twicePerMonth => 'offers.limit_twice_month',
        UsageLimitType.custom => 'offers.limit_custom',
      };
}
