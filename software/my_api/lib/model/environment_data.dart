import 'package:my_api/model/environment.dart';
import 'package:my_api/model/iot_device.dart';

class EnvironmentData {
  Environment? environment;
  List<IoTDevice>? devices;
  List<String>? topics;

  EnvironmentData({
    this.environment,
    this.devices,
    this.topics,
  });

  EnvironmentData.fromMap(Map<String, dynamic> map) {
    if (map['environment'] != null) {
      environment = Environment.fromMap(map['environment']);
    }
    if (map['devices'] != null) {
      devices =
          List<IoTDevice>.from(map['devices'].map((x) => IoTDevice.fromMap(x)));
    }
    if (map['topics'] != null) {
      topics = List<String>.from(map['topics']);
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'environment': environment?.toMap(),
      'devices': devices?.map((x) => x.toMap()).toList(),
      'topics': topics,
    };
  }

  @override
  String toString() {
    return 'EnvironmentData {'
        'environment: $environment, '
        'devices: $devices, '
        'topics: $topics'
        '}';
  }
}
