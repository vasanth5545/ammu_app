import 'package:flutter/material.dart';
import 'dart:math' as math;

class GaugePainter extends CustomPainter {
  final double value;
  final double maxValue = 250;

  GaugePainter({required this.value});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 1.5);
    final radius = size.width / 1.5;
    const startAngle = 135 * (math.pi / 180);
    const sweepAngle = 270 * (math.pi / 180);
    final rect = Rect.fromCircle(center: center, radius: radius);
    final gapRadians = 1 * (math.pi / 180);

    final sections = [
      {'color': const Color(0xFF006400), 'start': 0.0, 'end': 49.0},
      {'color': const Color(0xFF74B04C), 'start': 51.0, 'end': 99.0},
      {'color': const Color(0xFFFDE49C), 'start': 101.0, 'end': 149.0},
      {'color': const Color(0xFFE59A45), 'start': 151.0, 'end': 199.0},
      {'color': const Color(0xFFB5542E), 'start': 201.0, 'end': 250.0},
    ];

    for (var section in sections) {
      final color = section['color'] as Color;
      final startVal = section['start'] as double;
      final endVal = section['end'] as double;

      final sectionStart = startAngle + (startVal / maxValue) * sweepAngle + gapRadians / 2;
      final sectionSweep = ((endVal - startVal) / maxValue) * sweepAngle - gapRadians;

      final isPointerHere = value >= startVal && value <= endVal;

      if (isPointerHere) {
        final verticalOffset = 4.0;
        final shadowOpacity = 0.2; // ⭐ Adjust shadow opacity here
        final shadowCenter = Offset(center.dx, center.dy + verticalOffset);
        final shadowRect = Rect.fromCircle(center: shadowCenter, radius: radius);

        final shadowPaint = Paint()
          ..color = Colors.black.withOpacity(shadowOpacity)
          ..strokeWidth = 26 + 4
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.butt;

        canvas.drawArc(shadowRect, sectionStart, sectionSweep, false, shadowPaint);
      }

      final paint = Paint()
        ..color = color
        ..strokeWidth = isPointerHere ? 26 : 18
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.butt;

      canvas.drawArc(rect, sectionStart, sectionSweep, false, paint);

      if (startVal == 0.0) {
        final capX = center.dx + radius * math.cos(sectionStart);
        final capY = center.dy + radius * math.sin(sectionStart);
        final capOffset = Offset(capX, capY);
        canvas.drawCircle(capOffset, 9, Paint()..color = color);
      } else if (endVal == 250.0) {
        final endAngle = sectionStart + sectionSweep;
        final capX = center.dx + radius * math.cos(endAngle);
        final capY = center.dy + radius * math.sin(endAngle);
        final capOffset = Offset(capX, capY);
        canvas.drawCircle(capOffset, 9, Paint()..color = color);
      }
    }

    // 🔘 Draw pointer
    final pointerAngle =
        startAngle + ((value.clamp(0, maxValue) / maxValue) * sweepAngle);
    final pointerPaint = Paint()..color = const Color(0xFF63A646);
    final pointerX = center.dx + radius * math.cos(pointerAngle);
    final pointerY = center.dy + radius * math.sin(pointerAngle);

    canvas.drawCircle(
      Offset(pointerX, pointerY),
      12,
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4,
    );
    canvas.drawCircle(Offset(pointerX, pointerY), 10, pointerPaint);

    _drawLabels(canvas, size, center);
  }

  void _drawLabels(Canvas canvas, Size size, Offset center) {
    final labels = {
      'Low': 135.0,
      '50': 189.0,
      '100': 240.0,
      '150': 300.0,
      '200': 350.0,
      'High': 45.0,
    };

    labels.forEach((text, angle) {
      final textPainter = TextPainter(
        text: TextSpan(
          text: text,
          style: TextStyle(
            color: Colors.grey[700],
            fontSize: 20,
            fontWeight: ['Low', 'High'].contains(text)
                ? FontWeight.bold
                : FontWeight.normal,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();

      final angleRad = angle * (math.pi / 180);
      final labelRadius = (size.width / 1.4) + 20;
      final x =
          center.dx + labelRadius * math.cos(angleRad) - textPainter.width / 2;
      final y =
          center.dy + labelRadius * math.sin(angleRad) - textPainter.height / 2;

      textPainter.paint(canvas, Offset(x, y));
    });
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
