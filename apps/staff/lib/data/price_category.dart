/// A price list the owner makes once ("PS5 عادي", "VIP", "PS4") and gives to many devices.
/// It does not know about device kinds: the pair price only counts for the
/// kinds that can have one (see UnitTypeRules). Prices are piasters.
class PriceCategory {
  const PriceCategory({
    required this.id,
    required this.name,
    required this.hourlyPrice,
    this.multiHourlyPrice,
  });

  final String id;
  final String name;
  final int hourlyPrice; // per hour, single
  final int? multiHourlyPrice; // per hour, two or more players; null = none
}
