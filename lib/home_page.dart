import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'widgets/person_card.dart';
import 'transaction_page.dart';

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

  Future<void> _saveData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('debt_data', jsonEncode(people));
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    final String? savedData = prefs.getString('debt_data');
    if (savedData != null) {
      setState(() {
        people = jsonDecode(savedData);
      });
    }
  }

  void _addNewPerson() {
    if (_nameController.text.isNotEmpty) {
      setState(() {
        people.add({"name": _nameController.text, "transactions": []});
      });
      _nameController.clear();
      _saveData();
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Student Debt Manager"), centerTitle: true),
      body: ListView.builder(
        itemCount: people.length,
        itemBuilder: (context, index) {
          double total = 0;
          for (var t in people[index]['transactions']) {
            total += t['amount'];
          }

          return Dismissible(
            key: Key(people[index]['name'] + index.toString()),
            direction: DismissDirection.endToStart,
            // --- NEW: Confirmation Dialog Logic ---
            confirmDismiss: (direction) async {
              return await showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text("Delete Person?"),
                  content: Text("Are you sure you want to remove ${people[index]['name']} and all their data?"),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: const Text("Cancel"),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      child: const Text("Delete", style: TextStyle(color: Colors.red)),
                    ),
                  ],
                ),
              );
            },
            onDismissed: (direction) {
              setState(() {
                people.removeAt(index);
              });
              _saveData();
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Person removed")));
            },
            background: Container(
              color: Colors.red,
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: 20),
              child: const Icon(Icons.delete, color: Colors.white),
            ),
            child: PersonCard(
              name: people[index]['name'],
              totalAmount: total,
              onTap: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => TransactionPage(person: people[index]),
                  ),
                );
                setState(() {});
                _saveData();
              },
            ),
          );
        },
      ),
      // --- NEW: Updated FAB with "Made by Abubkar Ch" ---
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: () => _showAddDialog(),
            child: const Icon(Icons.add),
          ),
          const SizedBox(height: 8),
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

  void _showAddDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("New Person"),
        content: TextField(controller: _nameController, decoration: const InputDecoration(hintText: "Enter Name")),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(onPressed: _addNewPerson, child: const Text("Add")),
        ],
      ),
    );
  }
}