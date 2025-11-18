import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:my_api/client_services/http/dio_iot.dart';
import 'package:my_api/client_services/http/dio_iot_data.dart';
import 'package:my_api/model/environment.dart';
import 'package:my_api/model/environment_data.dart';
import 'package:my_api/model/iot_data.dart';
import 'package:my_api/model/iot_device.dart';

class MqttServerControl {
  late MqttServerClient client;
  bool isDisconnectIntentional = false;
  List<String> topics = [];
  Map<String, List<IoTData>> topicMessages = {};
  Map<String, Timer> topicTimers = {};

  MqttServerControl(String host, String clientIdentifier) {
    client = MqttServerClient(host, clientIdentifier);
    client.logging(on: false);
    client.keepAlivePeriod = 20;
    client.onConnected = onConnected;
    client.onDisconnected = onDisconnected;
    client.onSubscribed = onSubscribed;
    client.pongCallback = pong;
    client.setProtocolV311();

    Timer.periodic(Duration(seconds: 10), (Timer t) {
      print("Current Time: ${DateTime.now()}");
    });
  }

  Future<void> connect(String username, String password) async {
    if (client.connectionStatus?.state == MqttConnectionState.connected) {
      print('Client already connected');
      return;
    }
    final connMess =
        MqttConnectMessage().authenticateAs(username, password).startClean();
    client.connectionMessage = connMess;
    try {
      await client.connect();
    } on NoConnectionException catch (e) {
      print('client exception - $e');
      client.disconnect();
    } on SocketException catch (e) {
      print('socket exception - ${e.message}');
      client.disconnect();
    }
    if (client.connectionStatus?.state == MqttConnectionState.connected) {
      topics.forEach((topic) {
        client.subscribe(topic, MqttQos.atLeastOnce);
      });
    }
  }

  Future<void> subscribe(String topic) async {
    if (client.connectionStatus!.state == MqttConnectionState.connected) {
      print('Subscribing to topic: $topic');
      client.subscribe(topic, MqttQos.atMostOnce);

      if (!topics.contains(topic)) {
        topics.add(topic);
      }

      client.updates!
          .listen((List<MqttReceivedMessage<MqttMessage?>>? c) async {
        if (c == null || c.isEmpty) {
          print('Received empty message');
          return;
        }

        final MqttPublishMessage recMess = c[0].payload as MqttPublishMessage;
        final String pt =
            MqttPublishPayload.bytesToStringAsString(recMess.payload.message);

        if (c[0].topic == topic) {
          processMessage(topic, pt);
        }
      });
    } else {
      print('ERROR::Client is not connected, cannot subscribe to the topic.');
    }
  }

  Future<void> processMessage(String topic, String message) async {
    try {
      var iotDataMap = jsonDecode(message);
      var iotData = IoTData.fromMap(iotDataMap);
      topicMessages.putIfAbsent(topic, () => []).add(iotData);

      if (!topicTimers.containsKey(topic)) {
        topicTimers[topic] = Timer.periodic(
            Duration(minutes: 1), (Timer t) => sendAverageAndReset(topic));
      }
    } catch (e) {
      print("Error processing message: $e");
    }
  }

  Future<void> sendAverageAndReset(String topic) async {
    var values = topicMessages[topic] ?? [];
    double sum = 0;
    values.forEach((data) {
      sum += double.tryParse(data.value.toString()) ?? 0;
    });

    double average = values.isNotEmpty ? sum / values.length : 0.0;

    var res = await DioIot.fetchDeviceByComposedKey(topic);
    var chave = res?.id;

    if (chave != null) {
      IoTData avgData = IoTData(
          value: average.toString(),
          mqttTopic: topic,
          timestamp: DateTime.now());
      avgData.deviceId = chave;

      topicMessages[topic] = [];
      topicTimers.remove(topic);

      saveAverageData(avgData);
    }
  }

  Future<void> saveAverageData(IoTData data) async {
    try {
      bool res = await DioIotData.saveIotData(data);
      if (res)
        print('Average IoT data saved successfully! $res');
      else
        print('ERRO ao salvar Iot DATA! $res');
    } catch (e) {
      print('Error saving average data: $e');
    }
  }

  Future<void> publish(String topic, String message) async {
    if (client.connectionStatus?.state == MqttConnectionState.connected) {
      final builder = MqttClientPayloadBuilder();
      builder.addString(message);
      client.publishMessage(topic, MqttQos.exactlyOnce, builder.payload!);
    } else {
      print('ERROR::Client is not connected, cannot publish');
    }
  }

  Future<void> disconnect() async {
    isDisconnectIntentional = true;
    client.disconnect();
  }

  void onConnected() {
    print('Client connection was successful');
    isDisconnectIntentional = false;
    topics.forEach((String topic) {
      client.subscribe(topic, MqttQos.atLeastOnce);
    });
  }

  void onDisconnected() {
    print('Disconnected');
    if (!isDisconnectIntentional) {
      print('Unexpected disconnection; attempting to reconnect...');
      _reconnect();
    }
  }

  void onSubscribed(String topic) {
    print('Subscription confirmed for topic $topic');
  }

