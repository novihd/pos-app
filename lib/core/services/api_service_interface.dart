import '../../features/product/model/product_model.dart';
import '../../features/transaction/model/transaction_model.dart';

abstract class ApiService {
  Future<bool> postProduct(ProductModel product);
  Future<List<ProductModel>> getAllProducts();
  Future<bool> updateProduct(String id, ProductModel product);
  Future<bool> deleteProduct(String id);

  Future<bool> postTransaction(TransactionModel transaction);
  Future<List<TransactionModel>> getAllTransactions();
  Future<bool> updateTransaction(String transactionId, TransactionModel transaction);
  Future<bool> deleteTransaction(String transactionId);
}
