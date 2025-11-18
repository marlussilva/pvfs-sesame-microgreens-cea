import 'package:flutter/material.dart';
import 'dart:math' as math;

class PHDisplay extends StatefulWidget {
  final Size size;
  final double pH; // Intervalo de pH agora é de 0 a 14

  PHDisplay(this.pH, {required this.size});

  @override
  _PHDisplayState createState() => _PHDisplayState();
}

class _PHDisplayState extends State<PHDisplay> with TickerProviderStateMixin {
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
          painter: PHPainter(_animation.value, widget.pH),
        );
      },
    );
  }
}

class PHPainter extends CustomPainter {
  final double animationValue;
  final double pH;

  PHPainter(this.animationValue, this.pH);

  @override
  void paint(Canvas canvas, Size size) {
    final Offset center = Offset(size.width / 2, size.height / 2);
    final double radius = size.width / 4;
    final Paint phPaint = Paint()..style = PaintingStyle.fill;

    // Define a cor baseada no valor do pH
    Color color;
    if (pH < 7) {
      // Acidez: vai de vermelho a amarelo conforme se aproxima do neutro
      double intensity = pH / 7;
      color = Color.lerp(Colors.red, Colors.yellow, intensity)!;
    } else {
      // Alcalinidade: vai de verde a azul conforme se afasta do neutro
      double intensity = (pH - 7) / 7;
      color = Color.lerp(Colors.green, Colors.blue, intensity)!;
    }
    phPaint.color = color.withOpacity(0.75 + animationValue * 0.25);
    canvas.drawCircle(center, radius, phPaint);

    // Exibe o valor do pH
    _drawPHText(canvas, size, center, radius, pH);
  }

  void _drawPHText(
      Canvas canvas, Size size, Offset center, double radius, double pH) {
    TextStyle textStyle = TextStyle(
      color: Colors.white,
      fontSize: radius / 4,
      fontWeight: FontWeight.bold,
    );
    String text = pH.toStringAsFixed(1);

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
