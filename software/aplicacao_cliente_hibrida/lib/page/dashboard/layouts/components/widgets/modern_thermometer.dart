import 'package:flutter/material.dart';

class ModernThermometer extends StatefulWidget {
  final double temperature;
  final Size size;

  ModernThermometer(this.temperature, {required this.size});

  @override
  _ModernThermometerState createState() => _ModernThermometerState();
}

class _ModernThermometerState extends State<ModernThermometer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: widget.size,
      painter: ModernThermometerPainter(widget.temperature, _controller.value),
    );
  }
}

class ModernThermometerPainter extends CustomPainter {
  final double temperature;
  final double animationValue;

  ModernThermometerPainter(this.temperature, this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final Paint thermometerPaint = Paint()
      ..color = Colors.grey[300]!
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0;

    final Offset center = Offset(size.width / 2, size.height - 30);
    final double bulbRadius = 25;

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromPoints(
          Offset(20, 20),
          Offset(size.width - 20, size.height - bulbRadius - 20),
        ),
        Radius.circular(15),
      ),
      thermometerPaint,
    );

    canvas.drawCircle(center, bulbRadius, thermometerPaint);

    double limitedTemperature = temperature.clamp(0.0, 100.0);

    final double mercuryHeight =
        (size.height - 60) * (limitedTemperature / 100);
    final Paint mercuryPaint = Paint()
      ..color = Colors.red
      ..style = PaintingStyle.fill;

    canvas.drawRect(
      Rect.fromPoints(
        Offset(size.width / 2 - 10, size.height - 50),
        Offset(size.width / 2 + 10, size.height - 50 - mercuryHeight),
      ),
      mercuryPaint,
    );

    canvas.drawCircle(center, bulbRadius - 4, mercuryPaint);

    final double waveHeight = 10 * (animationValue - 0.5).abs();
    final double waveWidth = 20;
    final double start = size.width / 2 - 10;
    final double end = size.width / 2 + 10;
    final double mercuryTop = size.height - 60 - mercuryHeight;
    final Path path = Path()
      ..moveTo(start, mercuryTop)
      ..quadraticBezierTo(
        start + waveWidth / 2,
        mercuryTop + waveHeight,
        end,
        mercuryTop,
      );

    canvas.drawPath(path, mercuryPaint);

    // Desenho do texto da temperatura
    final textStyle = TextStyle(
      color: Colors.white,
      fontSize: 14.0,
      fontWeight: FontWeight.bold,
    );
    final textSpan = TextSpan(
      text: '${limitedTemperature.toStringAsFixed(1)}',
      style: textStyle,
    );
    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
    );
    textPainter.layout(
      minWidth: 0,
      maxWidth: size.width,
    );
    final textOffset = Offset(
      center.dx - textPainter.width / 2,
      center.dy - textPainter.height / 2,
    );
    textPainter.paint(canvas, textOffset);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
