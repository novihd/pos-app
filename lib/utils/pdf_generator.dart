import 'dart:typed_data';
import 'package:intl/intl.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../features/transaction/model/transaction_model.dart';

class PdfGenerator {
  static Future<void> shareInvoice(TransactionModel t) async {
    final doc = pw.Document();
    final currency = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ');
    doc.addPage(pw.Page(
        build: (_) => pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text('INVOICE',
                      style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
                  pw.SizedBox(height: 8),
                  pw.Text(
                      'Tanggal: ${DateFormat('dd MMM yyyy, HH:mm').format(DateTime.now())}'),
                  pw.SizedBox(height: 12),
                  pw.Text('Produk: ${t.productName}'),
                  pw.Text('Qty: ${t.quantity}'),
                  pw.Text('Harga: ${currency.format(t.price)}'),
                  pw.SizedBox(height: 12),
                  pw.Text('Total: ${currency.format(t.total)}',
                      style: pw.TextStyle(
                          fontSize: 16, fontWeight: pw.FontWeight.bold)),
                ])));
    final bytes = await doc.save();
    await Printing.sharePdf(
        bytes: bytes,
        filename: 'invoice_${DateTime.now().millisecondsSinceEpoch}.pdf');
  }

  static Future<Uint8List> buildSimpleReport(
      List<TransactionModel> list) async {
    final doc = pw.Document();
    final currency = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ');
    final total = list.fold<double>(0, (s, t) => s + t.total);
    doc.addPage(pw.Page(
        build: (_) => pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text('Laporan Penjualan',
                      style: pw.TextStyle(
                          fontSize: 20, fontWeight: pw.FontWeight.bold)),
                  pw.Text(
                      'Generated: ${DateFormat('dd MMM yyyy, HH:mm').format(DateTime.now())}'),
                  pw.SizedBox(height: 12),
                  pw.TableHelper.fromTextArray(
                      headers: ['Produk', 'Qty', 'Harga', 'Subtotal'],
                      data: list
                          .map((t) => [
                                t.productName,
                                t.quantity.toString(),
                                currency.format(t.price),
                                currency.format(t.total)
                              ])
                          .toList()),
                  pw.SizedBox(height: 12),
                  pw.Align(
                      alignment: pw.Alignment.centerRight,
                      child: pw.Text('Grand Total: ${currency.format(total)}',
                          style: pw.TextStyle(
                              fontSize: 16, fontWeight: pw.FontWeight.bold)))
                ])));
    return doc.save();
  }

  static Future<void> shareReport(Uint8List bytes) async {
    await Printing.sharePdf(
        bytes: bytes,
        filename: 'report_${DateTime.now().millisecondsSinceEpoch}.pdf');
  }
}
