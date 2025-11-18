import 'dart:io';
import 'dart:typed_data';

import 'package:aplicacao_cliente_hibrida/page/dashboard/layouts/components/charts/widgets/generic_chart.dart';
import 'package:aplicacao_cliente_hibrida/store/environment_store.dart';
import 'package:aplicacao_cliente_hibrida/store/experiment_card_store.dart';
import 'package:aplicacao_cliente_hibrida/store/generic_chart_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:get_it/get_it.dart';
import 'package:my_api/model/environment_data.dart';
import 'package:my_api/model/iot_device.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;
import 'dart:ui' as ui;
import 'package:share_plus/share_plus.dart';
import 'package:aplicacao_cliente_hibrida/l10n/app_localizations.dart';

class ExperimentCard extends StatefulWidget {
  const ExperimentCard({super.key});

  @override
  _ExperimentCardState createState() => _ExperimentCardState();
}

class _ExperimentCardState extends State<ExperimentCard> {
  EnvironmentData? environmentData;
  DateTime? startDate;
  DateTime? endDate;
  bool showGraphs = false;
  bool isLoading = false; // Estado para controlar o indicador de carregamento
  List<Widget> generatedGraphs = [];

  var store = GetIt.I<ExperimentCardStore>();

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  void _fetchData() async {
    setState(() {
      isLoading = true; // Ativa o indicador de carregamento
    });
    var store = GetIt.I<EnvironmentStore>();
    var res = await store.fetchEnvironmentAndDevices();
    print(res);
    setState(() {
      environmentData = res;
      isLoading =
          false; // Desativa o indicador de carregamento após a conclusão
    });
  }

  Future<void> _selectDateTime(BuildContext context, bool isStartDate) async {
    final DateTime now = DateTime.now();
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(now.year + 1, now.month, now.day),
    );
    if (pickedDate != null) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );
      if (pickedTime != null) {
        final DateTime result = DateTime(
          pickedDate.year,
          pickedDate.month,
          pickedDate.day,
          pickedTime.hour,
          pickedTime.minute,
        );
        setState(() {
          if (isStartDate) {
            startDate = result;
          } else {
            endDate = result;
          }
        });
      }
    }
  }



String getChartTitle(String apiTitle, AppLocalizations loc) {
  // Converte o título para minúsculas para facilitar as comparações
  final lowerTitle = apiTitle.toLowerCase();
   print("${lowerTitle} aqui   ${lowerTitle.contains("Indicador de força do sinal recebido")}");
  if (lowerTitle.contains("intensidade azul") && lowerTitle.contains("ppfd")) {
    return loc.ppfdBlue;
  } else if (lowerTitle.contains("intensidade branca") && lowerTitle.contains("ppfd")) {
    return loc.ppfdWhite;
  } else if (lowerTitle.contains("intensidade rbw") && lowerTitle.contains("ppfd")) {
    return loc.ppfdRBW;
  } else if (lowerTitle.contains("intensidade vermelho") && lowerTitle.contains("ppfd")) {
    return loc.ppfdRed;
  } else if (lowerTitle.contains("dimerização azul")) {
    return loc.dimBlue;
  } else if (lowerTitle.contains("dimerização branca")) {
    return loc.dimWhite;
  } else if (lowerTitle.contains("dimerização rbw")) {
    return loc.dimRBW;
  } else if (lowerTitle.contains("dimerização vermelha")) {
    return loc.dimRed;
  } else if (lowerTitle.contains("temperatura")) {
    return loc.temperature;
  } else if (lowerTitle.contains("umidade")) {
    return loc.humidity;
  } else if (lowerTitle.contains("ppm co2")) {
    return loc.ppmCo2;
  } else if (lowerTitle.contains("energia") || lowerTitle.contains("kwh")) {
    return loc.kWh;
  } else if (lowerTitle.contains("potência") || lowerTitle.contains("watts")) {
    return loc.watts;
  } else if (lowerTitle.contains("indicador de força do sinal recebido")) {
    return loc.wifi;
  } else if (lowerTitle.contains("fator de potência")) {
    return loc.factorPower;
  } else if (lowerTitle.contains("painel de luz") || lowerTitle.contains("painel de luzes")) {
    return loc.lightPanel;
  }

  // Se não houver correspondência, retorna o título original
  return apiTitle;
}








  void _generateAndShowGraphs(DateTime start, DateTime end) async {
    setState(() {
      isLoading = true; // Ativa o indicador de carregamento
    });

    if (environmentData == null) {
      print("Dados do ambiente não estão disponíveis.");
      setState(() {
        isLoading =
            false; // Desativa o indicador de carregamento se não houver dados
      });
      return;
    }

    List<Future> chartFutures =
        []; // Lista para armazenar as Futures das consultas
    List<IoTDevice>? devices = environmentData?.devices;
    List<String>? topics = environmentData?.topics;

    if (devices != null && topics != null) {
      for (var i = 0; i < devices.length; i++) {
        var element = devices[i];
        var topic = topics[i];

        var _store = GenericChartStore();
        _store.setChartStartTime(start);
        _store.setChartEndTime(end);

        // Armazena a Future da consulta em uma lista
        chartFutures.add(_store.consultGraphics(topic).then((_) {
          return Observer(builder: (_) {

            final localizedTitle = getChartTitle(element.name??'', AppLocalizations.of(context)!);


            return GenericChart(
              titulo: localizedTitle,
              xLabels: _store.xLabels,
              maxX: _store.maxX,
              minX: _store.minX,
              maxY: _store.maxY,
              minY: _store.minY,
              spots: _store.spots,
            );
          });
        }));
      }

      // Espera todas as consultas serem concluídas antes de atualizar o estado
      var graphsResults = await Future.wait(chartFutures);
      setState(() {
        generatedGraphs = graphsResults.cast<Widget>();
        showGraphs = true;
        isLoading =
            false; // Desativa o indicador de carregamento após todas as consultas
      });
    } else {
      // Caso não haja dispositivos ou tópicos, desativa o carregamento imediatamente
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                title: Text(
                    '${AppLocalizations.of(context)!.dateTimeSearchInit} ${startDate ?? ''}'),
                trailing: Icon(Icons.calendar_today),
                onTap: () => _selectDateTime(context, true),
              ),
              ListTile(
                title: Text(
                    '${AppLocalizations.of(context)!.dateTimeSearchEnd} ${endDate ?? ''}'),
                trailing: Icon(Icons.calendar_today),
                onTap: () => _selectDateTime(context, false),
              ),
              ElevatedButton(
                child: Text('Submit'),
                onPressed: () {
                  if (startDate == null || endDate == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                            'Por favor, selecione o período inicial e final.'),
                      ),
                    );
                    return;
                  }
                  if (endDate!.isBefore(startDate!)) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                            'Período final não pode ser antes do inicial.'),
                      ),
                    );
                    return;
                  }

                  // Chama o método para gerar e mostrar os gráficos
                  _generateAndShowGraphs(startDate!, endDate!);
                },
              ),
              if (isLoading)
                Column(
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(
                      height: 12,
                    ),
                    Observer(builder: (_) {
                      return Text("Consultando....");
                    }),
                  ],
                ) // Mostra o indicador de carregamento
              else if (showGraphs)
                ...generatedGraphs, // Mostra os gráficos após o carregamento
            ],
          ),
        ),
      ),
    );
  }
}
