import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/di/service_locator.dart' as di;
import 'features/product/viewmodel/product_viewmodel.dart';
import 'features/transaction/viewmodel/transaction_viewmodel.dart';
import 'features/home/home_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await di.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => di.locator<ProductViewModel>()..loadProducts()),
        ChangeNotifierProvider(create: (_) => di.locator<TransactionViewModel>()..loadTransactions()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'POS Offline',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
          textTheme: Theme.of(context).textTheme.apply(bodyColor: Colors.black87),
        ),
        home: const HomePage(),
      ),
    );
  }
}
