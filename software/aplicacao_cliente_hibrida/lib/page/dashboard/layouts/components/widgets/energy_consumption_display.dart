import 'package:flutter/material.dart';
import 'dart:math' as math;

class EnergyConsumptionDisplay extends StatefulWidget {
  final Size size;
  final double energyConsumption; // Consumo de energia em kWh

  EnergyConsumptionDisplay(this.energyConsumption, {required this.size});

  @override
  _EnergyConsumptionDisplayState createState() =>
      _EnergyConsumptionDisplayState();
}

class _EnergyConsumptionDisplayState extends State<EnergyConsumptionDisplay>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  late Animation<double> _arcAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: 0.5, end: 1.0)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _arcAnimation = Tween<double>(
            begin: 0, end: math.pi * 2 * (widget.energyConsumption / 1000))
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
      animation: Listenable.merge([_animation, _arcAnimation]),
      builder: (context, child) {
        return CustomPaint(
          size: widget.size,
          painter: EnergyConsumptionPainter(
              _animation.value, _arcAnimation.value, widget.energyConsumption),
        );
      },
    );
  }
}

class EnergyConsumptionPainter extends CustomPainter {
  final double opacityAnimationValue;
  final double arcAnimationValue;
  final double energyConsumption;

  EnergyConsumptionPainter(this.opacityAnimationValue, this.arcAnimationValue,
      this.energyConsumption);

  @override
  void paint(Canvas canvas, Size size) {
    final Offset center = Offset(size.width / 2, size.height / 2);
    final double radius = size.width / 4;
    final Paint energyPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10.0;

    // Ajusta a cor para o tema escuro
    Color color;
    if (energyConsumption < 100) {
      color = Colors.lightGreenAccent;
    } else if (energyConsumption >= 100 && energyConsumption < 500) {
      color = Colors.orangeAccent;
    } else {
      color = Colors.redAccent;
    }
    energyPaint.color = color.withOpacity(opacityAnimationValue);

    // Desenha um arco dinâmico
    canvas.drawArc(Rect.fromCircle(center: center, radius: radius), math.pi,
        arcAnimationValue, false, energyPaint);

    // Exibe o valor do consumo de energia
    _drawEnergyText(canvas, size, center, radius, energyConsumption, color);
  }

  void _drawEnergyText(Canvas canvas, Size size, Offset center, double radius,
      double energyConsumption, Color color) {
    TextStyle textStyle = TextStyle(
      color: color.withOpacity(opacityAnimationValue),
      fontSize: radius / 4,
      fontWeight: FontWeight.bold,
    );
    String text = '${energyConsumption.toStringAsFixed(3)} kWh';

    final TextSpan textSpan = TextSpan(text: text, style: textStyle);
    final TextPainter textPainter = TextPainter(
      text: textSpan,
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    )..layout(minWidth: 0, maxWidth: size.width);

    textPainter.paint(
      canvas,
      Offset(center.dx - textPainter.width / 2,
          center.dy - textPainter.height / 2),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
