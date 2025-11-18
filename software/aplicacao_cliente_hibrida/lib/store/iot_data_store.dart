import 'dart:io';

import 'package:intl/intl.dart';
import 'package:mobx/mobx.dart';
import 'package:my_api/model/iot_data.dart';
import 'package:my_api/client_services/http/dio_iot_data.dart';
import 'package:path_provider/path_provider.dart';

import 'package:timezone/timezone.dart' as tz;

part 'iot_data_store.g.dart';

class IotDataStore = _IotDataStoreBase with _$IotDataStore;

abstract class _IotDataStoreBase with Store {
  @observable
  ObservableList<Map<String, dynamic>> iotDataList =
      ObservableList<Map<String, dynamic>>();

  @observable
  bool isLoading = false;

  @observable
  String errorMessage = '';

  @action
  Future<void> fetchIotDataByTimestampAndTopic(
      DateTime startTimestamp, DateTime endTimestamp, String mqttTopic) async {
    isLoading = true;
    errorMessage = '';
    try {
      final List<Map<String, dynamic>> result =
          await DioIotData.graficoSemInterpolacao(
        startTimestamp: startTimestamp,
        endTimestamp: endTimestamp,
        mqttTopic: mqttTopic,
      );

      // Não há necessidade de converter os dados, basta atualizar a lista
      iotDataList.clear();
      iotDataList.addAll(result);
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoading = false;
    }
  }

  @action
  Future<String> convertIotDataListToCsv() async {
    // Supondo que 'tz' já foi inicializado e configurado corretamente, como mostrado acima

    StringBuffer csv = StringBuffer();
    csv.write('\uFEFF'); // BOM para UTF-8
    // Adicionando cabeçalhos com ponto e vírgula como delimitador
    csv.writeln('"Received At";"MQTT Topic";"Numeric Value"');

    for (var data in iotDataList) {
      // Convertendo 'receivedAt' para o fuso horário de Brasília
      final receivedAt = tz.TZDateTime.from(DateTime.parse(data['receivedAt']),
          tz.getLocation('America/Sao_Paulo'));

      // Formatação da data/hora para o padrão brasileiro
      final formattedReceivedAt =
          DateFormat('dd/MM/yyyy HH:mm:ss', 'pt_BR').format(receivedAt);

      csv.writeln(
          '"$formattedReceivedAt";"${data['mqttTopic']}";"${data['numericValue']}"');
    }

    return csv.toString();
  }

  @action
  Future<File> saveCsvToFile(String csvString) async {
    final directory = await getApplicationDocumentsDirectory();
    final path = directory.path + "/iot_data.csv";
    final file = File(path);

    // Escrevendo o CSV no arquivo
    await file.writeAsString(csvString);

    return file;
  }
}
