import '../data/stock.dart';
import '../l10n/l10n.dart';

/// "باقي 24", or "ناقص 2" when more was sold than the shelf count says.
String stockLeftText(AppLocalizations l10n, StockItem item) =>
    item.onHand < 0 ? l10n.stockShort(-item.onHand) : l10n.stockLeft(item.onHand);
