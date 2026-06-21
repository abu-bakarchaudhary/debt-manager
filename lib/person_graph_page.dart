import 'dart:math' as math;
import 'package:flutter/material.dart';

class PersonGraphPage extends StatelessWidget {
  final Map<String, dynamic> person;

  const PersonGraphPage({super.key, required this.person});

  @override
  Widget build(BuildContext context) {
    final transactions = (person['transactions'] as List<dynamic>?) ?? [];

    return Scaffold(
      appBar: AppBar(
        title: Text('${person['name'] ?? 'Person'} - Payment Graph'),
      ),
      body: transactions.isEmpty
          ? const Center(child: Text('No transactions to display'))
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Expanded(
                    child: CustomPaint(
                      size: Size.infinite,
                      painter: CandleStickChartPainter(
                        transactions: transactions,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildLegend(),
                ],
              ),
            ),
    );
  }

  Widget _buildLegend() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _legendDot(Colors.green, 'Receivable (They owe)'),
        const SizedBox(width: 24),
        _legendDot(Colors.red, 'Payable (I owe)'),
      ],
    );
  }

  Widget _legendDot(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(fontSize: 13)),
      ],
    );
  }
}

class CandleStickChartPainter extends CustomPainter {
  final List<dynamic> transactions;

  CandleStickChartPainter({required this.transactions});

  @override
  void paint(Canvas canvas, Size size) {
    const leftGap = 55.0;
    const bottomGap = 55.0;
    const topGap = 20.0;
    const rightGap = 20.0;

    final plotLeft = leftGap;
    final plotRight = size.width - rightGap;
    final plotTop = topGap;
    final plotBottom = size.height - bottomGap;
    final plotW = plotRight - plotLeft;
    final plotH = plotBottom - plotTop;
    final midY = plotTop + plotH / 2;

    double maxAmt = 0;
    for (final t in transactions) {
      final a = (t['amount'] as num?)?.toDouble() ?? 0.0;
      if (a.abs() > maxAmt) maxAmt = a.abs();
    }
    if (maxAmt == 0) maxAmt = 1;
    maxAmt = _ceilToNice(maxAmt);

    final n = transactions.length;
    final spacing = n > 1 ? plotW / (n - 1) : plotW / 2;
    final candleW = (spacing * 0.5).clamp(6.0, 32.0);
    const wickW = 1.5;

    // ---- grid lines ----
    final gridPaint = Paint()
      ..color = Colors.grey.withValues(alpha: 0.15)
      ..strokeWidth = 1;
    const int steps = 4;
    for (int i = -steps; i <= steps; i++) {
      if (i == 0) continue;
      final y = midY - (i / steps) * (plotH / 2);
      canvas.drawLine(Offset(plotLeft, y), Offset(plotRight, y), gridPaint);
    }

    // ---- zero line ----
    final zeroPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.25)
      ..strokeWidth = 1.5;
    canvas.drawLine(Offset(plotLeft, midY), Offset(plotRight, midY), zeroPaint);

    // ---- axes ----
    final axisPaint = Paint()
      ..color = Colors.black38
      ..strokeWidth = 1.5;
    canvas.drawLine(Offset(plotLeft, plotTop), Offset(plotLeft, plotBottom), axisPaint);

    // ---- Y labels ----
    final yLabelStyle = TextStyle(color: Colors.black54, fontSize: 10);
    for (int i = -steps; i <= steps; i++) {
      if (i == 0) continue;
      final y = midY - (i / steps) * (plotH / 2);
      final val = (i / steps) * maxAmt;
      final tp = TextPainter(
        text: TextSpan(text: val.toStringAsFixed(0), style: yLabelStyle),
        textDirection: TextDirection.ltr,
      );
      tp.layout();
      tp.paint(canvas, Offset(plotLeft - tp.width - 5, y - tp.height / 2));
    }

    // ---- candles ----
    final xLabelStyle = TextStyle(color: Colors.black54, fontSize: 8);
    for (int i = 0; i < n; i++) {
      final amt = (transactions[i]['amount'] as num?)?.toDouble() ?? 0.0;
      final purpose = (transactions[i]['purpose'] as String?) ?? '';

      final x = n > 1 ? plotLeft + (i / (n - 1)) * plotW : plotLeft + plotW / 2;
      final scaled = (amt / maxAmt) * (plotH / 2);
      final isPos = amt >= 0;
      final color = isPos ? Colors.green : Colors.red;

      // wick
      final wickEnd = isPos
          ? midY - scaled.abs() - 6
          : midY + scaled.abs() + 6;
      canvas.drawLine(
        Offset(x, midY - scaled),
        Offset(x, wickEnd),
        Paint()
          ..color = color
          ..strokeWidth = wickW
          ..strokeCap = StrokeCap.round,
      );

      // body
      final bodyRect = Rect.fromCenter(
        center: Offset(x, midY - scaled / 2),
        width: candleW,
        height: scaled.abs().clamp(1.0, double.infinity),
      );
      canvas.drawRect(
        bodyRect,
        Paint()
          ..color = color
          ..style = PaintingStyle.fill,
      );

      // border
      canvas.drawRect(
        bodyRect,
        Paint()
          ..color = color.withValues(alpha: 0.6)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.5,
      );

      // X label
      final label = purpose.isEmpty
          ? 'Tx${i + 1}'
          : (purpose.length > 8 ? '${purpose.substring(0, 8)}..' : purpose);
      final lp = TextPainter(
        text: TextSpan(text: label, style: xLabelStyle),
        textDirection: TextDirection.ltr,
      );
      lp.layout(maxWidth: spacing);
      lp.paint(canvas, Offset(x - lp.width / 2, midY + 10));
    }
  }

  double _ceilToNice(double v) {
    if (v <= 0) return 1;
    final magnitude = math.pow(10, (math.log(v) / math.ln10).floor()).toDouble();
    final normalized = v / magnitude;
    if (normalized <= 1) return magnitude;
    if (normalized <= 2) return 2 * magnitude;
    if (normalized <= 5) return 5 * magnitude;
    return 10 * magnitude;
  }

  @override
  bool shouldRepaint(covariant CandleStickChartPainter oldDelegate) =>
      oldDelegate.transactions != transactions;
}
