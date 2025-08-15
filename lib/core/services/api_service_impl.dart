import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import '../../features/product/model/product_model.dart';
import '../../features/transaction/model/transaction_model.dart';
import 'api_service_interface.dart';

class ApiServiceImpl implements ApiService {
  final String baseUrl;
  ApiServiceImpl({required this.baseUrl});

  @override
  Future<bool> postProduct(ProductModel product) async {
    final res = await http.post(Uri.parse('$baseUrl/products'),
      headers: {'Content-Type':'application/json'},
      body: jsonEncode({'productId': product.productId, 'name': product.name, 'price': product.price}));
    return res.statusCode == 201 || res.statusCode == 200;
  }

  @override
  Future<List<ProductModel>> getAllProducts() async {
    try {
      final res = await http.get(
        Uri.parse('$baseUrl/products'),
        headers: {'Content-Type': 'application/json'},
      );

      if (res.statusCode == 200) {
        final List<dynamic> data = jsonDecode(res.body);
        return data.map((e) {
          return ProductModel.fromMap(e);
        }).toList();
      } else {
        return [];
      }
    } catch (e) {
      log('Error fetching products from API: $e');
      return [];
    }
  }

  @override
  Future<bool> updateProduct(String productId, ProductModel product) async {
    final serverId = await _getServerIdByProductId(productId);
    if (serverId == null) return false;

    final res = await http.put(
      Uri.parse('$baseUrl/products/$serverId'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'productId': product.productId,
        'name': product.name,
        'price': product.price,
      }),
    );
    return res.statusCode == 200;
  }

  @override
  Future<bool> deleteProduct(String productId) async {
    final serverId = await _getServerIdByProductId(productId);
    if (serverId == null) return false;

    final res = await http.delete(
      Uri.parse('$baseUrl/products/$serverId'),
      headers: {'Content-Type': 'application/json'},
    );
    return res.statusCode == 200 || res.statusCode == 204;
  }

  @override
  Future<bool> postTransaction(TransactionModel transaction) async {
    final res = await http.post(Uri.parse('$baseUrl/transactions'),
      headers: {'Content-Type':'application/json'},
      body: jsonEncode({
        'productId': transaction.productId,
        'transactionId': transaction.transactionId,
        'productName': transaction.productName,
        'quantity': transaction.quantity,
        'price': transaction.price,
      }));
    return res.statusCode == 201 || res.statusCode == 200;
  }

  @override
  Future<List<TransactionModel>> getAllTransactions() async {
    try {
      final res = await http.get(
        Uri.parse('$baseUrl/transactions'),
        headers: {'Content-Type': 'application/json'},
      );
      if (res.statusCode == 200) {
        final List<dynamic> data = jsonDecode(res.body);
        return data.map((e) => TransactionModel.fromMap(e)).toList();
      }
    } catch (e) {
      log('Error getAllTransactions: $e');
    }
    return [];
  }

  @override
  Future<bool> updateTransaction(String transactionId, TransactionModel t) async {
    final serverId = await _getServerIdByTransactionId(transactionId);
    if (serverId == null) return false;

    final res = await http.put(
      Uri.parse('$baseUrl/transactions/$serverId'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(t.toMap()),
    );
    return res.statusCode == 200;
  }

  @override
  Future<bool> deleteTransaction(String transactionId) async {
    final serverId = await _getServerIdByTransactionId(transactionId);
    if (serverId == null) return false;

    final res = await http.delete(
      Uri.parse('$baseUrl/transactions/$serverId'),
      headers: {'Content-Type': 'application/json'},
    );
    return res.statusCode == 200 || res.statusCode == 204;
  }

  Future<String?> _getServerIdByProductId(String productId) async {
    try {
      final res = await http.get(
        Uri.parse('$baseUrl/products?productId=$productId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (res.statusCode == 200) {
        final List<dynamic> data = jsonDecode(res.body);
        if (data.isNotEmpty) {
          return data.first['id'];
        }
      }
      return null;
    } catch (e) {
      log('Error getting serverId for productId=$productId: $e');
      return null;
    }
  }

  Future<String?> _getServerIdByTransactionId(String transactionId) async {
    try {
      final res = await http.get(
        Uri.parse('$baseUrl/transactions?transactionId=$transactionId'),
        headers: {'Content-Type': 'application/json'},
      );
      if (res.statusCode == 200) {
        final List<dynamic> data = jsonDecode(res.body);
        if (data.isNotEmpty) return data.first['id'];
      }
      return null;
    } catch (e) {
      log('Error getting serverId for transactionId=$transactionId: $e');
      return null;
    }
  }

    
}
