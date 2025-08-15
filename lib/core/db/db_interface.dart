import '../../features/product/model/product_model.dart';
import '../../features/transaction/model/transaction_model.dart';

abstract class DbService {
  //Product
  Future<void> insertProduct(ProductModel product);
  Future<List<ProductModel>> getProducts();
  Future<ProductModel?> getProductById(String productId);
  Future<bool> updateProductSyncStatus(String id, bool isSynced);
  Future<void> deleteProduct(String id);

  // Transaction
  Future<void> insertTransaction(TransactionModel transaction);
  Future<List<TransactionModel>> getTransactions();
  Future<TransactionModel?> getTransactionById(String transactionId);
  Future<bool> updateTransactionSyncStatus(String id, bool isSynced);
  Future<void> deleteTransaction(String id);
}
