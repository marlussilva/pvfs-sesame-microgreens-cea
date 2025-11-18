import 'package:flutter/material.dart';
import 'package:aplicacao_cliente_hibrida/l10n/app_localizations.dart';

class ModernLedLight extends StatefulWidget {
  final double intensity;
  final Size size;

  ModernLedLight(this.intensity, {required this.size});

  @override
  _ModernLedBulbState createState() => _ModernLedBulbState();
}

class _ModernLedBulbState extends State<ModernLedLight>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _animation = Tween<double>(begin: 0.5, end: 1.0)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut))
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
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return CustomPaint(
          size: widget.size,
          painter: ModernLedBulbPainter(widget.intensity, _animation.value),
        );
      },
    );
  }
}

class ModernLedBulbPainter extends CustomPainter {
  final double intensity;
  final double animationValue;

  ModernLedBulbPainter(this.intensity, this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final double bulbRadius = size.width / 4;
    final Offset center = Offset(size.width / 2, size.height / 2);

    // Desenha a lâmpada
    final Paint bulbPaint = Paint()
      ..color = intensity == 0.0
          ? Colors.grey[300]!
          : Colors.yellow.withOpacity(animationValue)
      ..style = PaintingStyle.fill;
    canvas.drawOval(
      Rect.fromCenter(
          center: center, width: bulbRadius * 2, height: bulbRadius * 2.5),
      bulbPaint,
    );

    // Desenha a base da lâmpada
    final Paint basePaint = Paint()
      ..color = Colors.grey[850]!
      ..style = PaintingStyle.fill;
    canvas.drawRect(
      Rect.fromCenter(
          center: Offset(center.dx, center.dy + bulbRadius * 1.25),
          width: bulbRadius,
          height: bulbRadius / 2),
      basePaint,
    );

    // Desenha o texto da intensidade ou "desligado"
    TextStyle textStyle;

    if (intensity > 0) {
      textStyle = TextStyle(
        color: Colors.white,
        fontSize: 22.0,
        fontWeight: FontWeight.bold,
      );
    } else {
      textStyle = TextStyle(
        color: Colors.black,
        fontSize: 14.0,
        fontWeight: FontWeight.normal,
      );
    }

    TextSpan textSpan = intensity > 0
        ? TextSpan(
            text: '${intensity.toStringAsFixed(1)}',
            style: textStyle,
          )
        : TextSpan(
            text: 'Desligado',
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
