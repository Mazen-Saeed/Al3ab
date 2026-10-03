/// Something the shop sells at the counter (drink, snack). Prices are piasters
/// (1500 = 15 EGP), see money.dart. Later it comes from the products table.
class Product {
  const Product({required this.id, required this.name, required this.price, this.costPrice, this.stockItemId});

  final String id;
  final String name;
  final int price;

  /// What one costs the shop (piasters). Optional: null = not entered. Reports use it for true profit.
  final int? costPrice;

  /// The stock item this product draws from. Null = not tracked.
  final String? stockItemId;

  /// Same product with new name, price and cost price. [costPrice] null clears it.
  Product withDetails({required String name, required int price, int? costPrice}) =>
      Product(id: id, name: name, price: price, costPrice: costPrice, stockItemId: stockItemId);

  /// Same product, linked to another stock item (null = not tracked).
  Product withStockItem(String? stockItemId) =>
      Product(id: id, name: name, price: price, costPrice: costPrice, stockItemId: stockItemId);
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
