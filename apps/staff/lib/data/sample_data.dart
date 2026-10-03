import 'bill.dart';
import 'payment_account.dart';
import 'product.dart';
import 'stock.dart';
import 'unit.dart';

/// Sample venue name (owners type their own in Venue setup).
const sampleVenueName = 'سوبر ماريو مصر الجديدة';

/// Sample payment accounts (the owner's own; real ones come from venue settings later).
const samplePaymentAccounts = {
  PaymentMethod.instapay: PaymentAccount(
    link: 'https://ipn.eg/S/mazenncib/instapay/3iCKbo',
    handle: 'mazenncib@instapay',
    phone: '01098626879',
  ),
  PaymentMethod.wallet: PaymentAccount(
    link: 'http://vf.eg/vfcash?id=mt&qrId=hSkXDs',
    phone: '01098626879',
  ),
};

/// Sample connection state (comes from the sync service later).
const sampleIsOnline = true;

/// 12 sample units matching the design. Replaced by real data later.
List<Unit> buildSampleUnits() {
  final now = DateTime.now();
  DateTime ago(int h, int m, int s) =>
      now.subtract(Duration(hours: h, minutes: m, seconds: s));

  return [
    // Two halls, grouped by the owner as "صالات البلايستيشن المشتركة"
    Unit(id: 'ps5-1', name: 'PS5-1', type: UnitType.playstation, roomId: 'hall-1', roomName: 'صالة 1', groupId: 'halls', groupName: 'صالات البلايستيشن المشتركة', status: UnitStatus.running, hourlyPrice: 50, multiHourlyPrice: 70, startedAt: ago(1, 24, 10)),
    Unit(id: 'ps5-2', name: 'PS5-2', type: UnitType.playstation, roomId: 'hall-1', roomName: 'صالة 1', groupId: 'halls', groupName: 'صالات البلايستيشن المشتركة', status: UnitStatus.running, hourlyPrice: 50, multiHourlyPrice: 70, startedAt: ago(0, 47, 33), isMulti: true, plannedMinutes: 60),
    Unit(id: 'ps5-3', name: 'PS5-3', type: UnitType.playstation, roomId: 'hall-1', roomName: 'صالة 1', groupId: 'halls', groupName: 'صالات البلايستيشن المشتركة', status: UnitStatus.free, hourlyPrice: 50, multiHourlyPrice: 70, nextReservationAt: now.add(const Duration(hours: 1, minutes: 20))),
    Unit(id: 'ps5-4', name: 'PS5-4', type: UnitType.playstation, roomId: 'hall-2', roomName: 'صالة 2', groupId: 'halls', groupName: 'صالات البلايستيشن المشتركة', status: UnitStatus.running, hourlyPrice: 50, multiHourlyPrice: 70, startedAt: ago(0, 59, 10), plannedMinutes: 60, nextReservationAt: now.add(const Duration(minutes: 15))),
    const Unit(id: 'ps4-1', name: 'PS4-1', type: UnitType.playstation, roomId: 'hall-2', roomName: 'صالة 2', groupId: 'halls', groupName: 'صالات البلايستيشن المشتركة', status: UnitStatus.waitingPayment, hourlyPrice: 60, multiHourlyPrice: 80, amountDue: 120),
    const Unit(id: 'ps4-2', name: 'PS4-2', type: UnitType.playstation, roomId: 'hall-2', roomName: 'صالة 2', groupId: 'halls', groupName: 'صالات البلايستيشن المشتركة', status: UnitStatus.maintenance, hourlyPrice: 60, multiHourlyPrice: 80, note: 'جهاز بايظ'),
    // Table room (no group)
    Unit(id: 'pp-1', name: 'بينج بونج 1', type: UnitType.pingPong, roomId: 'tables', roomName: 'ترابيزات البينج والبلياردو', status: UnitStatus.running, hourlyPrice: 40, multiHourlyPrice: 60, startedAt: ago(0, 32, 10), isMulti: true),
    const Unit(id: 'pp-2', name: 'بينج بونج 2', type: UnitType.pingPong, roomId: 'tables', roomName: 'ترابيزات البينج والبلياردو', status: UnitStatus.free, hourlyPrice: 40, multiHourlyPrice: 60),
    Unit(id: 'bil-1', name: 'بلياردو 1', type: UnitType.billiards, roomId: 'tables', roomName: 'ترابيزات البينج والبلياردو', status: UnitStatus.running, hourlyPrice: 60, startedAt: ago(1, 5, 0), plannedMinutes: 60),
    const Unit(id: 'bil-2', name: 'بلياردو 2', type: UnitType.billiards, roomId: 'tables', roomName: 'ترابيزات البينج والبلياردو', status: UnitStatus.free, hourlyPrice: 60),
    // Private rooms (one unit each)
    Unit(id: 'ps5-5', name: 'PS5-5', type: UnitType.playstation, roomId: 'vip-1', roomName: 'VIP 1', status: UnitStatus.running, hourlyPrice: 90, multiHourlyPrice: 120, startedAt: ago(0, 5, 12), isMulti: true),
    const Unit(id: 'ps5-6', name: 'PS5-6', type: UnitType.playstation, roomId: 'vip-2', roomName: 'VIP 2', status: UnitStatus.free, hourlyPrice: 90, multiHourlyPrice: 120),
  ];
}

