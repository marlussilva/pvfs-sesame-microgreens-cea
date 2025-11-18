import 'package:flutter/material.dart';
import 'dart:math' as math;

class KWhMeterDisplay extends StatefulWidget {
  final double energyConsumption;
  final Size size;

  KWhMeterDisplay(this.energyConsumption, {required this.size});

  @override
  _KWhMeterDisplayState createState() => _KWhMeterDisplayState();
}

class _KWhMeterDisplayState extends State<KWhMeterDisplay>
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
          painter: KWhMeterPainter(widget.energyConsumption, _animation.value),
        );
      },
    );
  }
}

class KWhMeterPainter extends CustomPainter {
  final double energyConsumption;
  final double animationValue;

  KWhMeterPainter(this.energyConsumption, this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final Offset center = Offset(size.width / 2, size.height / 2);
    final double radius = size.width / 3;

    // Desenha o fundo do medidor adaptado para tema escuro
    _drawMeterBackground(canvas, size, center, radius);

    // Desenha o marcador adaptado para tema escuro
    _drawMarker(canvas, size, center, radius);

    // Desenha o texto do consumo de energia adaptado para tema escuro
    _drawEnergyConsumptionText(canvas, size, center);
  }

  void _drawMeterBackground(
      Canvas canvas, Size size, Offset center, double radius) {
    final Paint backgroundPaint = Paint()
      ..color = Colors.white
          .withOpacity(0.5) // Cor mais clara para destaque no tema escuro
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8.0;
    canvas.drawCircle(center, radius, backgroundPaint);
  }

  void _drawMarker(Canvas canvas, Size size, Offset center, double radius) {
    final Paint markerPaint = Paint()
      ..color = Colors.tealAccent // Cor que se destaca em fundo escuro
      ..style = PaintingStyle.fill;

    final double markerAngle =
        math.pi * (1 + (energyConsumption % 1000) / 1000);
    final Offset markerEnd = center +
        Offset(math.cos(markerAngle), math.sin(markerAngle)) * radius * 0.8;

    canvas.drawLine(center, markerEnd, markerPaint..strokeWidth = 4);

    // Base do marcador com cor ajustada para tema escuro
    canvas.drawCircle(center, radius * 0.1, markerPaint..color = Colors.teal);
  }

  void _drawEnergyConsumptionText(Canvas canvas, Size size, Offset center) {
    final textStyle = TextStyle(
      color: Colors.lightBlueAccent, // Cor clara para contraste no tema escuro
      fontSize: 20.0,
      fontWeight: FontWeight.bold,
    );
    final textSpan = TextSpan(
      text: '${energyConsumption.toStringAsFixed(2)} kWh',
      style: textStyle,
    );
    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
    )..layout(minWidth: 0, maxWidth: size.width);

    final textOffset = Offset(
      center.dx - textPainter.width / 2,
      center.dy + size.width / 3 + 20,
    );
    textPainter.paint(canvas, textOffset);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
