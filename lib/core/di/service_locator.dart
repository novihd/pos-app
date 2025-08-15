import 'package:get_it/get_it.dart';
import '../db/db_interface.dart';
import '../db/db_impl.dart';
import '../services/api_service_interface.dart';
import '../services/api_service_impl.dart';
import '../repository/product_repository_interface.dart';
import '../repository/product_repository_impl.dart';
import '../repository/transaction_repository_interface.dart';
import '../repository/transaction_repository_impl.dart';
import '../../features/product/viewmodel/product_viewmodel.dart';
import '../../features/transaction/viewmodel/transaction_viewmodel.dart';

final locator = GetIt.instance;

Future<void> init() async {
  locator.registerLazySingleton<DbService>(() => DbServiceImpl());
  locator.registerLazySingleton<ApiService>(() => ApiServiceImpl(baseUrl: 'https://66b713fe7f7b1c6d8f1ad842.mockapi.io/api/v1'));
  locator.registerLazySingleton<ProductRepository>(() => ProductRepositoryImpl(locator<DbService>(), locator<ApiService>()));
  locator.registerLazySingleton<TransactionRepository>(() => TransactionRepositoryImpl(locator<DbService>(), locator<ApiService>()));
  locator.registerFactory<ProductViewModel>(() => ProductViewModel(locator<ProductRepository>()));
  locator.registerFactory<TransactionViewModel>(() => TransactionViewModel(locator<TransactionRepository>()));
}
