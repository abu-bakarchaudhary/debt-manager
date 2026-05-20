import 'package:flutter/material.dart';
import 'dart:math';

class StatisticsPage extends StatelessWidget {
  final List<dynamic> people;
  const StatisticsPage({super.key, required this.people});

  @override
  Widget build(BuildContext context) {
    List<double> magnitudes = [];
    double expectedBalance = 0;

    // 1. Gather all magnitudes for Mean/StdDev (Syllabus Item 1 & 6)
    for (var person in people) {
      double personNet = 0;
      int repaidCount = 0;
      List txs = person['transactions'];

      for (var t in txs) {
        double val = (t['amount'] as num).toDouble();
        magnitudes.add(val.abs());
        personNet += val;
        if (val > 0) repaidCount++;
      }

      // 2. Point Estimation of Reliability P(x) (Syllabus Item 11)
      double p = txs.isEmpty ? 0.5 : (repaidCount / txs.length);
      expectedBalance += (personNet > 0) ? (personNet * p) : personNet;
    }

    // 3. Normal Distribution Stats (Syllabus Item 8)
    double mean = magnitudes.isEmpty ? 0 : magnitudes.reduce((a, b) => a + b) / magnitudes.length;
    double variance = magnitudes.isEmpty ? 0 : magnitudes.map((x) => pow(x - mean, 2)).reduce((a, b) => a + b) / magnitudes.length;
    double stdDev = sqrt(variance);

    return Scaffold(
      appBar: AppBar(title: const Text("Statistical Insights")),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _card("Expected Wallet Value", "${expectedBalance.toStringAsFixed(2)} PKR", "Calculated via E[X] = Σ xP(x)"),
          _card("Sample Mean (μ)", "${mean.toStringAsFixed(2)} PKR", "Average transaction magnitude"),
          _card("Standard Deviation (σ)", "${stdDev.toStringAsFixed(2)} PKR", "Measure of data dispersion"),
          const SizedBox(height: 20),
          const Text("Peer Reliability Index", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const Divider(),
          ...people.map((p) {
            List txs = p['transactions'];
            int success = txs.where((t) => t['amount'] > 0).length;
            double prob = txs.isEmpty ? 0 : success / txs.length;
            return ListTile(
              title: Text(p['name']),
              subtitle: Text("Confidence based on n=${txs.length} samples"),
              trailing: Text("${(prob * 100).toStringAsFixed(1)}%",
                  style: TextStyle(color: prob > 0.7 ? Colors.green : Colors.red, fontWeight: FontWeight.bold)),
            );
          }),
        ],
      ),
    );
  }

  Widget _card(String t, String v, String s) => Card(
    child: ListTile(title: Text(t), subtitle: Text(s), trailing: Text(v, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.teal))),
  );
}