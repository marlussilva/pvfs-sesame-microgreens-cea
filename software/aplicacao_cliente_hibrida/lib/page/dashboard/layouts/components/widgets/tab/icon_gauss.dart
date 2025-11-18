import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class IconGauss extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return LineChart(
      LineChartData(
        gridData: FlGridData(show: false),
        titlesData: FlTitlesData(show: false),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: getGaussianCurvePoints(),
            isCurved: false,

            barWidth: 2,
            isStrokeCapRound: false,
            dotData: FlDotData(show: false), // Esta linha remove os pontos
          ),
        ],
        lineTouchData: LineTouchData(
          enabled: false, // Desabilita interações de toque e tooltips
        ),
      ),
    );
  }

  List<FlSpot> getGaussianCurvePoints() {
    // Geração dos pontos para a curva de Gauss
    List<FlSpot> spots = [];

    double maxY = (1 / sqrt(2 * pi)); // Altura máxima da curva de Gauss
    double minY = 0; // Altura mínima (base da curva)
    double rangeY = maxY - minY; // Faixa total de Y

    for (double x = -4; x <= 4; x += 0.1) {
      double y = (1 / sqrt(2 * pi)) * exp(-x * x / 2);

      // Centralizar no eixo Y
      double normalizedY =
          (y - minY) / rangeY; // Normaliza Y para o intervalo [0, 1]

      spots.add(FlSpot(x, normalizedY));
    }

    return spots;
  }
}
