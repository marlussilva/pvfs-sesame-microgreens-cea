import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:my_api/client_services/http/dio_environment.dart';
import 'package:my_api/client_services/http/dio_iot.dart';
import 'package:my_api/client_services/http/dio_iot_data.dart';
import 'package:my_api/model/environment.dart';
import 'package:my_api/model/iot_data.dart';

class MqttServerControl {
  late DateTime serverStartTime;
  Map<String, bool> environmentOnlineStatus = {};

  late MqttServerClient client;
  bool isDisconnectIntentional = false;
  List<String> topics = [];
  Map<String, List<IoTData>> topicValues = {};
  Map<String, Timer> collectionTimers = {};
  Map<String, DateTime> lastSaveTime = {};
  Map<String, IoTData> lastReceivedValue = {};
  Map<String, Timer> saveDataTimers = {}; // Adiciona esta linha
  Map<String, bool> lastEnvironmentStatus = {};

  MqttServerControl(String host, String clientIdentifier) {
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
      topicValues[topic] = [];
      lastSaveTime[topic] = DateTime.now();
      startCollectionTimer(topic);
    }
    client.updates!.listen((List<MqttReceivedMessage<MqttMessage?>>? c) {
      if (c == null || c.isEmpty) return;
      final MqttPublishMessage recMess = c[0].payload as MqttPublishMessage;
      final String message =
          MqttPublishPayload.bytesToStringAsString(recMess.payload.message);

      if (c[0].topic == topic) {
        processData(topic, message);
      }
    });
  }

  void processData(String topic, String message) {
    var environment = topic.split('/')[0];
    environmentOnlineStatus[environment] = true;

    try {
      var value = jsonDecode(message);
      if (value != null) {
        var iot = IoTData.fromMap(value);
        iot.timestamp = DateTime.now();
        lastReceivedValue[topic] = iot;
        lastSaveTime[topic] = DateTime.now();
      }
    } catch (e) {
      print("Error processing message: $e");
    }
  }

  void startCollectionTimer(String topic) {
    collectionTimers[topic] = Timer.periodic(Duration(seconds: 1), (_) {
      if (lastReceivedValue.containsKey(topic)) {
        topicValues[topic]?.add(lastReceivedValue[topic]!);
      }
    });

    saveDataTimers[topic] = Timer.periodic(Duration(seconds: 10), (_) {
      var environment = topic.split('/')[0];
      if (environmentOnlineStatus[environment] ?? false) {
        // Só salva se o ambiente estiver online
        if (topicValues[topic]?.isNotEmpty ?? false) {
          saveData(topic);
        }
      } else {
        // print("Ambiente $environment está offline. Dados não serão salvos.");
      }
    });

    Timer.periodic(Duration(seconds: 5), (_) {
      String environment = topic.split('/')[0];
      bool environmentIsActive = false;
      topics.where((t) => t.startsWith(environment)).forEach((t) {
        if (DateTime.now().difference(lastSaveTime[t]!).inSeconds <= 5) {
          environmentIsActive = true;
        }
      });

      // Chama checkEnvironmentStatus com o estado correto
      checkEnvironmentStatus(environment, environmentIsActive);
    });
  }

  Future<void> checkEnvironmentStatus(String environment, bool isOnline) async {
    // Verifica diretamente se há uma mudança de status comparando com o valor atual em environmentOnlineStatus
    if (!lastEnvironmentStatus.containsKey(environment) ||
        lastEnvironmentStatus[environment] != isOnline) {
      // Atualiza o último estado conhecido para refletir a mudança
      lastEnvironmentStatus[environment] = isOnline;
      print("last $lastEnvironmentStatus");
      // Atualiza o status online atual
      environmentOnlineStatus[environment] = isOnline;
      print("envirtonmentStatus ${environmentOnlineStatus}");
      // Imprime a mensagem baseada no novo estado
      if (isOnline) {
        Environment env =
            await DioEnvironment.fetchEnvironmentByAcronym(environment);
        env.status = ConnectionStatus.online;
        await DioEnvironment.updateEnvironmentStatus(env);
        print("Ambiente $environment está online. $env");
      } else {
        Environment env =
            await DioEnvironment.fetchEnvironmentByAcronym(environment);
        env.status = ConnectionStatus.offline;
        await DioEnvironment.updateEnvironmentStatus(env);
        print("Ambiente $environment está offline. Dados não serão salvos.");
        print("envirtonmentStatus $environmentOnlineStatus");
      }
    }
  }

  Future<void> saveData(String topic) async {
    var environment = topic.split('/')[0];
    if (!(environmentOnlineStatus[environment] ?? true)) {
      // Assume true por padrão
      print("Ambiente $environment está offline. Dados não serão salvos.");
      return; // Sai do método sem salvar os dados
    }

    // Continua com a lógica de salvamento se o ambiente estiver online...
    var values = topicValues[topic] ?? [];
    double sum = 0;
    for (var data in values) {
      sum += double.tryParse(data.value.toString()) ?? 0;
    }

    double average = values.isNotEmpty ? sum / values.length : 0.0;

    var res = await DioIot.fetchDeviceByComposedKey(topic);
    var chave = res?.id;

    if (chave != null) {
      IoTData avgData = IoTData(
          value: average.toString(),
          mqttTopic: topic,
          timestamp: DateTime.now().toUtc());
      avgData.deviceId = chave;

      topicValues[topic] = [];
      await saveAverageData(avgData);
    }
  }

  Future<void> saveAverageData(IoTData data) async {
    try {
      bool res = await DioIotData.saveIotData(data);
      if (res) {
        print('SAVE! ${data.mqttTopic} value ${data.value} ${data.timestamp}');
      } else {
        print('ERRO ao salvar Iot DATA! $res');
      }
    } catch (e) {
      print('Error saving average data: $e');
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
    // Cancel all timers on disconnect
    collectionTimers.forEach((_, timer) => timer.cancel());
    saveDataTimers.forEach((_, timer) => timer.cancel());
  }
}
