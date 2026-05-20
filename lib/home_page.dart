import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'transaction_page.dart';
import 'statistics_page.dart';

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
      setState(() { people = jsonDecode(savedData); });
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
      appBar: AppBar(
        title: const Text("PTP Debt Analytics"),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.analytics_outlined),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => StatisticsPage(people: people)),
            ).then((_) => setState(() {})),
          )
        ],
      ),
      body: people.isEmpty
          ? const Center(child: Text("No data. Tap + to start sampling."))
          : ListView.builder(
        itemCount: people.length,
        itemBuilder: (context, index) {
          double total = 0;
          for (var t in people[index]['transactions']) {
            total += t['amount'];
          }
          return ListTile(
            title: Text(people[index]['name'], style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text("Net: ${total.toStringAsFixed(2)} PKR"),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => TransactionPage(
                  person: people[index],
                  fullPeopleList: people,
                ),
              ),
            ).then((_) => setState(() {})),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddDialog(),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Add New Peer"),
        content: TextField(controller: _nameController, decoration: const InputDecoration(hintText: "Enter Name")),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(onPressed: _addNewPerson, child: const Text("Add")),
        ],
      ),
    );
  }
}