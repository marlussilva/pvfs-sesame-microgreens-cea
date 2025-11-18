import 'package:flutter/material.dart';
import 'dart:math' as math;

class FuturisticHumiditySensor extends StatefulWidget {
  final dynamic humidity;
  final Size size;
  final bool animate; // Novo parâmetro para controlar a animação

  // O parâmetro 'animate' é opcional e o padrão é 'true'
  FuturisticHumiditySensor(
      {Key? key,
      required this.humidity,
      required this.size,
      this.animate = true})
      : super(key: key);

  @override
  _FuturisticHumiditySensorState createState() =>
      _FuturisticHumiditySensorState();
}

class _FuturisticHumiditySensorState extends State<FuturisticHumiditySensor>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    // Inicializar o AnimationController somente se 'animate' for true
    if (widget.animate) {
      _controller = AnimationController(
        duration: const Duration(milliseconds: 1000), // A duração da animação
        vsync: this,
      )..repeat(reverse: true); // Loop da animação

      _animation = Tween<double>(begin: 0.8, end: 1.2).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
      ); // Valores que a animação percorrerá
    }
  }

  @override
  void dispose() {
    if (widget.animate) {
      _controller
          .dispose(); // Garante que o controlador seja descartado para evitar vazamentos de memória
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Se 'animate' for true, retorna o AnimatedBuilder; caso contrário, retorna o widget padrão.
    if (widget.animate) {
      return AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          return Transform.scale(
            scale: _animation.value, // Aplica o valor da animação como escala
            child: child,
          );
        },
        child:
            _buildHumiditySensor(), // Extraímos a construção do sensor de umidade para um método separado
      );
    } else {
      return _buildHumiditySensor(); // Construção padrão sem animação
    }
  }

  // Método para construir o sensor de umidade (parte do widget que não muda com a animação)
  Widget _buildHumiditySensor() {
    return SizedBox(
      width: widget.size.width,
      height: widget.size.height,
      child: CustomPaint(
        painter:
            RadialPainter(progress: widget.humidity / 100, size: widget.size),
        child: Center(
          child: LayoutBuilder(builder: (context, constraints) {
            double fontSize =
                math.min(constraints.maxWidth, constraints.maxHeight) / 5;
            return Text(
              '${widget.humidity.toStringAsFixed(1)}%',
              style: TextStyle(fontSize: fontSize, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            );
          }),
        ),
      ),
    );
  }
}

class RadialPainter extends CustomPainter {
  final double progress;
  final Size size;

  RadialPainter({required this.progress, required this.size});

  @override
  void paint(Canvas canvas, Size size) {
    // Center of the canvas is the middle of the provided size
    Offset center = Offset(size.width / 2, size.height / 2);
    // Radius is calculated to fit within the provided size while allowing room for the stroke width
    double radius = math.min(size.width / 2, size.height / 2) - (3 / 2);

    var outerCirclePaint = Paint()
      ..color = Colors.grey[300]!
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    // Draw the outer circle using the above paint
    canvas.drawCircle(center, radius, outerCirclePaint);

    // Progress arc starts from 12 o'clock and draws clockwise
    var progressArcPaint = Paint()
      ..shader = LinearGradient(
        colors: [Colors.blue, Colors.blueAccent],
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5;

    // How much to draw based on the progress
    double progressAngle = 2 * math.pi * progress;

    // Draw the progress arc
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      progressAngle,
      false,
      progressArcPaint,
    );

    // Calculate angles and radius for the division lines
    double angle = (2 * math.pi) / 100; // The angle between each division
    double innerCircleRadius = radius - 12; // Where the division line starts

    // Draw the division lines
    for (int i = 0; i < 100; i++) {
      double x1 = center.dx + innerCircleRadius * math.cos(i * angle);
      double y1 = center.dy + innerCircleRadius * math.sin(i * angle);

      double x2 = center.dx + radius * math.cos(i * angle);
      double y2 = center.dy + radius * math.sin(i * angle);

      // Change the color based on if it is "past" the current progress point
      bool isPastProgress = ((i + 1) * angle) <= progressAngle + (math.pi / 2);
      var divisionPaint = Paint()
        ..color = isPastProgress ? Colors.blue : Colors.grey
        ..strokeCap = StrokeCap.round
        ..strokeWidth = 2;

      // Draw the line
      canvas.drawLine(Offset(x1, y1), Offset(x2, y2), divisionPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
