/// A single pricing tier for a service (e.g. "Standard", "Premium").
class ServiceTier {
  final String tier;
  final double? gbp;
  final double? gbpYr;
  final double? usd;
  final double? usdYr;
  final double? eur;
  final double? eurYr;
  final double? pln;
  final double? plnYr;

  const ServiceTier({
    required this.tier,
    this.gbp,
    this.gbpYr,
    this.usd,
    this.usdYr,
    this.eur,
    this.eurYr,
    this.pln,
    this.plnYr,
  });

  /// Get the monthly price for a given currency code.
  double? monthlyPrice(String currency) {
    switch (currency.toUpperCase()) {
      case 'GBP':
        return gbp;
      case 'USD':
        return usd;
      case 'EUR':
        return eur;
      case 'PLN':
        return pln;
      default:
        return null;
    }
  }

  /// Get the annual price for a given currency code.
  double? annualPrice(String currency) {
    switch (currency.toUpperCase()) {
      case 'GBP':
        return gbpYr;
      case 'USD':
        return usdYr;
      case 'EUR':
        return eurYr;
      case 'PLN':
        return plnYr;
      default:
        return null;
    }
  }

  /// Whether this tier has an annual plan in any currency.
  bool get hasAnyAnnualPlan =>
      gbpYr != null || usdYr != null || eurYr != null || plnYr != null;
}

/// A service with known pricing tiers.
class ServiceInfo {
  final String name;
  final String slug;
  final String category;
  final String brandColor;
  final String iconLetter;
  final String fallbackCurrency;
  final List<ServiceTier> tiers;

  const ServiceInfo({
    required this.name,
    required this.slug,
    required this.category,
    required this.brandColor,
    required this.iconLetter,
    required this.fallbackCurrency,
    required this.tiers,
  });

  /// Whether any tier of this service has an annual plan.
  bool get hasAnyAnnualPlan => tiers.any((t) => t.hasAnyAnnualPlan);
}
