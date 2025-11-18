import 'package:aplicacao_cliente_hibrida/store/constante_store.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:get_it/get_it.dart';

class IconLinear extends StatelessWidget {
  IconLinear({super.key});

  ConstanteStore store = GetIt.I<ConstanteStore>();

  @override
  Widget build(BuildContext context) {
    return _buildConstanteChart();
  }

  Widget _buildConstanteChart() {
    return Observer(
      builder: (_) => Container(
        height: 300,
        padding: EdgeInsets.all(10),
        child: LineChart(
          LineChartData(
            gridData: FlGridData(show: true),
            titlesData: FlTitlesData(
              show: true,
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  //  getTitlesWidget: bottomTitleWidgets,
                  reservedSize: 30,
                ),
              ),
              topTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  //   getTitlesWidget: leftTitleWidgets,
                  reservedSize: 30,
                ),
              ),
              rightTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: false,
                ),
              ),
            ),
            borderData: FlBorderData(show: true),
            minX: store.horaDecimalInicioAjustada,
            maxX: store.horaDecimalFimAjustado,
            minY: 0,
            maxY: store.intensidadeMaxima + 100,
            lineBarsData: [
              LineChartBarData(
                spots: store.calculoIntensidade,
                isCurved: false, // Definido como false para linhas retas
                color: Colors.blue,
                barWidth: 2,
                isStrokeCapRound: true,
                dotData: FlDotData(show: true),
                belowBarData: BarAreaData(show: false),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
