import 'dart:math';

import 'package:my_api/client_services/http/dio_iot.dart';
import 'package:my_mqtt_server/mqtt/mqtt_server_control.dart';
import 'package:my_mqtt_server/mqtt/times/mqtt_server_10seconds.dart';
import 'package:my_mqtt_server/mqtt/util/mqtt_util.dart';
import 'package:my_api/config/my_config.dart';

Future<void> main(List<String> arguments) async {
  var random = Random();
  var control = MqttServerControl(MyConfig.IP, "my_api${random.nextInt(100)}");
  await control.connect("guest", "guest");
  MqttUtil util = MqttUtil();
  util.initTopics(control);
}
