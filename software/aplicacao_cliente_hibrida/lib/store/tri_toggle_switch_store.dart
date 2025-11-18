// tri_toggle_switch_store.dart
import 'dart:convert';
import 'dart:math';

import 'package:aplicacao_cliente_hibrida/store/mqtt_store.dart';
import 'package:get_it/get_it.dart';
import 'package:mobx/mobx.dart';
import 'package:my_api/config/my_config.dart';
import 'package:my_api/model/iot_data.dart';

part 'tri_toggle_switch_store.g.dart';

class TriToggleSwitchStore = _TriToggleSwitchStoreBase
    with _$TriToggleSwitchStore;

abstract class _TriToggleSwitchStoreBase with Store {
  _TriToggleSwitchStoreBase() {
    _connectMqtt();
  }

  @observable
  bool status = false;

  @action
  void setStatus(bool v) => status = v;

  @observable
  int currentIndex = 0; // Este é o valor que queremos observar.

  @action
  void setIndex(int index) {
    currentIndex = index; // Ação para alterar o índice.
  }

  late MqttStore mqttStore;

  @observable
  IoTData? ioTData;
  @action
  void setIotData(IoTData v) => ioTData = v;

  Future<bool> _connectMqtt() async {
    var rng = Random();
    int maxNumber = 999999999;
    int randomNumber = rng.nextInt(maxNumber);
    mqttStore = MqttStore(MyConfig.IP, "${randomNumber}client_tri_toggle");

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
  void sendCommandMqtt(String command, String topic, double value) {
    Map<String, dynamic> messageJson = {
      "comando": command,
      "value": value.round().toString()
    };

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
}