/// Sample counter products. Replaced by the owner's own list later.
const sampleProducts = [
  Product(id: 'pepsi', name: 'بيبسي', price: 15, stockItemId: 'stock-pepsi'),
  Product(id: 'chips', name: 'شيبسي', price: 15, stockItemId: 'stock-chips'),
  Product(id: 'tea', name: 'شاي', price: 10, stockItemId: 'stock-tea'),
  Product(id: 'coffee', name: 'قهوة', price: 20, stockItemId: 'stock-coffee'),
  Product(id: 'water', name: 'مياه', price: 8, stockItemId: 'stock-water'),
  Product(id: 'juice', name: 'عصير', price: 15, stockItemId: 'stock-juice'),
  Product(id: 'indomie', name: 'اندومي', price: 25, stockItemId: 'stock-indomie'),
  Product(id: 'biscuit', name: 'بسكوت', price: 10, stockItemId: 'stock-biscuit'),
];

/// Sample stock. Cans and bags subtract on every sale; tea and coffee are counted in tins/packets
/// that staff record by hand (a cup does not subtract anything); sugar and milk are used, not sold.
/// Chips is low on purpose.
const sampleStockItems = [
  StockItem(id: 'stock-pepsi', name: 'بيبسي', deductsOnSale: true, onHand: 24, lowStockAt: 6),
  StockItem(id: 'stock-chips', name: 'شيبسي', deductsOnSale: true, onHand: 8, lowStockAt: 10),
  StockItem(id: 'stock-tea', name: 'شاي', deductsOnSale: false, onHand: 3, lowStockAt: 1),
  StockItem(id: 'stock-coffee', name: 'قهوة', deductsOnSale: false, onHand: 4, lowStockAt: 2),
  StockItem(id: 'stock-water', name: 'مياه', deductsOnSale: true, onHand: 40, lowStockAt: 12),
  StockItem(id: 'stock-juice', name: 'عصير', deductsOnSale: true, onHand: 18, lowStockAt: 6),
  StockItem(id: 'stock-indomie', name: 'اندومي', deductsOnSale: true, onHand: 25, lowStockAt: 8),
  StockItem(id: 'stock-biscuit', name: 'بسكوت', deductsOnSale: true, onHand: 20, lowStockAt: 8),
  // Used but not sold: no product draws from these.
  StockItem(id: 'stock-sugar', name: 'سكر', deductsOnSale: false, onHand: 6, lowStockAt: 2),
  StockItem(id: 'stock-milk', name: 'لبن', deductsOnSale: false, onHand: 12, lowStockAt: 4),
];
