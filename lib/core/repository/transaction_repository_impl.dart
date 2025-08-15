import 'dart:developer';

import '../../features/transaction/model/transaction_model.dart';
import '../db/db_interface.dart';
import '../services/api_service_interface.dart';
import 'transaction_repository_interface.dart';

class TransactionRepositoryImpl implements TransactionRepository {
  final DbService _localDb;
  final ApiService _api;

  TransactionRepositoryImpl(this._localDb, this._api);

  @override
  Future<List<TransactionModel>> getTransactions() async {
    return await _localDb.getTransactions();
  }

  @override
  Future<void> addTransaction(TransactionModel transaction, {required bool isOnline}) async {
    bool synced = false;
    if (isOnline) {
      try {
        synced = await _api.postTransaction(transaction);
      } catch (_) { 
        synced = false; 
      }
    }
    await _localDb.insertTransaction(transaction.copyWith(isSynced: synced));
  }

  @override
  Future<bool> syncTransactions() async {
    final localTransactions = await _localDb.getTransactions();
    bool allSuccess = true;

    try {
      final serverTransactions = await _api.getAllTransactions();
      final serverIds = serverTransactions.map((e) => e.transactionId).toSet();
      final localIds = localTransactions.map((e) => e.transactionId).toSet();

      for (final t in localTransactions) {
        if (!serverIds.contains(t.transactionId)) {
          final ok = await _api.postTransaction(t);
          if (ok) {
            await _localDb.updateTransactionSyncStatus(t.transactionId, true);
          } else {
            allSuccess = false;
          }
        } else {
          final ok = await _api.updateTransaction(t.transactionId, t);
          if (!ok) {
            allSuccess = false;
          }
        }
      }

      for (final s in serverTransactions) {
        if (!localIds.contains(s.transactionId)) {
          final ok = await _api.deleteTransaction(s.transactionId);
          if (!ok) {
            allSuccess = false;
          }
        }
      }

    } catch (e) {
      log('Error syncing transactions: $e');
      allSuccess = false;
    }

    return allSuccess;
  }

  @override
  Future<bool> syncSingleTransaction(String id) async {
    try {
      final transactions = await _localDb.getTransactions();
      final transaction = transactions.where((e) => e.transactionId == id).firstOrNull;
      if (transaction != null && !transaction.isSynced) {
        final success = await _api.postTransaction(transaction);

        if (success) {
          await _localDb.updateTransactionSyncStatus(transaction.transactionId, true);
        }

        return success;
      }

      return false;
    } catch (e) {
      log('syncSingleTransaction error: $e');
      return false;
    }
  }

  @override
  Future<void> deleteTransaction(String id) async {
    await _localDb.deleteTransaction(id).then((val) => _api.deleteTransaction(id));
  }
}
