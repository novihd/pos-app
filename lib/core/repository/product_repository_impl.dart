import 'dart:developer';

import '../../features/product/model/product_model.dart';
import '../db/db_interface.dart';
import '../services/api_service_interface.dart';
import 'product_repository_interface.dart';

class ProductRepositoryImpl implements ProductRepository {
  final DbService _localDb;
  final ApiService _api;

  ProductRepositoryImpl(this._localDb, this._api);

  @override
  Future<List<ProductModel>> getProducts() async {
    return await _localDb.getProducts();
  }

  @override
  Future<void> addProduct(ProductModel product, {required bool isOnline}) async {
    bool synced = false;
    if (isOnline) {
      try {
        synced = await _api.postProduct(product);
      } catch (_) { 
        synced = false; 
      }
    }
    await _localDb.insertProduct(product.copyWith(isSynced: synced));
  }

  @override
  Future<bool> syncProducts() async {
    final localProducts = await _localDb.getProducts();
    bool allSuccess = true;

    try {
      final serverProducts = await _api.getAllProducts();
      final serverIds = serverProducts.map((e) => e.productId).toSet();
      final localIds = localProducts.map((e) => e.productId).toSet();

      for (final p in localProducts) {
        if (!serverIds.contains(p.productId)) {
          final ok = await _api.postProduct(p);
          if (ok) {
            await _localDb.updateProductSyncStatus(p.productId, true);
          } else {
            allSuccess = false;
          }
        } else {
          final ok = await _api.updateProduct(p.productId, p);
          if (!ok) {
            allSuccess = false;
          }
        }
      }

      for (final s in serverProducts) {
        if (!localIds.contains(s.productId)) {
          final ok = await _api.deleteProduct(s.productId);
          if (!ok) {
            allSuccess = false;
          }
        }
      }

    } catch (e) {
      log('Error syncing products: $e');
      allSuccess = false;
    }

    return allSuccess;
  }

  @override
  Future<bool> syncSingleProduct(String id) async {
    try {
      final product = await _localDb.getProductById(id);

      if (product != null && !product.isSynced) {
        final success = await _api.postProduct(product);

        if (success) {
          await _localDb.updateProductSyncStatus(product.productId, true);
        }

        return success;
      }

      return false;
    } catch (e) {
      log('syncSingleProduct error: $e');
      return false;
    }
  }

  @override
  Future<void> deleteProduct(String id) async {
    await _localDb.deleteProduct(id).then((val) => _api.deleteProduct(id));
  }
}