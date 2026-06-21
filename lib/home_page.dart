import 'dart:convert';
import 'package:open_filex/open_filex.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'transaction_page.dart';
import 'statistics_page.dart';
import 'services/pdf_service.dart';
import 'person_graph_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<dynamic> people = [];
  final TextEditingController _nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  // Save the list back to storage
  Future<void> _saveData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('debt_data', jsonEncode(people));
  }

  // Load list from storage
  Future<void> _loadData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? savedData = prefs.getString('debt_data');
      if (savedData != null) {
        final decoded = jsonDecode(savedData);
        if (decoded is List<dynamic>) {
          setState(() {
            people = decoded;
          });
        }
      }
    } catch (_) {}
  }

  Future<void> _addNewPerson() async {
    if (_nameController.text.trim().isNotEmpty) {
      setState(() {
        people.add({
          "name": _nameController.text.trim(), 
          "transactions": []
        });
      });
      _nameController.clear();
      await _saveData();
      if (!mounted) return;
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Student Debt Manager"), 
        centerTitle: true,
        backgroundColor: Colors.blueGrey.shade50,
        leading: IconButton(
          icon: const Icon(Icons.bar_chart_rounded),
          tooltip: 'View Probability Metrics',
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => StatisticsPage(people: people),
              ),
            );
          },
        ),
        actions: [
          // UPGRADE: Added global master PDF statement downloader action
          IconButton(
            icon: const Icon(Icons.picture_as_pdf_rounded),
            tooltip: 'Export All Records to PDF',
            onPressed: () async {
              final scaffold = ScaffoldMessenger.of(context);
              if (people.isEmpty) {
                scaffold.showSnackBar(const SnackBar(content: Text("No records available to compile.")));
                return;
              }
              scaffold.showSnackBar(const SnackBar(content: Text("Compiling master financial summary...")));
              try {
                // Generates master report compilation
                final file = await PdfService.generateMasterSummaryPdf(people);
                if (!mounted) return;
                await OpenFilex.open(file.path);
              } catch (e) {
                if (!mounted) return;
                scaffold.showSnackBar(SnackBar(content: Text("Failed to render document: $e")));
              }
            },
          ),
        ],
      ),
      body: people.isEmpty 
        ? const Center(child: Text("No entries yet. Tap + to add a person."))
        : ListView.builder(
            itemCount: people.length,
            itemBuilder: (context, index) {
              // Calculate the current net balance
              double total = 0;
              final txns = people[index]['transactions'];
              if (txns is List) {
                for (var t in txns) {
                  final amt = t['amount'];
                  if (amt is num) total += amt;
                }
              }

              final personName = people[index]['name'];

              return Dismissible(
                key: ValueKey('$personName-$index'),
                direction: DismissDirection.endToStart,
                confirmDismiss: (direction) async {
                  return await showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text("Confirm Deletion"),
                      content: Text("Delete $personName? This will wipe all their transaction history."),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(false), // Cancel
                          child: const Text("Cancel"),
                        ),
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(true), // Delete
                          child: const Text("Delete", style: TextStyle(color: Colors.red)),
                        ),
                      ],
                    ),
                  );
                },
                onDismissed: (direction) async {
                  String deletedName = people[index]['name'];
                  final messenger = ScaffoldMessenger.of(context);
                  
                  setState(() {
                    people.removeAt(index);
                  });
                  await _saveData();
                  if (!mounted) return;
                  messenger.showSnackBar(
                    SnackBar(content: Text("Removed $deletedName from ledger")),
                  );
                },
                background: Container(
                  color: Colors.red.shade400,
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20),
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                child: Card(
                  margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  child: ListTile(
                    title: Text(
                      personName,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    subtitle: Text(
                      total >= 0 ? "They owe you" : "You owe them",
                      style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "${total.abs().toStringAsFixed(2)} PKR",
                          style: TextStyle(
                            color: total >= 0 ? Colors.green : Colors.red,
                            fontWeight: FontWeight.bold,
                            fontSize: 16
                          ),
                        ),
                        PopupMenuButton<String>(
                          icon: const Icon(Icons.more_vert, size: 20),
                          onSelected: (v) => _handlePersonAction(v, index),
                          itemBuilder: (context) => [
                            const PopupMenuItem(value: 'pdf', child: ListTile(leading: Icon(Icons.picture_as_pdf, size: 20), title: Text('PDF'))),
                            const PopupMenuItem(value: 'graph', child: ListTile(leading: Icon(Icons.show_chart, size: 20), title: Text('Graph'))),
                          ],
                        ),
                      ],
                    ),
                    onTap: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => TransactionPage(
                            person: people[index],
                            fullPeopleList: people, // Pass full list for state sync
                          ),
                        ),
                      );
                      setState(() {}); // Repaint running summaries when returning
                    },
                  ),
                ),
              );
            },
          ),
      
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: () => _showAddDialog(),
            tooltip: 'Add Person',
            child: const Icon(Icons.add),
          ),
          const SizedBox(height: 10),
          const Padding(
            padding: EdgeInsets.only(right: 4.0),
            child: Text(
              "Made by Abubkar Ch",
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.blueGrey,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _handlePersonAction(String action, int index) async {
    final person = people[index];
    if (action == 'pdf') {
      final scaffold = ScaffoldMessenger.of(context);
      try {
        final file = await PdfService.generateSingleLedgerPdf(person);
        if (!mounted) return;
        await OpenFilex.open(file.path);
      } catch (e) {
        if (!mounted) return;
        scaffold.showSnackBar(SnackBar(content: Text('PDF export failed: $e')));
      }
    } else if (action == 'graph') {
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PersonGraphPage(person: person),
        ),
      );
    }
  }

  void _showAddDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Add New Person"),
        content: TextField(
          controller: _nameController,
          autofocus: true,
          decoration: const InputDecoration(hintText: "Enter name (e.g. Ali)"),
          onSubmitted: (_) => _addNewPerson(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context), 
            child: const Text("Cancel")
          ),
          ElevatedButton(
            onPressed: _addNewPerson, 
            child: const Text("Add")
          ),
        ],
      ),
    );
  }
}