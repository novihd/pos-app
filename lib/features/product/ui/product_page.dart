import 'package:flutter/material.dart';
import 'package:pos_app/utils/ui_helper.dart';
import 'package:provider/provider.dart';
import '../viewmodel/product_viewmodel.dart';
import '../../../utils/connectivity_helper.dart';

class ProductPage extends StatelessWidget {
  const ProductPage({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ProductViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Produk'),
        actions: [
          IconButton(
            onPressed: vm.isSyncing ? null : () async {
              final online = await ConnectivityHelper.isOnline();

              if (!online) {
                if (context.mounted) {
                  UIHelper.showSnackBar(context: context, message: 'Tidak ada koneksi', color: Colors.red);
                }
                return;
              }

              final success = await vm.syncAll();

              if (context.mounted) {
                UIHelper.showSnackBar(context: context, 
                  message: success
                    ? 'Sinkronisasi produk selesai'
                    : 'Sinkronisasi produk gagal', 
                  color: success 
                    ? Colors.green
                    : Colors.red);
              }
            },
            icon: vm.isSyncing 
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                    ),
                  )
                : const Icon(Icons.sync),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: vm.isSyncing ? null : () {
          showDialog(
            context: context,
            builder: (_) => const _AddProductDialog(),
          );
        },
        label: const Text('Tambah Produk'),
        icon: const Icon(Icons.add),
      ),
      body: vm.isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(12),
              child: vm.products.isEmpty
                  ? const Center(child: Text('Belum ada produk'))
                  : ListView.separated(
                      itemBuilder: (c, i) {
                        final p = vm.products[i];
                        return ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: Padding(
                            padding: const EdgeInsets.only(left: 16),
                            child: Icon(
                              p.isSynced ? Icons.cloud_done : Icons.cloud_off,
                              color: p.isSynced ? Colors.green : Colors.red,
                            ),
                          ),
                          title: Text(
                            p.name,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          subtitle: Text('Harga: Rp ${p.price.toStringAsFixed(0)}'),
                          trailing: PopupMenuButton<String>(
                            padding: EdgeInsets.zero,
                            onSelected: (v) async {
                              if (v == 'delete') {
                                await vm.deleteProduct(p.productId);
                              } else {
                                final success = await vm.syncProduct(p.productId);

                                if (context.mounted) {
                                  UIHelper.showSnackBar(
                                    context: context, 
                                    message: success
                                      ? 'Sinkronisasi produk ${p.name} selesai'
                                      : 'Sinkronisasi produk ${p.name} gagal', 
                                    color: success 
                                      ? Colors.green
                                      : Colors.red);
                                }
                              }
                            },
                            itemBuilder: (_) => [
                              if (!p.isSynced)
                              const PopupMenuItem(
                                  value: 'sync',
                                  child: Text('Sync'),
                                ),
                              const PopupMenuItem(
                                value: 'delete',
                                child: Text('Hapus'),
                              ),
                            ],
                          ),
                        );
                      },
                      separatorBuilder: (_, __) => const Divider(),
                      itemCount: vm.products.length,
                    ),
            ),
    );
  }
}
class _AddProductDialog extends StatefulWidget {
  const _AddProductDialog();
  @override
  State<_AddProductDialog> createState() => _AddProductDialogState();
}

class _AddProductDialogState extends State<_AddProductDialog> {
  final _form = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _price = TextEditingController();
  bool _loading = false;
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
        title: const Text('Tambah Produk'),
        content: Form(
            key: _form,
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              TextFormField(
                  controller: _name,
                  decoration: const InputDecoration(labelText: 'Nama'),
                  validator: (v) => v == null || v.isEmpty ? 'Wajib' : null),
              TextFormField(
                  controller: _price,
                  decoration: const InputDecoration(labelText: 'Harga'),
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  validator: (v) =>
                      double.tryParse(v ?? '') == null ? 'Tidak valid' : null),
            ])),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal')),
          FilledButton(
              onPressed: _loading
                  ? null
                  : () async {
                      if (!_form.currentState!.validate()) return;
                      setState(() => _loading = true);
                      final vm = context.read<ProductViewModel>();
                      final online = await ConnectivityHelper.isOnline();
                      await vm.addProduct(
                          _name.text.trim(), double.parse(_price.text),
                          isOnline: online);
                      setState(() => _loading = false);
                      if (context.mounted) Navigator.pop(context);
                    },
              child: _loading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2))
                  : const Text('Simpan'))
        ]);
  }
}
