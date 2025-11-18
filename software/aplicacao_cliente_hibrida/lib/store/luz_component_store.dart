import 'dart:convert';
import 'dart:math';

import 'package:aplicacao_cliente_hibrida/store/mqtt_store.dart';
import 'package:get_it/get_it.dart';
import 'package:mobx/mobx.dart';
import 'package:my_api/config/my_config.dart';
import 'package:my_api/model/iot_data.dart';
part 'luz_component_store.g.dart';

class LuzComponentStore = _LuzComponentStoreBase with _$LuzComponentStore;

abstract class _LuzComponentStoreBase with Store {
  late MqttStore mqttStore;

  @observable
  double value = 0;
  @action
  void setValue(double v) => value = v;
  @observable
  IoTData? ioTData;
  @action
  void setIotData(IoTData v) => ioTData = v;

  Future<MqttStore> connectMqtt() async {
    var rng = Random();
    int maxNumber = 999999999;
    int randomNumber = rng.nextInt(maxNumber);
    mqttStore = MqttStore(MyConfig.IP, "${randomNumber}client");

    try {
      await mqttStore.connect(MyConfig.USER_MQTT, MyConfig.PASSWORD_MQTT);
      reaction((p0) => mqttStore.ioTData, (value) {
        if (value != null) setIotData(value);
      });
    } catch (e) {
      print("Falha ao conectar ao MQTT: $e");
      // Aqui você pode implementar lógicas adicionais em caso de falha,
      // como tentativas de reconexão ou notificações ao usuário.
    }
    return mqttStore;
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
  Future<void> disconnect() async {
    await mqttStore.disconnect();
  }
}
