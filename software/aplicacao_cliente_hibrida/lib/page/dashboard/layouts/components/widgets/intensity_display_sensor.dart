import 'package:flutter/material.dart';
import 'dart:math' as math;

class LightIntensitySensorDisplay extends StatefulWidget {
  final double intensity; // Intensidade luminosa em μmol/m²/s
  final Size size;

  LightIntensitySensorDisplay(this.intensity, {required this.size});

  @override
  _LightIntensitySensorDisplayState createState() =>
      _LightIntensitySensorDisplayState();
}

class _LightIntensitySensorDisplayState
    extends State<LightIntensitySensorDisplay> with TickerProviderStateMixin {
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
    // Detecta o tipo de dispositivo (mobile vs tablet/desktop) com base na largura da tela
    bool isMobile = MediaQuery.of(context).size.width < 600;

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return CustomPaint(
          size: widget.size,
          painter: LightIntensitySensorPainter(
            widget.intensity,
            _animation.value,
            Theme.of(context).brightness,
            isMobile:
                isMobile, // Passa a informação sobre o tipo de dispositivo
          ),
        );
      },
    );
  }
}

class LightIntensitySensorPainter extends CustomPainter {
  final double intensity;
  final double animationValue;
  final Brightness brightness;
  final bool isMobile; // Adiciona um parâmetro para verificar se é mobile

  LightIntensitySensorPainter(
      this.intensity, this.animationValue, this.brightness,
      {required this.isMobile});

  @override
  void paint(Canvas canvas, Size size) {
    final Offset center = Offset(
        size.width / 2,
        size.height / 2 -
            20); // Ajustado para deixar espaço para o texto abaixo
    final double radius = isMobile
        ? size.width / 4
        : size.width / 5; // Ajusta o raio para dispositivos maiores
    final Paint sensorPaint = Paint()..style = PaintingStyle.fill;
    final double opacity =
        animationValue < 0.5 ? animationValue : 1 - animationValue;

    sensorPaint.color =
        _getLightIntensityColor(intensity).withOpacity(0.75 + opacity * 0.25);
    if (brightness == Brightness.dark) {
      sensorPaint.color = sensorPaint.color.withOpacity(0.5 + opacity * 0.5);
    }
    canvas.drawCircle(center, radius, sensorPaint);

    _drawLightSymbol(canvas, size, center, radius);
    _drawIntensityText(
        canvas, size, Offset(center.dx, center.dy + radius + 20), isMobile);
  }

  void _drawLightSymbol(
      Canvas canvas, Size size, Offset center, double radius) {
    final paint = Paint()
      ..color = brightness == Brightness.dark
          ? Colors.white.withOpacity(0.8 + animationValue * 0.2)
          : Colors.black.withOpacity(0.8 + animationValue * 0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = isMobile
          ? 2
          : 1.5; // Ajusta a espessura do traço para dispositivos maiores

    const int rays = 8;
    for (int i = 0; i < rays; i++) {
      final angle = (i / rays) * 2 * math.pi;
      final lineStart =
          center + Offset(math.cos(angle), math.sin(angle)) * radius * 0.75;
      final lineEnd =
          center + Offset(math.cos(angle), math.sin(angle)) * radius * 1.25;
      canvas.drawLine(lineStart, lineEnd, paint);
    }

    canvas.drawCircle(center, radius * 0.5, paint..style = PaintingStyle.fill);
  }

  void _drawIntensityText(
      Canvas canvas, Size size, Offset textPosition, bool isMobile) {
    final textStyle = TextStyle(
      color: brightness == Brightness.dark ? Colors.white : Colors.black,
      fontSize: isMobile
          ? 12.0
          : 12.0, // Ajusta o tamanho da fonte para dispositivos maiores
      fontWeight: FontWeight.bold,
    );
    final textSpan = TextSpan(
      text: '${intensity.toInt()} μmol/m²/s',
      style: textStyle,
    );
    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
    )..layout(minWidth: 0, maxWidth: size.width);

    textPainter.paint(canvas, textPosition);
  }

  Color _getLightIntensityColor(double intensity) {
    if (intensity < 100) {
      return Colors.blue;
    } else if (intensity < 200) {
      return Colors.green;
    } else {
      return Colors.orange;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
