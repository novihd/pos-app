import 'dart:developer';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../../../core/repository/transaction_repository_interface.dart';
import '../model/transaction_model.dart';

class TransactionViewModel extends ChangeNotifier {
  final TransactionRepository _repo;
  List<TransactionModel> transactions = [];
  bool isLoading = false;
  bool isSyncing = false;

  Future<bool>? _syncOperation;

  TransactionViewModel(this._repo);

  Future<void> loadTransactions() async {
    try {
      isLoading = true;
      notifyListeners();
      transactions = await _repo.getTransactions();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addTransaction({
    String? productId,
    required String productName,
    required int quantity,
    required double price,
    required bool isOnline,
  }) async {
    final newTransaction = TransactionModel(
      transactionId: const Uuid().v4(),
      productId: productId,
      productName: productName,
      quantity: quantity,
      price: price,
    );

    await _repo.addTransaction(newTransaction, isOnline: isOnline);
    transactions = await _repo.getTransactions();
    notifyListeners();
  }

  Future<bool> syncAll() async {
    if (_syncOperation != null) {
      return await _syncOperation!;
    }

    isSyncing = true;
    notifyListeners();

    _syncOperation = _performSync();

    try {
      final result = await _syncOperation!;
      return result;
    } finally {
      _syncOperation = null;
      isSyncing = false;
      notifyListeners();
    }
  }

  Future<bool> syncTransaction(String transactionId) async {
    try {
      isSyncing = true;
      notifyListeners();

      bool success = await _repo.syncSingleTransaction(transactionId);

      if (success) {
        transactions = await _repo.getTransactions();
      }
      return success;
    } catch (e) {
      log('Sync single transaction $transactionId error: $e');
      return false;
    } finally {
      isSyncing = false;
      notifyListeners();
    }
  }

  Future<bool> _performSync() async {
    try {
      bool isSync = await _repo.syncTransactions();
      transactions = await _repo.getTransactions();
      return isSync;
    } catch (e) {
      log('Sync error: $e');
      return false;
    }
  }

  Future<void> deleteTransaction(String id) async {
    await _repo.deleteTransaction(id);
    transactions = await _repo.getTransactions();
    notifyListeners();
  }
}
