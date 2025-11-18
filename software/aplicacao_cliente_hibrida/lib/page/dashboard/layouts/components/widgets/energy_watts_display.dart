import 'package:flutter/material.dart';

class EnergyWattsDisplay extends StatefulWidget {
  final double watts; // Consumo de energia em watts
  final Size size;

  const EnergyWattsDisplay({Key? key, required this.watts, required this.size})
      : super(key: key);

  @override
  _EnergyWattsDisplayState createState() => _EnergyWattsDisplayState();
}

class _EnergyWattsDisplayState extends State<EnergyWattsDisplay> {
  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: widget.size,
      painter: EnergyWattsPainter(
          watts: widget.watts, // Utiliza o valor diretamente sem animação
          maxWatts: 500), // Atualizado para considerar 500W como máximo
    );
  }
}

class EnergyWattsPainter extends CustomPainter {
  final double watts;
  final double maxWatts;

  EnergyWattsPainter({required this.watts, required this.maxWatts});

  @override
  void paint(Canvas canvas, Size size) {
    Paint backgroundPaint = Paint()
      ..color = Colors.grey.shade900
      ..style = PaintingStyle.fill;

    Paint progressPaint = Paint()
      ..color = _getColorForWatts(watts)
      ..style = PaintingStyle.fill;

    // Fundo da barra de progresso
    canvas.drawRect(
        Rect.fromLTWH(0, 0, size.width, size.height), backgroundPaint);

    // Barra de progresso
    double progressWidth = (watts / maxWatts) * size.width;
    canvas.drawRect(
        Rect.fromLTWH(0, 0, progressWidth, size.height), progressPaint);

    // Adiciona escala de marcação para cada 100W
    _drawScaleMarks(canvas, size);

    // Texto do consumo
    final textStyle = TextStyle(color: Colors.white, fontSize: 14);
    final textSpan =
        TextSpan(text: '${watts.toStringAsFixed(0)}W', style: textStyle);
    final textPainter = TextPainter(
        text: textSpan,
        textAlign: TextAlign.left,
        textDirection: TextDirection.ltr);
    textPainter.layout(minWidth: 0, maxWidth: size.width);
    textPainter.paint(
        canvas,
        Offset(size.width - textPainter.width - 10,
            (size.height - textPainter.height) / 2));
  }

  void _drawScaleMarks(Canvas canvas, Size size) {
    Paint scaleMarkPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    double markWidth = 2.0;
    double markHeight = 10.0;
    for (int i = 1; i < 5; i++) {
      // Desenha 4 marcas para 100W, 200W, 300W, 400W
      double xPos = (i / 5) * size.width;
      canvas.drawRect(
          Rect.fromLTWH(xPos - (markWidth / 2), 0, markWidth, markHeight),
          scaleMarkPaint);
      canvas.drawRect(
          Rect.fromLTWH(xPos - (markWidth / 2), size.height - markHeight,
              markWidth, markHeight),
          scaleMarkPaint);
    }
  }

  Color _getColorForWatts(double watts) {
    if (watts < 167) {
      // Ajustado para refletir a nova escala de 500W
      return Colors.lightGreenAccent;
    } else if (watts >= 167 && watts < 334) {
      return Colors.orangeAccent;
    } else {
      return Colors.redAccent;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
