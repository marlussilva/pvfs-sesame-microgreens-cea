import 'package:flutter/material.dart';
import 'dart:math' as math;

class PowerFactorIndicator extends StatefulWidget {
  final double powerFactor; // Fator de potência, valor entre 0.0 e 1.0
  final Size size;

  PowerFactorIndicator(this.powerFactor, {required this.size});

  @override
  _PowerFactorIndicatorState createState() => _PowerFactorIndicatorState();
}

class _PowerFactorIndicatorState extends State<PowerFactorIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut)
      ..addListener(() => setState(() {}))
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          _controller.reverse();
        } else if (status == AnimationStatus.dismissed) {
          _controller.forward();
        }
      });

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: widget.size,
      painter:
          PowerFactorIndicatorPainter(widget.powerFactor, _animation.value),
    );
  }
}

class PowerFactorIndicatorPainter extends CustomPainter {
  final double powerFactor;
  final double animationValue;

  PowerFactorIndicatorPainter(this.powerFactor, this.animationValue) : super();

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2 * 0.8;
    final startAngle = -math.pi / 2;
    final sweepAngle = 2 * math.pi * powerFactor * animationValue;
    final backgroundPaint = Paint()
      ..color = Colors.grey.shade800
      ..style = PaintingStyle.stroke
      ..strokeWidth = 20;

    canvas.drawCircle(center, radius, backgroundPaint);

    Color arcColor;
    if (powerFactor >= 0.85) {
      arcColor = Colors.green;
    } else if (powerFactor >= 0.5 && powerFactor < 0.85) {
      arcColor = Colors.yellow;
    } else {
      arcColor = Colors.red;
    }

    final powerFactorPaint = Paint()
      ..color = arcColor
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 10;

    canvas.drawArc(Rect.fromCircle(center: center, radius: radius), startAngle,
        sweepAngle, false, powerFactorPaint);

    final text = powerFactor.toStringAsFixed(2);
    final textStyle = TextStyle(
      color: Colors.white,
      fontSize: 20,
      fontWeight: FontWeight.bold,
    );
    final textSpan = TextSpan(text: text, style: textStyle);
    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    final textCenter = Offset(
        center.dx - textPainter.width / 2, center.dy - textPainter.height / 2);
    textPainter.paint(canvas, textCenter);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
