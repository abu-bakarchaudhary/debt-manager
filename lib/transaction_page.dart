import 'package:flutter/material.dart';

class TransactionPage extends StatefulWidget {
  final Map<String, dynamic> person;
  const TransactionPage({super.key, required this.person});

  @override
  State<TransactionPage> createState() => _TransactionPageState();
}

class _TransactionPageState extends State<TransactionPage> {
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _purposeController = TextEditingController();

  void _addTransaction(bool isReceiving) {
    double amt = double.tryParse(_amountController.text) ?? 0;
    if (amt > 0) {
      // Get the current time and format it
      DateTime now = DateTime.now();
      String formattedDate =
          "${now.day}/${now.month} ${now.hour}:${now.minute}";

      setState(() {
        widget.person['transactions'].add({
          "amount": isReceiving ? amt : -amt,
          "purpose": _purposeController.text,
          "date": formattedDate, // <--- New Field
        });
      });
      _amountController.clear();
      _purposeController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    List txs = widget.person['transactions'];

    return Scaffold(
      appBar: AppBar(title: Text("${widget.person['name']}'s Ledger")),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                TextField(
                  controller: _amountController,
                  decoration: const InputDecoration(labelText: "Amount"),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: _purposeController,
                  decoration: const InputDecoration(labelText: "Purpose"),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: () => _addTransaction(false),
                      child: const Text(
                        "I Owe Them",
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () => _addTransaction(true),
                      child: const Text(
                        "They Owe Me",
                        style: TextStyle(color: Colors.green),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Divider(),
          Expanded(
            child: ListView.builder(
              itemCount: txs.length,
              itemBuilder: (context, index) => ListTile(
                title: Text(txs[index]['purpose']),
                subtitle: Text(
                  txs[index]['amount'] > 0 ? "Owed to me" : "I owe",
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "${txs[index]['amount']}",
                      style: TextStyle(
                        color: txs[index]['amount'] > 0
                            ? Colors.green
                            : Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline, size: 20),
                      onPressed: () {
                        setState(() {
                          txs.removeAt(index);
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
