import 'dart:math';

import 'package:flutter/material.dart';
import 'dart:math' as math;

class ResetEnergyButton extends StatefulWidget {
  final Size size;
  final VoidCallback onReset;

  ResetEnergyButton({required this.size, required this.onReset});

  @override
  State<ResetEnergyButton> createState() => _ResetEnergyButtonState();
}

class _ResetEnergyButtonState extends State<ResetEnergyButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  Color _buttonColor = Colors.blueAccent; // Estado inicial da cor do botão
  Color _iconColor = Colors.white; // Estado inicial da cor da seta

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        // Restaura a cor original ao final da animação
        setState(() {
          _buttonColor = Colors.blueAccent;
          _iconColor = Colors.white;
        });
        _controller.reset();
        widget.onReset();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTap() {
    // Muda a cor durante a animação
    setState(() {
      _buttonColor = Colors.greenAccent; // Nova cor do botão
      _iconColor = Colors.black; // Nova cor da seta
    });
    _controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handleTap,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (_, child) {
          return CustomPaint(
            size: widget.size,
            painter: ResetEnergyPainter(
              rotation: _controller.value * 2 * math.pi,
              buttonColor: _buttonColor,
              iconColor: _iconColor,
            ),
          );
        },
      ),
    );
  }
}

class ResetEnergyPainter extends CustomPainter {
  final double rotation;
  final Color buttonColor;
  final Color iconColor;

  ResetEnergyPainter({
    required this.rotation,
    required this.buttonColor,
    required this.iconColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = buttonColor;
    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width, size.height) / 2;

    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(rotation);
    canvas.drawCircle(Offset.zero, radius, paint);

    final textPainter = TextPainter(
      text: TextSpan(
        text: '↻',
        style: TextStyle(fontSize: radius / 2, color: iconColor),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
        canvas, Offset(-textPainter.width / 2, -textPainter.height / 2));
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
