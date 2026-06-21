import 'package:flutter/material.dart';
import 'dart:math';

class StatisticsPage extends StatelessWidget {
  final List<dynamic> people;

  const StatisticsPage({super.key, required this.people});

  // --- STATISTICAL CORNERSTONE CALCULATIONS ---

  double get totalReceivable {
    double sum = 0;
    for (var person in people) {
      if (person['transactions'] != null) {
        for (var tx in person['transactions']) {
          if (tx['amount'] > 0) sum += tx['amount'];
        }
      }
    }
    return sum;
  }

  double get totalPayable {
    double sum = 0;
    for (var person in people) {
      if (person['transactions'] != null) {
        for (var tx in person['transactions']) {
          if (tx['amount'] < 0) sum += tx['amount'].abs();
        }
      }
    }
    return sum;
  }

  double get netCashFlow => totalReceivable - totalPayable;

  /// Probability that the next transaction in your university circle will be a cash outflow (paying someone)
  double get probabilityOfExpense {
    int totalTransactions = 0;
    int negativeTransactions = 0;

    for (var person in people) {
      if (person['transactions'] != null) {
        for (var tx in person['transactions']) {
          totalTransactions++;
          if (tx['amount'] < 0) negativeTransactions++;
        }
      }
    }
    if (totalTransactions == 0) return 0.0;
    return (negativeTransactions / totalTransactions);
  }

  /// Statistical Variance: Measures how volatile or unevenly distributed your debts are among friends
  double calculateVariance() {
    if (people.isEmpty) return 0.0;

    // 1. Find balances for each person safely
    List<double> balances = people.map((person) {
      double bal = 0;
      if (person['transactions'] != null) {
        for (var tx in person['transactions']) { 
          bal += (tx['amount'] as num).toDouble(); 
        }
      }
      return bal;
    }).toList();

    // 2. Find Mean ($\mu$)
    double mean = balances.reduce((a, b) => a + b) / balances.length;

    // 3. Find Average of Squared Differences
    double squaredDiffSum = balances
      .map((b) => pow(b - mean, 2).toDouble())
      .reduce((a, b) => a + b);
    return squaredDiffSum / balances.length;
  }

  @override
  Widget build(BuildContext context) {
    double variance = calculateVariance();
    double stdDeviation = sqrt(variance); // Standard Deviation ($\sigma$)
    double probExpense = probabilityOfExpense;
    double probIncome = people.isEmpty ? 0.0 : 1.0 - probExpense;

    return Scaffold(
      backgroundColor: const Color(0xFFFBF0F6), // Matches your Skeuomorphic theme base
      appBar: AppBar(
        title: const Text("Statistical Matrix & Probability"),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- FINANCIAL CARD SUMMARY ---
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFFEBF0F6),
                borderRadius: BorderRadius.circular(20),
                boxShadow: const [
                  BoxShadow(color: Colors.white, offset: Offset(-5, -5), blurRadius: 10),
                  BoxShadow(color: Color(0xA3B1C67F), offset: Offset(5, 5), blurRadius: 10),
                ],
              ),
              child: Column(
                children: [
                  const Text("NET WALLET LIQUIDITY", style: TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 5),
                  Text(
                    "${netCashFlow.toStringAsFixed(2)} PKR",
                    style: TextStyle(
                      fontSize: 28, 
                      fontWeight: FontWeight.w900, 
                      color: netCashFlow >= 0 ? Colors.green.shade600 : Colors.red.shade600
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 25),

            const Text("PROBABILITY METRICS", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blueGrey)),
            const SizedBox(height: 10),

            // --- PROBABILITY TILES ---
            Row(
              children: [
                Expanded(
                  child: _buildSkeuomorphicStatCard(
                    title: "Receivable Prob. P(In)",
                    value: "${(probIncome * 100).toStringAsFixed(1)}%",
                    subtitle: "Chance next ledger item is income",
                    icon: Icons.arrow_downward,
                    iconColor: Colors.green,
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: _buildSkeuomorphicStatCard(
                    title: "Payable Prob. P(Out)",
                    value: "${(probExpense * 100).toStringAsFixed(1)}%",
                    subtitle: "Chance next ledger item is debt",
                    icon: Icons.arrow_upward,
                    iconColor: Colors.red,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 25),

            const Text("DATA VARIANCE & DISTRIBUTION", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blueGrey)),
            const SizedBox(height: 10),

            // --- ADVANCED STATS TILES ---
            _buildSkeuomorphicStatCard(
              title: "Standard Deviation (σ)",
              value: "${stdDeviation.toStringAsFixed(2)} PKR",
              subtitle: stdDeviation > 500 
                  ? "High Volatility: Debts are highly uneven across your circle."
                  : "Low Volatility: Balances are evenly shared among peers.",
              icon: Icons.analytics_outlined,
              iconColor: Colors.purple,
            ),
            
            const SizedBox(height: 40),
            const Center(
              child: Text(
                "Generated by Student Debt Analytics Engine v1.0",
                style: TextStyle(fontSize: 10, color: Colors.grey, fontStyle: FontStyle.italic),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Skeuomorphic card abstraction to maintain design uniformity
  Widget _buildSkeuomorphicStatCard({
    required String title, 
    required String value, 
    required String subtitle, 
    required IconData icon,
    required Color iconColor
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFEBF0F6),
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: Colors.white, offset: Offset(-3, -3), blurRadius: 6),
          BoxShadow(color: Color(0xA3B1C640), offset: Offset(3, 3), blurRadius: 6),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: iconColor, size: 20),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(4)),
                child: const Text("MATH", style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold)),
              )
            ],
          ),
          const SizedBox(height: 10),
          Text(title, style: const TextStyle(fontSize: 12, color: Colors.blueGrey, fontWeight: FontWeight.w500)),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
          const SizedBox(height: 6),
          Text(subtitle, style: TextStyle(fontSize: 10, color: Colors.grey.shade600)),
        ],
      ),
    );
  }
}