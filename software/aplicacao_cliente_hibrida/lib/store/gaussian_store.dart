import 'dart:convert';

import 'package:aplicacao_cliente_hibrida/store/mqtt_store.dart';
import 'package:flutter/material.dart';
import 'package:mobx/mobx.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:math';

import 'package:my_api/config/my_config.dart';
import 'package:my_api/model/iot_data.dart';

part 'gaussian_store.g.dart';

class GaussianStore = _GaussianStore with _$GaussianStore;

abstract class _GaussianStore with Store {
  _GaussianStore() {
    _connectMqtt();
  }

  Future<bool> _connectMqtt() async {
    var rng = Random();
    int maxNumber = 999999999;
    int randomNumber = rng.nextInt(maxNumber);
    mqttStore = MqttStore(MyConfig.IP, "${randomNumber}client_gauss");

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

  @observable
  IoTData? ioTData;
  @action
  void setIotData(IoTData v) => ioTData = v;

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
  Future<void> inscrever(String topic) async {
    await mqttStore.subscribe(topic);
  }

  @action
  Future<void> disconnect() async {
    await mqttStore.disconnect();
  }

  late MqttStore mqttStore;

  final TextEditingController intensityMaxController = TextEditingController();
  final TextEditingController intensityMinController = TextEditingController();

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

  @action
  void setIntensidadeMaxima(double v) {
    intesidadeMaxima = v;
    intensityMaxController.text = intesidadeMaxima.toString();
  }

  @action
  void setIntensidadeMinima(double v) {
    intesidadeMinima = v;
    intensityMinController.text = intesidadeMinima.toString();
  }

  @observable
  double mi = 1.0;

  @observable
  double sigma = 0.32;

  @observable
  double intesidadeMaxima = 500.0;

  @observable
  double intesidadeMinima = 84.0;

  @observable
  double inicio = -1;

  @observable
  double delta = 0.1;

  @computed
  List<FlSpot> get gaussianCurve {
    int totalPoints = 21;
    List<FlSpot> curvePoints = [];
    double x = inicio + mi;
    double b2 = sigma;
    double b3 = mi;
    for (int i = 0; i < totalPoints; i++) {
      x = i == 0 ? 0.0 : x + delta;
      double y =
          1 / (b2 * sqrt(2 * pi)) * exp(-0.5 * pow(x - b3, 2) / pow(b2, 2));
      curvePoints.add(FlSpot(x, y));
    }
    return curvePoints;
  }

  @computed
  List<FlSpot> get normalizedGaussianCurve {
    List<FlSpot> curve = gaussianCurve;
    double maxY = curve.map((point) => point.y).reduce(max);
    return curve.map((point) => FlSpot(point.x, point.y / maxY)).toList();
  }

  /*@computed
  List<FlSpot> get calculoIntensidade {
    List<FlSpot> curve = normalizedGaussianCurve;
    List<FlSpot> intermediario = curve.map((e) {
      var sub = (intesidadeMaxima - intesidadeMinima);
      var mult = e.y * sub;
      return FlSpot(e.x, mult);
    }).toList();

    var calc =
        intermediario.map((e) => FlSpot(e.x, e.y + intesidadeMinima)).toList();

    
    for (var element in calc) {
      
    }

    return calc;
  }*/
  @computed
  List<FlSpot> get calculoIntensidade {
    List<FlSpot> curve = normalizedGaussianCurve;
    List<FlSpot> intermediario = curve.map((e) {
      var sub = (intesidadeMaxima - intesidadeMinima);
      var mult = e.y * sub;
      return FlSpot(e.x, mult);
    }).toList();

    var calc =
        intermediario.map((e) => FlSpot(e.x, e.y + intesidadeMinima)).toList();

    double horaAtualDecimal = horaDecimalInicio;
    for (int i = 0; i < calc.length; i++) {
      // Calcula o valor de hora decimal para o ponto atual
      if (i != 0) {
        horaAtualDecimal += deltaHoraDecimal;
      }

      int horas = horaAtualDecimal.toInt();
      double minutosDecimais = (horaAtualDecimal - horas) * 60;
      double xValue = horas + minutosDecimais / 60.0;

      // Atualiza o valor de x para cada FlSpot
      calc[i] = FlSpot(xValue, calc[i].y);
    }

    return calc;
  }

  @action
  String sendGrausMQTT() {
    List<FlSpot> intensidadeValues = calculoIntensidade;
    List<List<double>> matriz = [];

    for (FlSpot spot in intensidadeValues) {
      matriz.add([
        double.parse(spot.x.toStringAsFixed(6)),
        double.parse(spot.y.toStringAsFixed(0))
      ]);
    }

    String jsonMatriz = jsonEncode(matriz);

    print(jsonMatriz);
    return jsonMatriz;
    // Aqui você pode enviar o jsonMatriz para onde precisar
  }

  @action
  String decimalParaHorario(double decimal) {
    int horas = decimal.toInt();
    int minutos = ((decimal - horas) * 60).round();
    return "${horas.toString().padLeft(2, '0')}:${minutos.toString().padLeft(2, '0')}";
  }

  List<String> get calcHoraDecimal {
    var intermediario = calculoIntensidade;
    List<String> res = [];
    double aux = 0;
    var decimalHora = horaDecimalInicio;
    for (var element in intermediario) {
      decimalHora = decimalHora + aux;
      aux = deltaHoraDecimal;

      res.add(decimalParaHorario(decimalHora));
    }

    return res;
  }

  @computed
  double get integralDli {
    List<FlSpot> intensidade = calculoIntensidade;

    double res;
    List<double> l = [];
    for (var i = 0; i < intensidade.length; i++) {
      if (i > 0) {
        // print("${intensidade[i].y} +  ${intensidade[i - 1].y}");
        res = (intensidade[i].y + intensidade[i - 1].y) *
            deltaHoraSegundos /
            2 /
            (1000 * 1000);
      } else
        res = 0;
      l.add(res);
    }
    return l.reduce((value, element) => value + element);
  }

  @computed
  double get calculoICE {
    var periodo = segundosFim - segundosInicio;
    print("periodo $periodo");
    print("periodo $integralDli");

    return integralDli * 1000.00 * 1000.00 / periodo;
  }
}
