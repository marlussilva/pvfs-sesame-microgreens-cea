import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';
import 'package:my_api/model/iot_data.dart';

class CsvExporter {
  // Função para gerar e salvar o CSV
  Future<File> exportIotDataToCsv(List<IoTData> dataList) async {
    // Obtém o diretório onde o arquivo será salvo.
    // Por exemplo, usa o diretório de documentos para o aplicativo.
    final directory = await getApplicationDocumentsDirectory();
    final path = '${directory.path}/iot_data.csv';
    final file = File(path);

    // Cria um StringBuffer para construir o conteúdo do CSV.
    final StringBuffer csv = StringBuffer();

    // Adiciona o cabeçalho do arquivo CSV.
    csv.writeln('ID;Value;Timestamp;Received At;Device ID;MQTT Topic;Unit');

    // Formata os dados para o CSV.
    for (final data in dataList) {
      final id = data.id?.toHexString() ?? '';
      final value = data.value.toString();
      final timestamp = data.timestamp != null
          ? DateFormat('yyyy-MM-ddTHH:mm:ss').format(data.timestamp!)
          : '';
      final receivedAt = data.receivedAt != null
          ? DateFormat('yyyy-MM-ddTHH:mm:ss').format(data.receivedAt!)
          : '';
      final deviceId = data.deviceId?.toHexString() ?? '';
      final mqttTopic = data.mqttTopic ?? '';
      final unit = data.unit ?? '';

      // Adiciona os dados ao CSV, usando ponto e vírgula (;) como separador.
      csv.writeln(
          '$id;$value;$timestamp;$receivedAt;$deviceId;$mqttTopic;$unit');
    }

    // Escreve o conteúdo no arquivo e o retorna.
    await file.writeAsString(csv.toString());
    return file;
  }
}
