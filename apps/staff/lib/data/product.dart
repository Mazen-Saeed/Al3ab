/// Something the shop sells at the counter (drink, snack). Price in whole EGP.
/// Later it comes from the products table.
class Product {
  const Product({required this.id, required this.name, required this.price, this.stockItemId});

  final String id;
  final String name;
  final int price;

  /// The stock item this product draws from. Null = not tracked.
  final String? stockItemId;

  Product copyWith({String? name, int? price}) =>
      Product(id: id, name: name ?? this.name, price: price ?? this.price, stockItemId: stockItemId);

  /// Same product, linked to another stock item (null = not tracked).
  Product withStockItem(String? stockItemId) =>
      Product(id: id, name: name, price: price, stockItemId: stockItemId);
}

/// One line on a session's bill: "Pepsi, 2 × 15".
/// It copies the name and price at the moment of ordering (like an invoice line),
/// so changing a product's price later never changes bills that already exist.
class OrderLine {
  const OrderLine({required this.productId, required this.name, required this.unitPrice, required this.quantity});

  final String productId;
  final String name;
  final int unitPrice;
  final int quantity;

  int get total => unitPrice * quantity;

  OrderLine withQuantity(int quantity) =>
      OrderLine(productId: productId, name: name, unitPrice: unitPrice, quantity: quantity);
}
