import 'dart:io';

import 'package:aplicacao_cliente_hibrida/store/environment_store.dart';
import 'package:aplicacao_cliente_hibrida/store/iot_data_store.dart';
import 'package:aplicacao_cliente_hibrida/util/time_convert.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';
import 'package:file_selector/file_selector.dart';
import 'package:path_provider/path_provider.dart' as path_provider;
import 'package:share_plus/share_plus.dart';

class IotDataQueryScreen extends StatefulWidget {
  @override
  _IotDataQueryScreenState createState() => _IotDataQueryScreenState();
}

class _IotDataQueryScreenState extends State<IotDataQueryScreen> {
  final IotDataStore _store = GetIt.I<IotDataStore>();
  final EnvironmentStore _environmentStore = GetIt.I<EnvironmentStore>();
  DateTime? _startDate;
  DateTime? _endDate;
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;

  String? _selectedTopic;

  @override
  Widget build(BuildContext context) {
    var topics = _environmentStore.environmentData?.topics ?? [];

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.read_more),
            SizedBox(width: 8),
            Text('Exportar Dados IoT', style: TextStyle(fontSize: 20)),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          children: <Widget>[
            topics.isNotEmpty
                ? Container(
                    height: MediaQuery.of(context).size.height *
                        0.3, // Ajuste conforme necessário
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: topics.length,
                      itemBuilder: (context, index) {
                        return RadioListTile<String>(
                          value: topics[index],
                          groupValue: _selectedTopic,
                          title: Text(topics[index]),
                          onChanged: (value) {
                            setState(() {
                              _selectedTopic = value;
                            });
                          },
                        );
                      },
                    ),
                  )
                : Container(),
            SizedBox(height: 20),
            ListTile(
              title: Text(
                'Data/Hora Inicial: ${_formatDateTime(_startDate, _startTime)}',
                style: TextStyle(fontSize: 12),
              ),
              trailing: Icon(Icons.calendar_today),
              onTap: () => _pickDateTime(isStart: true),
            ),
            ListTile(
              title: Text(
                'Data/Hora Final: ${_formatDateTime(_endDate, _endTime)}',
                style: TextStyle(fontSize: 12),
              ),
              trailing: Icon(Icons.calendar_today),
              onTap: () => _pickDateTime(isStart: false),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: _fetchData,
                  child: Text(
                    'Consultar Dados',
                    style: TextStyle(fontSize: 12),
                  ),
                ),
                SizedBox(width: 16),
                ElevatedButton(
                  onPressed: _exportAndShareCsv,
                  child:
                      Text('Exportar para CSV', style: TextStyle(fontSize: 12)),
                ),
              ],
            ),
            SizedBox(height: 20),
            Observer(
              builder: (_) =>
                  _store.isLoading ? CircularProgressIndicator() : Container(),
            ),
          ],
        ),
      ),
    );
  }

  void _exportAndShareCsv() async {
    setState(() {
      _store.isLoading = true;
    });

    try {
      await _fetchData();
      String csvString = await _store.convertIotDataListToCsv();
      String formattedDate = DateFormat('yyyyMMdd_HHmm').format(DateTime.now());
      String safeTopic =
          _selectedTopic!.replaceAll(RegExp('[^a-zA-Z0-9_]+'), '_');
      String fileName = 'topico_${safeTopic}_$formattedDate.csv';

      if (Platform.isAndroid || Platform.isIOS) {
        // Para Android e iOS, compartilha o arquivo CSV
        final directory = await path_provider.getTemporaryDirectory();
        String filePath = '${directory.path}/$fileName';
        File csvFile = File(filePath);
        await csvFile.writeAsString(csvString);

        await Share.shareXFiles([XFile(filePath)],
            text: 'Aqui estão seus dados IoT exportados.');
      } else if (Platform.isLinux || Platform.isWindows || Platform.isMacOS) {
        // Para desktop, permite ao usuário escolher o local para salvar o arquivo CSV
        FileSaveLocation? saveLocation = await getSaveLocation(
          acceptedTypeGroups: [
            XTypeGroup(label: 'files', extensions: ['csv'])
          ],
          suggestedName: fileName,
          confirmButtonText: 'Salvar',
        );

        if (saveLocation != null) {
          final String? outputPath = saveLocation.path;
          if (outputPath != null) {
            File csvFile = File(outputPath);
            await csvFile.writeAsString(csvString);
            ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("Dados IoT exportados: $outputPath")));
          } else {
            print("Falha ao obter o caminho do arquivo.");
          }
        } else {
          print("Usuário cancelou ou falhou ao salvar o arquivo.");
        }
      }
    } catch (e) {
      print('Erro ao exportar para CSV: $e');
    } finally {
      setState(() {
        _store.isLoading = false;
      });
    }
  }

  Future<void> _pickDateTime({required bool isStart}) async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (date != null) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );
      if (time != null) {
        setState(() {
          if (isStart) {
            _startDate = DateTime(
                date.year, date.month, date.day, time.hour, time.minute);
            _startTime = time;
          } else {
            _endDate = DateTime(
                date.year, date.month, date.day, time.hour, time.minute);
            _endTime = time;
          }
        });
      }
    }
  }

  String _formatDateTime(DateTime? date, TimeOfDay? time) {
    if (date == null || time == null) return 'Não selecionado';
    return DateFormat('dd/MM/yyyy HH:mm').format(
        DateTime(date.year, date.month, date.day, time.hour, time.minute));
  }

  Future<void> _fetchData() async {
    if (_startDate != null && _endDate != null && _selectedTopic!.isNotEmpty) {
      await _store.fetchIotDataByTimestampAndTopic(
          _startDate!, _endDate!, _selectedTopic!);
    }
  }
}
