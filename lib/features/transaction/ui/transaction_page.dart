import 'package:flutter/material.dart';
import 'package:pos_app/utils/ui_helper.dart';
import 'package:provider/provider.dart';
import '../viewmodel/transaction_viewmodel.dart';
import '../../../utils/connectivity_helper.dart';
import '../../../utils/pdf_generator.dart';
import 'transaction_form_page.dart';

class TransactionPage extends StatelessWidget {
  const TransactionPage({super.key});
  @override
  Widget build(BuildContext context) {
    final vm = context.watch<TransactionViewModel>();
    return Scaffold(
      appBar: AppBar(title: const Text('Transaksi'), actions: [
        IconButton(
            onPressed: () async {
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
                    ? 'Sinkronisasi transaksi selesai'
                    : 'Sinkronisasi transaksi gagal', 
                  color: success 
                    ? Colors.green
                    : Colors.red);
              }
            },
            icon: vm.isSyncing 
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.sync)),
        IconButton(
            onPressed: () async {
              final bytes =
                  await PdfGenerator.buildSimpleReport(vm.transactions);
              await PdfGenerator.shareReport(bytes);
            },
            icon: const Icon(Icons.picture_as_pdf)),
      ]),
      floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            Navigator.push(context,
                MaterialPageRoute(builder: (_) => const TransactionFormPage()));
          },
          label: const Text('Tambah Transaksi'),
          icon: const Icon(Icons.add)),
      body: vm.isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(12),
              child: vm.transactions.isEmpty
                  ? const Center(child: Text('Belum ada transaksi'))
                  : ListView.separated(
                      itemBuilder: (c, i) {
                        final t = vm.transactions[i];
                        return ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: Padding(
                            padding: const EdgeInsets.only(left: 16),
                            child: Icon(
                                t.isSynced ? Icons.cloud_done : Icons.cloud_off,
                                color: t.isSynced ? Colors.green : Colors.red),
                          ),
                          title: Text(t.productName,
                              style:
                                  const TextStyle(fontWeight: FontWeight.w600)),
                          subtitle: Text(
                              'Qty: ${t.quantity} • Harga: Rp ${t.price.toStringAsFixed(0)} • Total: Rp ${t.total.toStringAsFixed(0)}'),
                          trailing: PopupMenuButton<String>(
                              onSelected: (v) async {
                                if (v == 'invoice') {
                                  await PdfGenerator.shareInvoice(t);
                                } else if (v == 'delete') {
                                  await vm.deleteTransaction(t.transactionId);
                                } else {
                                  final success = await vm.syncTransaction(t.transactionId);

                                  if (context.mounted) {
                                    UIHelper.showSnackBar(
                                      context: context, 
                                      message: success
                                        ? 'Sinkronisasi transaksi selesai'
                                        : 'Sinkronisasi transaksi gagal', 
                                      color: success 
                                        ? Colors.green
                                        : Colors.red);
                                  }
                                }
                              },
                              itemBuilder: (_) => [
                                const PopupMenuItem(
                                  value: 'invoice',
                                  child: Text('Bagikan Invoice (PDF)')),
                                const PopupMenuItem(
                                  value: 'delete',
                                  child: Text('Hapus'),
                                ),
                                if (!t.isSynced)
                                  const PopupMenuItem(
                                    value: 'sync',
                                    child: Text('Sync'),
                                  ),
                              ]),
                        );
                      },
                      separatorBuilder: (_, __) => const Divider(),
                      itemCount: vm.transactions.length)),
    );
  }
}
