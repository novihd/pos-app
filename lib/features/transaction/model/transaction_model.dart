class TransactionModel {
  final int? id;
  final String transactionId;
  final String? productId;
  final String productName;
  final int quantity;
  final double price;
  final bool isSynced;
  const TransactionModel(
      {this.id,
      required this.transactionId,
      this.productId,
      required this.productName,
      required this.quantity,
      required this.price,
      this.isSynced = false});

  double get total => quantity * price;

  TransactionModel copyWith(
          {int? id,
          String? transactionId,
          String? productId,
          String? productName,
          int? quantity,
          double? price,
          bool? isSynced}) =>
      TransactionModel(
          id: id ?? this.id,
          transactionId: transactionId ?? this.transactionId,
          productId: productId ?? this.productId,
          productName: productName ?? this.productName,
          quantity: quantity ?? this.quantity,
          price: price ?? this.price,
          isSynced: isSynced ?? this.isSynced);

  Map<String, dynamic> toMap() => {
        'id': id,
        'transactionId': transactionId,
        'productId': productId,
        'productName': productName,
        'quantity': quantity,
        'price': price,
        'isSynced': isSynced ? 1 : 0
      };

  factory TransactionModel.fromMap(Map<String, dynamic> m) => TransactionModel(
      id: _parseId(m['id']),
      transactionId: m['transactionId'] ?? '',
      productId: m['productId'] as String?,
      productName: m['productName'] as String,
      quantity: m['quantity'] as int,
      price: (m['price'] as num).toDouble(),
      isSynced: (m['isSynced'] as int) == 1);
  
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
