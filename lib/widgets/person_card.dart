import 'package:flutter/material.dart';

class PersonCard extends StatelessWidget {
  final String name;
  final double totalAmount;
  final VoidCallback onTap;

  const PersonCard({super.key, required this.name, required this.totalAmount, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: ListTile(
        onTap: onTap,
        title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
        trailing: Text(
          "${totalAmount.abs()} PKR",
          style: TextStyle(
            color: totalAmount >= 0 ? Colors.green : Colors.red,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}