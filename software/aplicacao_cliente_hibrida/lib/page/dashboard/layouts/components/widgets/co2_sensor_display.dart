import 'package:flutter/material.dart';
import 'dart:math' as math;

class CO2SensorDisplay extends StatefulWidget {
  final double concentration;
  final Size size;

  CO2SensorDisplay(this.concentration, {required this.size});

  @override
  _CO2SensorDisplayState createState() => _CO2SensorDisplayState();
}

class _CO2SensorDisplayState extends State<CO2SensorDisplay>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: 0.0, end: 1.0)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return CustomPaint(
          size: widget.size,
          painter: CO2SensorPainter(widget.concentration, _animation.value),
        );
      },
    );
  }
}

class CO2SensorPainter extends CustomPainter {
  final double concentration;
  final double animationValue;

  CO2SensorPainter(this.concentration, this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final Offset center = Offset(size.width / 2, size.height / 2);
    final double radius = size.width / 4;
    final Paint sensorPaint = Paint()..style = PaintingStyle.fill;
    final double opacity =
        animationValue < 0.5 ? animationValue : 1 - animationValue;

    // Define a cor e desenha o sensor
    sensorPaint.color =
        _getSensorColor(concentration).withOpacity(0.75 + opacity * 0.25);
    canvas.drawCircle(center, radius, sensorPaint);

    // Desenha as nuvens de CO2
    _drawCO2Clouds(canvas, size, center, radius);

    // Desenha o texto da concentração
    _drawConcentrationText(canvas, size, center);
  }

  void _drawCO2Clouds(Canvas canvas, Size size, Offset center, double radius) {
    final cloudPaint = Paint()
      ..color =
          _getCloudColor(concentration).withOpacity(0.3 + animationValue * 0.7);
    final cloudRadius = radius *
        (1.5 +
            concentration /
                2000); // Ajusta o tamanho da nuvem baseado na concentração
    final cloudCenter = Offset(
        center.dx + radius * 0.6 * math.cos(animationValue * 2 * math.pi),
        center.dy + radius * 0.6 * math.sin(animationValue * 2 * math.pi));

    canvas.drawCircle(cloudCenter, cloudRadius, cloudPaint);
    canvas.drawCircle(Offset(center.dx - cloudRadius, center.dy),
        cloudRadius * 0.85, cloudPaint);
    canvas.drawCircle(
        Offset(center.dx + cloudRadius * 0.5, center.dy - cloudRadius * 0.5),
        cloudRadius * 0.75,
        cloudPaint);
  }

  void _drawConcentrationText(Canvas canvas, Size size, Offset center) {
    final textStyle = TextStyle(
      color: Colors.white,
      fontSize: 22.0,
      fontWeight: FontWeight.bold,
    );
    final textSpan = TextSpan(
      text: '${concentration.toInt()} ppm',
      style: textStyle,
    );
    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
    )..layout(minWidth: 0, maxWidth: size.width);

    final textOffset = Offset(
      center.dx - textPainter.width / 2,
      center.dy - textPainter.height / 2,
    );
    textPainter.paint(canvas, textOffset);
  }

  Color _getSensorColor(double concentration) {
    if (concentration < 800) {
      return Colors.green;
    } else if (concentration < 1200) {
      return Colors.yellow;
    } else {
      return Colors.red;
    }
  }

  Color _getCloudColor(double concentration) {
    if (concentration < 800) {
      return Colors.green[200]!;
    } else if (concentration < 1200) {
      return Colors.yellow[200]!;
    } else {
      return Colors.red[200]!;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
