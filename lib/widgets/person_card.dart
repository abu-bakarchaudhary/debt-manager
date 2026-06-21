import 'package:flutter/material.dart';

class PersonCard extends StatelessWidget {
  final String name;
  final double totalAmount;
  final VoidCallback onTap;

  const PersonCard({
    super.key, 
    required this.name, 
    required this.totalAmount, 
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: ListTile(
        onTap: onTap,
        title: Text(
          name, 
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          totalAmount >= 0 ? "Net Creditor" : "In Debt",
          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
        ),
        trailing: Text(
          "${totalAmount.abs().toStringAsFixed(2)} PKR",
          style: TextStyle(
            color: totalAmount >= 0 ? Colors.green.shade700 : Colors.red.shade700,
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
        ),
      ),
    );
  }
}