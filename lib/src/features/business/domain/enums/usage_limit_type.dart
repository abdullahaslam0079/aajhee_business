enum UsageLimitType {
  oneTime,
  oncePerWeek,
  oncePerMonth,
  nTimesPerWeek,
  nTimesPerMonth,
  nTimesTotal,
}

extension UsageLimitTypeX on UsageLimitType {
  String get labelKey => switch (this) {
        UsageLimitType.oneTime => 'offers.limit_one_time',
        UsageLimitType.oncePerWeek => 'offers.limit_once_week',
        UsageLimitType.oncePerMonth => 'offers.limit_once_month',
        UsageLimitType.nTimesPerWeek => 'offers.limit_n_times_week',
        UsageLimitType.nTimesPerMonth => 'offers.limit_n_times_month',
        UsageLimitType.nTimesTotal => 'offers.limit_n_times_total',
      };

  String get apiValue => switch (this) {
        UsageLimitType.oneTime => 'one_time',
        UsageLimitType.oncePerWeek => 'once_per_week',
        UsageLimitType.oncePerMonth => 'once_per_month',
        UsageLimitType.nTimesPerWeek => 'n_times_per_week',
        UsageLimitType.nTimesPerMonth => 'n_times_per_month',
        UsageLimitType.nTimesTotal => 'n_times_total',
      };

  static UsageLimitType fromApi(String value) => switch (value) {
        'once_per_week' => UsageLimitType.oncePerWeek,
        'once_per_month' => UsageLimitType.oncePerMonth,
        'n_times_per_week' => UsageLimitType.nTimesPerWeek,
        'n_times_per_month' => UsageLimitType.nTimesPerMonth,
        'n_times_total' => UsageLimitType.nTimesTotal,
        _ => UsageLimitType.oneTime,
      };

  bool get requiresCount => switch (this) {
        UsageLimitType.nTimesPerWeek ||
        UsageLimitType.nTimesPerMonth ||
        UsageLimitType.nTimesTotal =>
          true,
        _ => false,
      };
}
