import 'dart:convert';
import 'dart:math';

import 'package:aplicacao_cliente_hibrida/store/mqtt_store.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:mobx/mobx.dart';
import 'package:my_api/config/my_config.dart';
import 'package:my_api/model/iot_data.dart';
part 'constante_store.g.dart';

class ConstanteStore = _ConstanteStoreBase with _$ConstanteStore;

abstract class _ConstanteStoreBase with Store {
  _ConstanteStoreBase() {
    _connectMqtt();
  }
  final TextEditingController intensityMaxController = TextEditingController();
  @observable
  double intensidadeMaxima = 250.0;
  @observable
  DateTime horarioInicio = DateTime(
      DateTime.now().year, DateTime.now().month, DateTime.now().day, 6, 0);

  @observable
  DateTime horarioFim = DateTime(
      DateTime.now().year, DateTime.now().month, DateTime.now().day, 18, 0);

  @action
  void setHorarioInicio(DateTime horario) {
    horarioInicio = horario;
  }

  @action
  void setHorarioFim(DateTime horario) {
    horarioFim = horario;
  }

  @action
  void setIntensidadeMaxima(double v) {
    intensidadeMaxima = v;
    // Atualizar o texto do controlador apenas se o valor for diferente
    if (intensityMaxController.text != v.toString()) {
      intensityMaxController.text = v.toString();
    }
  }

  @computed
  double get horaDecimalInicio {
    return horarioInicio.hour + horarioInicio.minute / 60.0;
  }

  @computed
  int get segundosInicio {
    return horarioInicio.hour * 3600 + horarioInicio.minute * 60;
  }

  @computed
  double get horaDecimalFim {
    return horarioFim.hour + horarioFim.minute / 60.0;
  }

  @computed
  int get segundosFim {
    return horarioFim.hour * 3600 + horarioFim.minute * 60;
  }

  @computed
  double get deltaHoraDecimal {
    int secondsDiff = horarioFim.difference(horarioInicio).inSeconds;
    double hoursDiff = secondsDiff / 3600.0;
    return hoursDiff / 20;
  }

  @computed
  double get deltaHoraSegundos {
    return deltaHoraDecimal * 60 * 60;
  }

  String decimalParaHorario(double decimal) {
    int horas = decimal.toInt();
    int minutos = ((decimal - horas) * 60).round();
    return "${horas.toString().padLeft(2, '0')}:${minutos.toString().padLeft(2, '0')}";
  }

  @computed
  List<FlSpot> get calculoIntensidade {
    FlSpot inicioBase = FlSpot(horaDecimalInicio, 0);
    FlSpot inicioTopo = FlSpot(horaDecimalInicio, intensidadeMaxima);
    FlSpot fimTopo = FlSpot(horaDecimalFim, intensidadeMaxima);
    FlSpot fimBase = FlSpot(horaDecimalFim, 0);

    return [inicioBase, inicioTopo, fimTopo, fimBase];
  }

  @computed
  double get horaDecimalInicioAjustada {
    var horarioAjustado = horarioInicio.subtract(Duration(minutes: 30));
    return horarioAjustado.hour + horarioAjustado.minute / 60.0;
  }

  @computed
  double get horaDecimalFimAjustado {
    var horarioAjustado = horarioFim.add(Duration(minutes: 30));
    return horarioAjustado.hour + horarioAjustado.minute / 60.0;
  }

  @computed
  double get dli {
    // Calcula a duração do fotoperíodo em segundos
    int duracaoFotoperiodoSegundos =
        horarioFim.difference(horarioInicio).inSeconds;

    // Calcula a DLI usando a fórmula fornecida
    return intensidadeMaxima * duracaoFotoperiodoSegundos / (1000 * 1000);
  }

  @observable
  IoTData? ioTData;
  @action
  void setIotData(IoTData v) => ioTData = v;

  @action
  Future<bool> _connectMqtt() async {
    var rng = Random();
    int maxNumber = 999999999;
    int randomNumber = rng.nextInt(maxNumber);
    mqttStore = MqttStore(MyConfig.IP, "${randomNumber}client_constante");

    try {
      await mqttStore.connect(MyConfig.USER_MQTT, MyConfig.PASSWORD_MQTT);
      reaction((p0) => mqttStore.ioTData, (value) {
        if (value != null) setIotData(value);
      });
      return true;
    } catch (e) {
      print("Falha ao conectar ao MQTT: $e");
      return false;
      // Aqui você pode implementar lógicas adicionais em caso de falha,
      // como tentativas de reconexão ou notificações ao usuário.
    }
  }

  @action
  Future<void> inscrever(String topic) async {
    await mqttStore.subscribe(topic);
  }

  @action
  Future<void> disconnect() async {
    await mqttStore.disconnect();
  }

  late MqttStore mqttStore;
  @action
  void sendCommandMqtt(String command, String topic, String value) {
    Map<String, dynamic> messageJson = {
      "comando": command,
      "value": /*"oi bruno"*/ value
    };

    print(topic);
    print(messageJson);
    mqttStore
        .publish("$topic/cmd", jsonEncode(messageJson))
        .then((_) {})
        .catchError((error) {
      print('Falha ao enviar o comando: $error');
    });
  }

  @action
  String sendGrausMQTT() {
    List<FlSpot> intensidadeValues = calculoIntensidade;
    List<List<double>> matriz = [];

    List<FlSpot> aux = intensidadeValues.toList();
    if (aux.length > 1) {
      aux.removeAt(0);
      aux.removeAt(aux.length - 1);

      for (FlSpot spot in aux) {
        matriz.add([
          double.parse(spot.x.toStringAsFixed(6)),
          double.parse(spot.y.toStringAsFixed(0))
        ]);
      }
    }

    String jsonMatriz = jsonEncode(matriz);

    print(jsonMatriz);
    return jsonMatriz;
    // Aqui você pode enviar o jsonMatriz para onde precisar
  }
}
