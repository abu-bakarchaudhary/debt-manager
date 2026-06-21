import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:open_filex/open_filex.dart';

import 'services/pdf_service.dart';

class TransactionPage extends StatefulWidget {
  final Map<String, dynamic> person;
  final List<dynamic> fullPeopleList;

  const TransactionPage({super.key, required this.person, required this.fullPeopleList});

  @override
  State<TransactionPage> createState() => _TransactionPageState();
}

class _TransactionPageState extends State<TransactionPage> {
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _purposeController = TextEditingController();

  List<dynamic> get transactions {
    final tx = widget.person['transactions'];
    return tx is List<dynamic> ? tx : [];
  }

  Future<void> _saveAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('debt_data', jsonEncode(widget.fullPeopleList));
  }

  Future<void> _addTransaction(bool positive) async {
    final text = _amountController.text.trim();
    if (text.isEmpty) return;
    final amt = double.tryParse(text);
    if (amt == null) return;

    setState(() {
      transactions.add({
        'amount': positive ? amt : -amt,
        'purpose': _purposeController.text.trim(),
        'date': DateTime.now().toString(),
      });
    });
    _amountController.clear();
    _purposeController.clear();
    await _saveAll();
    if (!mounted) return;
    Navigator.of(context).pop();
  }

  double userProbability() {
    if (transactions.isEmpty) return 0.0;
    int total = 0, negative = 0;
    for (var t in transactions) {
      total++;
      final amt = t['amount'];
      if (amt is num && amt < 0) negative++;
    }
    return negative / total;
  }

  void _showAddDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Transaction'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _amountController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(hintText: 'Amount (numeric)'),
            ),
            TextField(
              controller: _purposeController,
              decoration: const InputDecoration(hintText: 'Purpose (optional)'),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
          TextButton(onPressed: () => _addTransaction(false), child: const Text('I own')),
          ElevatedButton(onPressed: () => _addTransaction(true), child: const Text('They Paid')),
        ],
      ),
    );
  }

  Future<void> _exportPdf() async {
    final scaffold = ScaffoldMessenger.of(context);
    try {
      final file = await PdfService.generateSingleLedgerPdf(widget.person);
      if (!mounted) return;
      await OpenFilex.open(file.path);
    } catch (e) {
      if (!mounted) return;
      scaffold.showSnackBar(SnackBar(content: Text('PDF export failed: $e')));
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _purposeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double total = 0;
    for (var t in transactions) {
      final amt = t['amount'];
      if (amt is num) total += amt.toDouble();
    }

    final prob = userProbability();

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(widget.person['name'] ?? 'Ledger'),
            Text('${(prob * 100).toStringAsFixed(1)}% chance next is a payment', style: const TextStyle(fontSize: 12)),
          ],
        ),
        actions: [
          Center(child: Padding(padding: const EdgeInsets.symmetric(horizontal: 8.0), child: Text('${total.toStringAsFixed(2)} PKR'))),
          IconButton(
            onPressed: _exportPdf,
            icon: const Icon(Icons.picture_as_pdf_rounded),
            tooltip: 'Export this ledger as PDF',
          ),
        ],
      ),
      body: transactions.isEmpty
          ? const Center(child: Text('No transactions yet.'))
          : ListView.builder(
              itemCount: transactions.length,
              itemBuilder: (context, index) {
                final tx = transactions[index];
                final amt = tx['amount'] is num ? (tx['amount'] as num).toDouble() : 0.0;
                return Dismissible(
                  key: ValueKey('${widget.person['name']}-txn-$index'),
                  direction: DismissDirection.endToStart,
                  confirmDismiss: (dir) async {
                    return await showDialog(
                      context: context,
                      builder: (c) => AlertDialog(
                        title: const Text('Confirm'),
                        content: const Text('Delete this transaction?'),
                        actions: [
                          TextButton(onPressed: () => Navigator.of(c).pop(false), child: const Text('Cancel')),
                          TextButton(onPressed: () => Navigator.of(c).pop(true), child: const Text('Delete', style: TextStyle(color: Colors.red))),
                        ],
                      ),
                    );
                  },
                  onDismissed: (d) async {
                    final messenger = ScaffoldMessenger.of(context);
                    setState(() {
                      transactions.removeAt(index);
                    });
                    await _saveAll();
                    if (!mounted) return;
                    messenger.showSnackBar(const SnackBar(content: Text('Transaction removed')));
                  },
                  background: Container(
                    color: Colors.red.shade400,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  child: ListTile(
                    title: Text(tx['purpose'] ?? 'Transaction'),
                    subtitle: Text(tx['date'] ?? ''),
                    trailing: Text(
                      '${amt.abs().toStringAsFixed(2)} PKR',
                      style: TextStyle(color: amt >= 0 ? Colors.green : Colors.red),
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}
