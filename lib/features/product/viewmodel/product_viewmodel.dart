import 'dart:developer';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../../../core/repository/product_repository_interface.dart';
import '../model/product_model.dart';

class ProductViewModel extends ChangeNotifier {
  final ProductRepository _repo;
  List<ProductModel> products = [];
  bool isLoading = false;
  bool isSyncing = false;
  
  Future<bool>? _syncOperation;
  
  ProductViewModel(this._repo);

  Future<void> loadProducts() async {
    try {
      isLoading = true;
      notifyListeners();
      products = await _repo.getProducts();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addProduct(String name, double price,
      {required bool isOnline}) async {
    await _repo.addProduct(
        ProductModel(
            productId: const Uuid().v4(),
            name: name,
            price: price),
        isOnline: isOnline);
    products = await _repo.getProducts();
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

  Future<bool> syncProduct(String id) async {
    try {
      isSyncing = true;
      notifyListeners();

      bool success = await _repo.syncSingleProduct(id);

      if (success) {
        products = await _repo.getProducts();
      }
      return success;
    } catch (e) {
      log('Sync single product error: $e');
      return false;
    } finally {
      isSyncing = false;
      notifyListeners();
    }
  }

  Future<bool> _performSync() async {
    try {
      bool isSync = await _repo.syncProducts();

      products = await _repo.getProducts();
      
      return isSync;
    } catch (e) {
      log('Sync error: $e');
      return false;
    }
  }

  Future<void> deleteProduct(String id) async {
    await _repo.deleteProduct(id);
    products = await _repo.getProducts();
    notifyListeners();
  }
}