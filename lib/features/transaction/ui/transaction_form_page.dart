import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../product/viewmodel/product_viewmodel.dart';
import '../viewmodel/transaction_viewmodel.dart';
import '../../../utils/connectivity_helper.dart';

class TransactionFormPage extends StatefulWidget {
  const TransactionFormPage({super.key});
  @override
  State<TransactionFormPage> createState() => _TransactionFormPageState();
}

class _TransactionFormPageState extends State<TransactionFormPage> {
  ProductViewModel? pvm;
  TransactionViewModel? tvm;
  String? _selectedProductId;
  int _qty = 1;
  @override
  Widget build(BuildContext context) {
    pvm = context.watch<ProductViewModel>();
    tvm = context.read<TransactionViewModel>();
    final products = pvm!.products;
    return Scaffold(
        appBar: AppBar(title: const Text('Tambah Transaksi')),
        body: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(children: [
              if (products.isEmpty)
                const Text('Belum ada produk, silakan tambah di tab Produk'),
              if (products.isNotEmpty)
                DropdownButtonFormField<String>(
                    value: _selectedProductId,
                    items: products
                        .map((p) => DropdownMenuItem(
                            value: p.productId,
                            child: Text(
                                '${p.name} - Rp ${p.price.toStringAsFixed(0)}')))
                        .toList(),
                    onChanged: (v) => setState(() => _selectedProductId = v),
                    decoration:
                        const InputDecoration(labelText: 'Pilih Produk')),
              const SizedBox(height: 12),
              TextFormField(
                  initialValue: '1',
                  keyboardType: const TextInputType.numberWithOptions(),
                  decoration: const InputDecoration(labelText: 'Qty'),
                  onChanged: (v) => _qty = int.tryParse(v) ?? 1),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                  onPressed: () async {
                    if (_selectedProductId == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Pilih produk')));
                      return;
                    }
                    final p = products
                        .firstWhere((e) => e.productId == _selectedProductId);
                    final isOnline = await ConnectivityHelper.isOnline();
                    await tvm!.addTransaction(productId: p.productId, productName: p.name, price: p.price, quantity: _qty, isOnline: isOnline);
                    if (context.mounted) Navigator.pop(context);
                  },
                  icon: const Icon(Icons.save),
                  label: const Text('Simpan')),
            ])));
  }
}
