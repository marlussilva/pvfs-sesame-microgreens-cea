import 'package:flutter/material.dart';
import 'dart:math' as math;

class WifiSignalDisplay extends StatefulWidget {
  final Size size;
  final double rssi; // Valor RSSI em dBm

  WifiSignalDisplay({required this.size, required this.rssi});

  @override
  _WifiSignalDisplayState createState() => _WifiSignalDisplayState();
}

class _WifiSignalDisplayState extends State<WifiSignalDisplay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _breathingAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _breathingAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _breathingAnimation,
      builder: (context, child) {
        return CustomPaint(
          size: widget.size,
          painter: WifiSignalPainter(widget.rssi, _breathingAnimation.value),
        );
      },
    );
  }
}

class WifiSignalPainter extends CustomPainter {
  final double rssi;
  final double animationValue;

  WifiSignalPainter(this.rssi, this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    _drawSignalWaves(canvas, size, animationValue);
    _drawSignalLabel(canvas, size);
  }

  void _drawSignalWaves(Canvas canvas, Size size, double animationValue) {
    Paint paint = Paint()
      ..style = PaintingStyle.stroke
      ..color = _getSignalColor(rssi).withOpacity(0.8)
      ..strokeWidth = 2.0;

    // Ajusta a base de desenho para que as ondas apontem para cima
    double baseSize = size.width * 0.1;
    double incrementSize = size.width * 0.15;
    for (int i = 0; i < 4; i++) {
      double radius = baseSize + i * incrementSize * animationValue;
      // Ajuste para desenhar os arcos para cima
      canvas.drawArc(
          Rect.fromCircle(
              center: Offset(size.width / 2, size.height * 0.6),
              radius: radius),
          math.pi, // Início do arco
          math.pi, // Extensão do arco
          false,
          paint);
    }
  }

  void _drawSignalLabel(Canvas canvas, Size size) {
    String signalQuality = _getSignalQuality(rssi);
    String labelText = '$signalQuality (${rssi.toInt()} dBm)';
    TextStyle textStyle = TextStyle(
      color: Colors.white.withOpacity(0.7),
      fontSize: 12,
      fontWeight: FontWeight.bold,
    );
    TextSpan textSpan = TextSpan(
      text: labelText,
      style: textStyle,
    );
    TextPainter textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    )..layout(maxWidth: size.width);

    textPainter.paint(canvas,
        Offset(size.width / 2 - textPainter.width / 2, size.height * 0.75));
  }

  Color _getSignalColor(double rssi) {
    if (rssi >= -50) {
      return Colors.green;
    } else if (rssi >= -70) {
      return Colors.yellow;
    } else {
      return Colors.red;
    }
  }

  String _getSignalQuality(double rssi) {
    if (rssi >= -50) {
      return 'Excelente';
    } else if (rssi >= -70) {
      return 'Razoável';
    } else {
      return 'Fraco';
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
