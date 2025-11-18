import 'package:flutter/material.dart';
import 'dart:math' as math;

class SunDisplay extends StatefulWidget {
  final Size size;
  final double intensity; // Intervalo agora é de 0 a 100

  SunDisplay(this.intensity, {required this.size});

  @override
  _SunDisplayState createState() => _SunDisplayState();
}

class _SunDisplayState extends State<SunDisplay> with TickerProviderStateMixin {
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
          painter: SunPainter(_animation.value, widget.intensity),
        );
      },
    );
  }
}

class SunPainter extends CustomPainter {
  final double animationValue;
  final double intensity; // Agora trabalha com o intervalo de 0 a 100

  SunPainter(this.animationValue, this.intensity);

  @override
  void paint(Canvas canvas, Size size) {
    final Offset center = Offset(size.width / 2, size.height / 2);
    final double radius = size.width / 4;
    final Paint sunPaint = Paint()..style = PaintingStyle.fill;

    // Desenha o sol
    sunPaint.color = Colors.orange.withOpacity(0.75 + animationValue * 0.25);
    canvas.drawCircle(center, radius, sunPaint);

    // Desenha os raios do sol de acordo com a intensidade, começando do topo
    _drawSunRays(canvas, size, center, radius, intensity);

    // Exibe a intensidade ou "Desligado"
    _drawIntensityText(canvas, size, center, radius, intensity);
  }

  void _drawSunRays(Canvas canvas, Size size, Offset center, double radius,
      double intensity) {
    final int points = 20; // Total de pontos (raios) possíveis
    final int activePoints = ((intensity / 100) * points).round();

    final Paint rayPaint = Paint()
      ..color = Colors.yellow.withOpacity(0.8)
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    for (int i = 0; i < activePoints; i++) {
      final double angle = (2 * math.pi / points) * i - math.pi / 2;
      final double rayLength = radius * 0.75 * (1 + animationValue);
      final Offset start = Offset(center.dx + radius * math.cos(angle),
          center.dy + radius * math.sin(angle));
      final Offset end = Offset(
          center.dx + (radius + rayLength) * math.cos(angle),
          center.dy + (radius + rayLength) * math.sin(angle));
      canvas.drawLine(start, end, rayPaint);
    }
  }

  void _drawIntensityText(Canvas canvas, Size size, Offset center,
      double radius, double intensity) {
    TextStyle textStyle = TextStyle(
        color: Colors.white, fontSize: radius / 4, fontWeight: FontWeight.bold);
    String text = '${intensity.toInt()}%';

    // Ajusta o tamanho da fonte e a posição do texto baseado na intensidade
    if (intensity > 0) {
      textStyle = TextStyle(
          color: Colors.white,
          fontSize: radius / 2,
          fontWeight: FontWeight.bold); // Maior para a porcentagem
      text = '${intensity.toInt()}%';
    } else {
      textStyle = TextStyle(
          color: Colors.white,
          fontSize: radius / 4,
          fontWeight: FontWeight.bold); // Menor para "Desligado"
      text = 'Desligado';
    }

    final TextSpan textSpan = TextSpan(text: text, style: textStyle);
    final TextPainter textPainter = TextPainter(
      text: textSpan,
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    )..layout(minWidth: 0, maxWidth: size.width);

    if (intensity > 0) {
      textPainter.paint(
          canvas,
          Offset(center.dx - textPainter.width / 2,
              center.dy - textPainter.height / 2));
    } else {
      textPainter.paint(
          canvas,
          Offset(center.dx - textPainter.width / 2,
              center.dy + radius + 20)); // Abaixo do sol para "Desligado"
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
