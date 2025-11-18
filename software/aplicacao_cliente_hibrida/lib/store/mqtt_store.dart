import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:mobx/mobx.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:my_api/model/iot_data.dart';
part 'mqtt_store.g.dart';

class MqttStore = _MqttStoreBase with _$MqttStore;

abstract class _MqttStoreBase with Store {
  late MqttServerClient client;
  bool _isDisconnectIntentional = false;
  Timer? _reconnectTimer;
  String? _username;
  String? _password;

  @observable
  String latestMessage = '';

  @observable
  IoTData? ioTData;

  @action
  void setIotData(IoTData data) {
    ioTData = data;
  }

  @observable
  String value = '';

  @action
  void setValue(String v) => value = v;

  _MqttStoreBase(String host, String clientIdentifier) {
    client = MqttServerClient(host, clientIdentifier);
    client.onConnected = onConnected;
    client.onDisconnected = onDisconnected;
    client.onSubscribed = onSubscribed;
    client.pongCallback = pong;
  }

  @computed
  bool get isConnected {
    return client.connectionStatus?.state == MqttConnectionState.connected;
  }

  @action
  Future<bool> connect(String username, String password) async {
    _username = username;
    _password = password;
    _isDisconnectIntentional = false;

    if (client.connectionStatus?.state == MqttConnectionState.connected) {
      return false;
    }

    client.logging(on: false);
    client.setProtocolV311();
    client.keepAlivePeriod = 20;
    client.connectTimeoutPeriod = 2000; // milliseconds

    final connMess = MqttConnectMessage()
        .authenticateAs(username, password)
        .startClean(); // Sessão não persistente para teste

    client.connectionMessage = connMess;

    try {
      await client.connect();
      return client.connectionStatus?.state == MqttConnectionState.connected;
    } on NoConnectionException catch (e) {
      print('ERROR::NoConnectionException - $e');
      client.disconnect();
      return false;
    } on SocketException catch (e) {
      print('ERROR::SocketException - ${e.message}');
      client.disconnect();
      return false;
    } catch (e) {
      print('ERROR::Unknown exception - $e');
      client.disconnect();
      return false;
    }
  }

  @action
  Future<void> subscribe(String topic) async {
    try {
      if (client.connectionStatus!.state == MqttConnectionState.connected) {
        client.subscribe(topic, MqttQos.atMostOnce);

        client.updates!.listen((List<MqttReceivedMessage<MqttMessage?>>? c) {
          final recMess = c![0].payload as MqttPublishMessage;
          final pt =
              MqttPublishPayload.bytesToStringAsString(recMess.payload.message);

          if (c[0].topic == topic) {
            latestMessage = pt;
            final Map<String, dynamic> jsonMap = json.decode(latestMessage);
            setIotData(IoTData.fromMap(jsonMap));
            setValue(ioTData?.value?.toString() ?? '');
          }
        });
      } else {
        print('ERROR::Client is not connected, cannot subscribe');
      }
    } catch (e) {
      print('ERROR::Exception during subscribe - $e');
      // Aqui você pode adicionar mais lógica de tratamento de erro conforme necessário.
    }
  }

  @action
  Future<void> publish(String topic, String message) async {
    final builder = MqttClientPayloadBuilder();
    builder.addString(message);

    client.publishMessage(topic, MqttQos.atMostOnce, builder.payload!);
  }

  @action
  Future<void> disconnect() async {
    _isDisconnectIntentional = true;
    _reconnectTimer?.cancel();
    client.disconnect();
  }

  // Callback functions
  void onSubscribed(String topic) {
    print('Subscription confirmed for topic $topic');
  }

  void onDisconnected() {
    print('Client disconnection');
    if (!_isDisconnectIntentional &&
        client.connectionStatus?.state != MqttConnectionState.connected) {
      _reconnectTimer?.cancel(); // Cancela qualquer timer anterior
      _reconnectTimer = Timer(const Duration(seconds: 3), () async {
        print('Attempting to reconnect');
        await connect(_username!, _password!);
      });
    }
  }

  void onConnected() {
    print('Client connection was successful');
  }

  void pong() {
    print('Ping response client callback invoked');
  }
}
