// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:intl/intl.dart';
import 'package:my_api/model/environment_data.dart';

import 'package:aplicacao_cliente_hibrida/store/gaussian_store.dart';
import 'package:aplicacao_cliente_hibrida/l10n/app_localizations.dart';

class GaussianPage extends StatefulWidget {
  EnvironmentData environmentData;
  Size size;
  GaussianPage({
    Key? key,
    required this.size,
    required this.environmentData,
  }) : super(key: key);
  @override
  _GaussianPageState createState() => _GaussianPageState();
}

class _GaussianPageState extends State<GaussianPage> {
  final GaussianStore store = GaussianStore();

  @override
  void initState() {
    super.initState();
    // store.setIntensidadeMaxima(500.0);
    //store.setIntensidadeMinima(100.0);
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: <Widget>[
          _buildParameterInputs(),
          _buildTimeSelectors(),
          SizedBox(height: 20),
          _buildGaussianChart(),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 16,
              ),
              _buildDli(),
              SizedBox(
                height: 16,
              ),
              _buildICE(),
              SizedBox(
                height: 16,
              ),
            ],
          ),
          _buildConfigScoreboard(),
        ],
      ),
    );
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

  Widget _buildICE() {
    return Observer(builder: (_) {
      return RichText(
        text: TextSpan(
          style: TextStyle(
            color: Colors.white, // Cor padrão para o resto do texto
          ),
          children: <TextSpan>[
            TextSpan(
                text:
                    AppLocalizations.of(context)!.constantEquivalentIntensity),
            TextSpan(
              text: ' ${store.calculoICE.toStringAsFixed(2)}',
              style: TextStyle(
                  color: Colors.blue,
                  fontWeight:
                      FontWeight.bold), // Definindo a cor azul para esta parte
            ),
            const TextSpan(text: ' \u00B5mol m\u207B\u00B2 s\u207B\u00B9'),
          ],
        ),
      );
    });
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
              text: ' ${store.integralDli.toStringAsFixed(2)}',
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

  Widget _buildParameterInputs() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: <Widget>[
          Row(
            children: [
              Text(
                "${AppLocalizations.of(context)!.mean}: ${store.mi.toStringAsFixed(1)}",
                style: TextStyle(color: Colors.white),
              ),
              SizedBox(
                width: 30,
              ),
              Expanded(
                child: Slider(
                  value: store.mi,
                  min: 0.0,
                  max: 10.0,
                  divisions: 100,
                  label: store.mi.toStringAsFixed(1),
                  onChanged: (double value) {
                    setState(() {
                      store.mi = value;
                    });
                  },
                ),
              ),
            ],
          ),
          Row(
            children: [
              Text(
                "${AppLocalizations.of(context)!.sigma}: ${store.sigma.toStringAsFixed(2)}",
                style: TextStyle(color: Colors.white),
              ),
              Expanded(
                child: Slider(
                  value: store.sigma,
                  min: 0.01,
                  max: 5.0,
                  divisions: 500,
                  label: store.sigma.toStringAsFixed(2),
                  onChanged: (double value) {
                    setState(() {
                      store.sigma = value;
                    });
                  },
                ),
              ),
            ],
          ),
          Row(
            children: [
              Expanded(
                child: Observer(builder: (_) {
                  return Column(
                    children: <Widget>[
                      Text(
                          "${AppLocalizations.of(context)!.maxIntensity}: ${store.intesidadeMaxima.toStringAsFixed(0)}"),
                      Slider(
                        value: store.intesidadeMaxima,
                        min: 0,
                        max: 750,
                        divisions: 750,
                        label: store.intesidadeMaxima.round().toString(),
                        onChanged: (double value) {
                          store.setIntensidadeMaxima(value);
                        },
                      ),
                    ],
                  );
                }),
              ),
              SizedBox(width: 8), // Espaço entre os campos
              Expanded(
                child: Observer(builder: (_) {
                  return Column(
                    children: <Widget>[
                      Text(
                          "${AppLocalizations.of(context)!.minIntensity}: ${store.intesidadeMinima.toStringAsFixed(0)}"),
                      Slider(
                        value: store.intesidadeMinima,
                        min: 0,
                        max: 750,
                        divisions: 750,
                        label: store.intesidadeMinima.round().toString(),
                        onChanged: (double value) {
                          store.setIntensidadeMinima(value);
                        },
                      ),
                    ],
                  );
                }),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildTimeSelectors() {
    return Observer(builder: (_) {
      return Column(
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              ElevatedButton(
                onPressed: () => _selectTime(context, true),
                child: Text(
                    "${AppLocalizations.of(context)!.start}: ${DateFormat('HH:mm').format(store.horarioInicio)}"),
              ),
              ElevatedButton(
                onPressed: () => _selectTime(context, false),
                child: Text(
                    "${AppLocalizations.of(context)!.end}: ${DateFormat('HH:mm').format(store.horarioFim)}"),
              ),
            ],
          ),
        ],
      );
    });
  }

  Widget _buildGaussianChart() {
    return Observer(
      builder: (_) => Container(
        height: 350,
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
            minX: store.horaDecimalInicio,
            maxX: store.horaDecimalFim,
            minY: 0,
            maxY: store.intesidadeMaxima + 100,
            lineBarsData: [
              LineChartBarData(
                spots: store.calculoIntensidade,
                isCurved: true,
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
    print(value);
    return Text(value.toInt().toString(), style: style);
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
}
