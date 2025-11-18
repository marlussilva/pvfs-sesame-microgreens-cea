// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:get_it/get_it.dart'; // Certifique-se de que o caminho do import está correto

import 'package:aplicacao_cliente_hibrida/store/constante_store.dart';
import 'package:my_api/model/environment_data.dart';
import 'package:aplicacao_cliente_hibrida/l10n/app_localizations.dart';

class ConstantePage extends StatefulWidget {
  EnvironmentData environmentData;
  Size size;
  ConstantePage({
    Key? key,
    required this.size,
    required this.environmentData,
  }) : super(key: key);

  @override
  _ConstantePageState createState() => _ConstantePageState();
}

class _ConstantePageState extends State<ConstantePage> {
  final ConstanteStore store = GetIt.I<ConstanteStore>();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    //store.setIntensidadeMaxima(250);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            _buildTimeSelectors(),
            _buildIntensityInput(),
            _buildConstanteChart(),
            const SizedBox(
              height: 8,
            ),
            _buildDli(),
            const SizedBox(
              height: 8,
            ),
            _buildConfigScoreboard(),
          ],
        ),
      ),
    );
  }

  Widget _buildDli() {
    return Observer(builder: (_) {
      return RichText(
        text: TextSpan(
          style: TextStyle(
            color: Colors.white, // Cor padrão para o resto do texto
          ),
          children: <TextSpan>[
            TextSpan(text: AppLocalizations.of(context)!.dailyLightIntegral),
            TextSpan(
              text: '${store.dli.toStringAsFixed(2)}',
              style: TextStyle(
                  color: Colors.blue,
                  fontWeight:
                      FontWeight.bold), // Definindo a cor azul para esta parte
            ),
            const TextSpan(text: ' mol m\u207B\u00B2 d\u207B\u00B9'),
          ],
        ),
      );
    });
  }

  Widget _buildConfigScoreboard() {
    return ElevatedButton(
        onPressed: () {
          store.sendCommandMqtt(
              "dimming",
              "${widget.environmentData.environment?.acronym}/dimming",
              store.sendGrausMQTT());
        },
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(AppLocalizations.of(context)!.saveToBoard),
            SizedBox(
              width: 16,
            ),
            Icon(Icons.save),
          ],
        ));
  }

  Widget _buildTimeSelectors() {
    return Observer(builder: (_) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          ElevatedButton(
            onPressed: () => _selectTime(context, true),
            child: Text(
                "${AppLocalizations.of(context)!.start} ${_formatDateTime(store.horarioInicio)}"),
          ),
          ElevatedButton(
            onPressed: () => _selectTime(context, false),
            child: Text(
                "${AppLocalizations.of(context)!.end} ${_formatDateTime(store.horarioFim)}"),
          ),
        ],
      );
    });
  }

  Widget _buildIntensityInput() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Observer(builder: (_) {
        return Column(
          children: <Widget>[
            Text(
                "${AppLocalizations.of(context)!.maxIntensity} ${store.intensidadeMaxima.toStringAsFixed(0)}"),
            Slider(
              value: store.intensidadeMaxima,
              min: 0,
              max: 750,
              divisions: 750,
              label: store.intensidadeMaxima.round().toString(),
              onChanged: (double value) {
                store.setIntensidadeMaxima(value);
              },
            ),
          ],
        );
      }),
    );
  }

  Future<void> _selectTime(BuildContext context, bool isStartTime) async {
    final DateTime currentTime =
        isStartTime ? store.horarioInicio : store.horarioFim;
    final TimeOfDay initialTime =
        TimeOfDay(hour: currentTime.hour, minute: currentTime.minute);
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: initialTime,
    );
    if (picked != null) {
      DateTime newTime = DateTime(
        currentTime.year,
        currentTime.month,
        currentTime.day,
        picked.hour,
        picked.minute,
      );
      if (isStartTime) {
        store.setHorarioInicio(newTime);
      } else {
        store.setHorarioFim(newTime);
      }
    }
  }

  String _formatDateTime(DateTime dateTime) {
    return MaterialLocalizations.of(context).formatTimeOfDay(
      TimeOfDay(hour: dateTime.hour, minute: dateTime.minute),
      alwaysUse24HourFormat: true,
    );
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
                  getTitlesWidget: bottomTitleWidgets,
                  reservedSize: 30,
                ),
              ),
              topTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: leftTitleWidgets,
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

  Widget bottomTitleWidgets(double value, TitleMeta meta) {
    var style = const TextStyle(
      color: Colors.white,
      fontWeight: FontWeight.bold,
      fontSize: 11,
    );
    var text = store.decimalParaHorario(value);

    return SideTitleWidget(
      axisSide: meta.axisSide,
      space: 8.0,
      child: Transform.rotate(
        angle: -pi / 2,
        child: Text(text, style: style),
      ),
    );
  }

  Widget leftTitleWidgets(double value, TitleMeta meta) {
    var style = const TextStyle(
      color: Colors.grey,
      fontWeight: FontWeight.bold,
      fontSize: 12,
    );
    return Text(value.toInt().toString(), style: style);
  }
}
