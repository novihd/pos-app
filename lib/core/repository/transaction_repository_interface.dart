import '../../features/transaction/model/transaction_model.dart';
abstract class TransactionRepository {
  Future<List<TransactionModel>> getTransactions();
  Future<void> addTransaction(TransactionModel transaction, {required bool isOnline});
  Future<bool> syncTransactions();
  Future<bool> syncSingleTransaction(String id);
  Future<void> deleteTransaction(String id);
}
