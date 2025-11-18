import 'dart:math';
import 'package:aplicacao_cliente_hibrida/store/experiment_card_store.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';
import 'package:mobx/mobx.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:my_api/client_services/http/dio_iot_data.dart';

part 'generic_chart_store.g.dart'; // Gere este arquivo com o comando build_runner

class GenericChartStore = _GenericChartStore with _$GenericChartStore;

abstract class _GenericChartStore with Store {
  @observable
  ObservableList<FlSpot> spots = ObservableList<FlSpot>();

  @observable
  ObservableList<String> xLabels = ObservableList<String>();

  @observable
  double minX = 0;

  @observable
  double maxX = 0;

  @observable
  double minY = 0;

  @observable
  double maxY = 0;

  @observable
  DateTime chartStartTime = DateTime.now();

  @observable
  DateTime chartEndTime = DateTime.now().add(Duration(hours: 24));

  @action
  Future<void> consultGraphics(String mqttTopic) async {
    spots.clear();
    xLabels.clear();

    var result = await DioIotData.grafico(
      mqttTopic: mqttTopic,
      startTimestamp: chartStartTime,
      endTimestamp: chartEndTime,
    );

    var novo = result.map(
      (e) {
        var locations =
            tz.timeZoneDatabase.locations; // Para fins de debug e verificação

        // Substitua 'America/Sao_Paulo' pelo fuso horário específico do Brasil que você deseja utilizar
        tz.Location brazilLocation = tz.getLocation('America/Sao_Paulo');

        return {
          "date": tz.TZDateTime.from(DateTime.parse(e["date"]), brazilLocation),
          "averageValue": e["averageValue"]
        };
      },
    ).toList();

    result = novo;
    for (int i = 0; i < result.length; i++) {
      var data = result[i];
      DateTime date = data['date'];
      double yValue = double.parse(
          data['averageValue'].toString()); // Garante um valor padrão

      // Usando índices como valores de x
      double xValue = i.toDouble();

      // Formatação da data baseada na diferença entre startTime e endTime
      String formattedDate = DateFormat('dd/MM HH:mm').format(date);
      xLabels.add(formattedDate);
      spots.add(FlSpot(xValue, yValue));

      // Ajusta os limites do gráfico conforme necessário
      minX = 0; // Sempre começando de 0
      maxX = result.length.toDouble() - 1; // Baseado no número de pontos
      minY = min(minY, yValue);
      maxY = max(maxY, yValue);
    }
    //maxY *= 1.05; // adicionando 5 por cento
    double maxXValue =
        spots.reduce((curr, next) => curr.y > next.y ? curr : next).y;
    double minxValue =
        spots.reduce((curr, next) => curr.y < next.y ? curr : next).y;

    double delta = maxXValue - minxValue;

    double margem = delta * 0.1;

    maxY = maxXValue + margem;

    minY = minxValue - margem;

    GetIt.I<ExperimentCardStore>().setIsGeneratingGraphs(false);
    GetIt.I<ExperimentCardStore>().setShowGraphs(false);
    // Não é mais necessário ajustar manualmente os limites do gráfico aqui
  }

  @action
  void setChartStartTime(DateTime startTime) {
    chartStartTime = startTime;
  }

  @action
  void setChartEndTime(DateTime endTime) {
    chartEndTime = endTime;
  }
}
