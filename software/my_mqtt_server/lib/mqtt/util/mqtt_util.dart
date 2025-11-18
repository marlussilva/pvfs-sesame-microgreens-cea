import 'package:my_mqtt_server/mqtt/times/mqtt_server_10seconds.dart';

import '../mqtt_server_control.dart';
import 'package:my_api/client_services/http/dio_environment.dart';
import 'package:my_api/client_services/http/dio_iot.dart';

import 'package:my_api/model/environment.dart';
import 'package:my_api/model/iot_device.dart';

class MqttUtil {
  Future<List<String>> _fetchEnvironmentDeviceTopics() async {
    List<String> result = [];

    List<Environment> listEnv = await DioEnvironment.fetchEnvironments();

    for (var element in listEnv) {
      List<IoTDevice> listDev = await DioIot.fetchAll(element.id!);

      for (var e in listDev) {
        result.add("${element.acronym}/${e.topic}");
      }
    }
    return result;
  }

  Future<void> initTopics(MqttServerControl control) async {
    var list = await _fetchEnvironmentDeviceTopics();
    for (var element in list) {
      control.subscribe(element);
      print("sub:   $element");
    }
  }
  Future<void> initTopics10(MqttServer10Seconds control) async {
    var list = await _fetchEnvironmentDeviceTopics();
    for (var element in list) {
      control.subscribe(element);
      print("sub:   $element");
    }
  }
}
