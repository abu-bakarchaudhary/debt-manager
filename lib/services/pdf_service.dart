import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';

class PdfService {
  // Feature A: Export Single Person's Ledger History
  static Future<File> generateSingleLedgerPdf(Map<String, dynamic> person) async {
    final pdf = pw.Document();
    final transactions = person['transactions'] as List<dynamic>? ?? [];

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text("Financial Statement", style: pw.TextStyle(fontSize: 26, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 8),
              pw.Text("Account Holder: ${person['name']}", style: pw.TextStyle(fontSize: 16)),
              pw.Divider(),
              pw.SizedBox(height: 15),
              
              // Structured Data Table
              pw.TableHelper.fromTextArray(
                headers: ['Date/Time', 'Purpose', 'Flow Direction', 'Amount (PKR)'],
                data: transactions.map((tx) {
                  double amt = (tx['amount'] as num).toDouble();
                  return [
                    tx['date'] ?? 'N/A',
                    tx['purpose'] ?? 'General',
                    amt > 0 ? 'Receivable (They Owe)' : 'Payable (I Owe)',
                    amt.abs().toStringAsFixed(2),
                  ];
                }).toList(),
                headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                cellAlignment: pw.Alignment.centerLeft,
              ),
            ],
          );
        },
      ),
    );

    // Save file to system cache or documents directory securely
    final output = await getTemporaryDirectory();
    final safeName = (person['name'] ?? 'ledger').toString().replaceAll(RegExp(r"[^0-9A-Za-z_.-]"), '_');
    final file = File("${output.path}/${safeName}_ledger.pdf");
    return await file.writeAsBytes(await pdf.save());
  }

  // Feature B: Export Full App Data Audit Report
  static Future<File> generateMasterSummaryPdf(List<dynamic> allPeople) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text("Student Debt Manager Master Audit", style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 5),
              pw.Text("Generated on: ${DateTime.now().toLocal()}"),
              pw.Divider(),
              pw.SizedBox(height: 20),
              
              pw.TableHelper.fromTextArray(
                headers: ['Person Name', 'Net Balance (PKR)', 'Status'],
                data: allPeople.map((p) {
                  double total = 0;
                  if (p['transactions'] != null) {
                    for (var t in p['transactions']) {
                      total += (t['amount'] as num).toDouble();
                    }
                  }
                  return [
                    p['name'] ?? 'Unknown',
                    total.toStringAsFixed(2),
                    total >= 0 ? 'Clear / Creditor' : 'In Debt',
                  ];
                }).toList(),
                headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                cellAlignment: pw.Alignment.centerLeft,
              ),
            ],
          );
        },
      ),
    );

    final output = await getTemporaryDirectory();
    final file = File("${output.path}/Master_Financial_Summary.pdf");
    return await file.writeAsBytes(await pdf.save());
  }
}