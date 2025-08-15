class ProductModel {
  final int? id;
  final String productId;
  final String name;
  final double price;
  final bool isSynced;
  const ProductModel(
      {this.id,
      required this.productId,
      required this.name,
      required this.price,
      this.isSynced = false});

  ProductModel copyWith(
          {int? id,
          String? productId,
          String? name,
          double? price,
          bool? isSynced}) =>
      ProductModel(
          id: id ?? this.id,
          productId: productId ?? this.productId,
          name: name ?? this.name,
          price: price ?? this.price,
          isSynced: isSynced ?? this.isSynced);

  Map<String, dynamic> toMap() => {
        'id': id,
        'productId': productId,
        'name': name,
        'price': price,
        'isSynced': isSynced ? 1 : 0
      };

  factory ProductModel.fromMap(Map<String, dynamic> m) => ProductModel(
      id: _parseId(m['id']),
      productId: m['productId'] as String,
      name: m['name'] as String,
      price: (m['price'] as num).toDouble(),
      isSynced: (m['isSynced'] ?? 0) == 1);

  static int? _parseId(dynamic id) {
    if (id == null) return null;
    if (id is int) return id;
    if (id is String) {
      try {
        return int.parse(id);
      } catch (e) {
        return null;
      }
    }
    return null;
  }
}
