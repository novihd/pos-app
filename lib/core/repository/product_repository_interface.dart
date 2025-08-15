import '../../features/product/model/product_model.dart';
abstract class ProductRepository {
  Future<List<ProductModel>> getProducts();
  Future<void> addProduct(ProductModel product, {required bool isOnline});
  Future<bool> syncProducts();
  Future<void> deleteProduct(String id);
  Future<bool> syncSingleProduct(String id);
}
