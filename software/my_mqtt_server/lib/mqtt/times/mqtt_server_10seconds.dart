import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:my_api/client_services/http/dio_iot_data.dart';
import 'package:my_api/model/iot_data.dart';

class MqttServer10Seconds {
  late DateTime serverStartTime;
  late MqttServerClient client;
  bool isDisconnectIntentional = false;
  List<String> topics = [];
  Map<String, Timer> collectionTimers = {};
  Map<String, IoTData> lastReceivedValue = {};

  MqttServer10Seconds(String host, String clientIdentifier) {
    serverStartTime = DateTime.now();
    client = MqttServerClient(host, clientIdentifier);
    client.logging(on: false);
    client.keepAlivePeriod = 20;
    client.onConnected = onConnected;
    client.onDisconnected = onDisconnected;
    client.setProtocolV311();
  }

  Future<void> subscribe(String topic) async {
    client.subscribe(topic, MqttQos.atLeastOnce);
    if (!topics.contains(topic)) {
      topics.add(topic);
      lastReceivedValue[topic] = IoTData(); // Inicializa com um objeto vazio ou um valor padrão adequado
      startCollectionTimer(topic);
    }
    client.updates!.listen((List<MqttReceivedMessage<MqttMessage?>>? c) {
      if (c == null || c.isEmpty) return;
      final MqttPublishMessage recMess = c[0].payload as MqttPublishMessage;
      final String message = MqttPublishPayload.bytesToStringAsString(recMess.payload.message);

      if (c[0].topic == topic) {
        processData(topic, message);
      }
    });
  }

  void processData(String topic, String message) {
    try {
      var value = jsonDecode(message);
      if (value != null) {
        var iot = IoTData.fromMap(value);
        iot.timestamp = DateTime.now();
        lastReceivedValue[topic] = iot; // Atualiza com o valor mais recente
      }
    } catch (e) {
      print("Error processing message: $e");
    }
  }

  void startCollectionTimer(String topic) {
    collectionTimers[topic]?.cancel(); // Cancela o timer anterior se existir
    collectionTimers[topic] = Timer.periodic(Duration(seconds: 10), (_) => saveDataImmediately(topic));
  }

  Future<void> saveDataImmediately(String topic) async {
    var data = lastReceivedValue[topic];
    if (data != null) {
      var uptime = DateTime.now().difference(serverStartTime);
      bool res = await DioIotData.saveIotData(data);
      if (res) {
        print('SAVE! ${data.mqttTopic} value ${data.value} ${data.timestamp}');
      } else {
        print('ERRO ao salvar Iot DATA! $res');
      }
      print('Dados salvos com sucesso. Tempo de atividade do servidor: ${uptime.inHours} horas, ${uptime.inMinutes % 60} minutos e ${uptime.inSeconds % 60} segundos.');
      print("");
    }
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

  void onConnected() {
    print('Client connection was successful');
    isDisconnectIntentional = false;
    topics.forEach((String topic) {
      client.subscribe(topic, MqttQos.atLeastOnce);
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

  Future<void> disconnect() async {
    isDisconnectIntentional = true;
    client.disconnect();
  }
}