  void pong() {
    print('Ping response client callback invoked');
  }

  Future<void> _reconnect() async {
    print('Attempting reconnection...');
    await connect(client.connectionMessage!.payload.username!,
        client.connectionMessage!.payload.password!);
  }
}






/*import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:my_api/client_services/http/dio_iot.dart';
import 'package:my_api/client_services/http/dio_iot_data.dart';
import 'package:my_api/model/environment.dart';
import 'package:my_api/model/environment_data.dart';
import 'package:my_api/model/iot_data.dart';
import 'package:my_api/model/iot_device.dart';

class MqttServerControl {
  late MqttServerClient client;
  bool isDisconnectIntentional =
      false; // Flag para verificar se a desconexão foi intencional
  List<String> topics = []; // Lista para manter os tópicos assinados

  MqttServerControl(String host, String clientIdentifier) {
    client = MqttServerClient(host, clientIdentifier);
    client.logging(on: true);
    client.keepAlivePeriod = 20;
    client.onConnected = onConnected;
    client.onDisconnected = onDisconnected;
    client.onSubscribed = onSubscribed;
    client.pongCallback = pong;
    client.setProtocolV311();
  }

  Future<void> connect(String username, String password) async {
    if (client.connectionStatus?.state == MqttConnectionState.connected) {
      print('Client already connected');
      return;
    }

    final connMess = MqttConnectMessage()
        .authenticateAs(username, password)
        .startClean(); // Sessão não persistente para teste
    client.connectionMessage = connMess;

    try {
      await client.connect();
    } on NoConnectionException catch (e) {
      print('client exception - $e');
      client.disconnect();
    } on SocketException catch (e) {
      print('socket exception - ${e.message}');
      client.disconnect();
    }

    // Reconectar-se automaticamente a todos os tópicos após conectar. Útil se a conexão cair e reconectar.
    if (client.connectionStatus?.state == MqttConnectionState.connected) {
      topics.forEach((topic) {
        client.subscribe(topic, MqttQos.atLeastOnce);
      });
    }
  }

  // ... restante do código, que permanece inalterado.

  Future<void> subscribe(String topic) async {
    if (client.connectionStatus!.state == MqttConnectionState.connected) {
      print('Subscribing to topic: $topic');

      client.subscribe(topic, MqttQos.atMostOnce);

      // Adicionando o tópico à lista de tópicos assinados se ainda não estiver lá
      if (!topics.contains(topic)) {
        topics.add(topic);
      }

      client.updates!
          .listen((List<MqttReceivedMessage<MqttMessage?>>? c) async {
        if (c == null || c.isEmpty) {
          print('Received empty message');
          return;
        }

        final MqttPublishMessage recMess = c[0].payload as MqttPublishMessage;
        final String pt =
            MqttPublishPayload.bytesToStringAsString(recMess.payload.message);

        print("Received message: $pt from topic: ${c[0].topic}");

        // Verificando se a mensagem recebida é do tópico assinado
        if (c[0].topic == topic) {
          try {
            // Seu código original para processar a mensagem recebida
            var res = await DioIot.fetchDeviceByComposedKey(topic);
            var chave = res?.id;
            if (chave != null) {
              var iotDataMap = jsonDecode(pt);
              var iotData = IoTData.fromMap(iotDataMap);
              iotData.deviceId = chave;
              iotData.mqttTopic = topic;

              await DioIotData.saveIotData(iotData);
            }
          } catch (e) {
            print("Error processing message: $e");
          }
        }
      });
    } else {
      print('ERROR::Client is not connected, cannot subscribe to the topic.');
      // Implementação de qualquer lógica de reconexão, se necessário, deve ser feita aqui.
    }
  }

  Future<void> publish(String topic, String message) async {
    if (client.connectionStatus?.state == MqttConnectionState.connected) {
      final builder = MqttClientPayloadBuilder();
      builder.addString(message);
      client.publishMessage(topic, MqttQos.exactlyOnce, builder.payload!);
    } else {
      print('ERROR::Client is not connected, cannot publish');
    }
  }

  Future<void> disconnect() async {
    isDisconnectIntentional = true; // Indicando que a desconexão é intencional
    client.disconnect();
  }

  // Callback functions
  void onSubscribed(String topic) {
    print('Subscription confirmed for topic $topic');
  }

  void onDisconnected() {
    print('Disconnected');
    if (!isDisconnectIntentional) {
      print('Unexpected disconnection; attempting to reconnect...');
      _reconnect();
    }
  }

  // Método para tentar reconectar
  Future<void> _reconnect() async {
    print('Attempting reconnection...');
    await connect(client.connectionMessage!.payload.username!,
        client.connectionMessage!.payload.password!); // Reutiliza credenciais
  }

  // Callbacks
  void onConnected() {
    print('Client connection was successful');
    isDisconnectIntentional = false; // Resetando o flag
    // Se necessário, reinscreva-se em tópicos aqui
    topics.forEach((String topic) {
      client.subscribe(topic, MqttQos.atLeastOnce);
    });
  }

  void pong() {
    print('Ping response client callback invoked');
  }
}
*/