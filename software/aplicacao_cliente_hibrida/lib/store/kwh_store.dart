import 'dart:convert';
import 'dart:math';

import 'package:aplicacao_cliente_hibrida/store/mqtt_store.dart';
import 'package:mobx/mobx.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:my_api/config/my_config.dart';
import 'package:my_api/model/iot_data.dart';
part 'kwh_store.g.dart';

class KwhStore = _KwhStoreBase with _$KwhStore;

abstract class _KwhStoreBase with Store {
  @observable
  IoTData? currentIotData;

  @action
  void setIotData(IoTData d) => currentIotData = d;

  late MqttStore mqttStore;

  @action
  Future<void> connectMqtt() async {
    var rng = Random();
    int maxNumber = 999999999;
    int randomNumber = rng.nextInt(maxNumber);
    mqttStore = MqttStore(MyConfig.IP, "${randomNumber}client_kwh");

    try {
      await mqttStore.connect(MyConfig.USER_MQTT, MyConfig.PASSWORD_MQTT);
      reaction((_) => mqttStore.ioTData, (value) {
        if (value != null) setIotData(value);
      });
    } catch (e) {
      print("Falha ao conectar ao MQTT: $e");
      // Aqui você pode implementar lógicas adicionais em caso de falha,
      // como tentativas de reconexão ou notificações ao usuário.
    }
  }

  @computed
  bool get isConnected {
    return mqttStore.client.connectionStatus?.state ==
        MqttConnectionState.connected;
  }

  @action
  Future<void> inscrever(String topic) async {
    await mqttStore.subscribe(topic);
  }

  @action
  void sendCommandMqtt(String command, String topic, double value) {
    Map<String, dynamic> messageJson = {
      "comando": command,
      "value": value.round().toString()
    };

    mqttStore.publish("$topic/cmd", jsonEncode(messageJson)).then((_) {
      print(messageJson);
    }).catchError((error) {
      print('Falha ao enviar o comando: $error');
    });
  }

  @action
  void disconnect() {
    mqttStore.disconnect();
  }
}
