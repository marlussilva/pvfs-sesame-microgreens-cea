import 'dart:math';

import 'package:aplicacao_cliente_hibrida/store/automatic_selector_store.dart';
import 'package:aplicacao_cliente_hibrida/store/constante_store.dart';
import 'package:aplicacao_cliente_hibrida/store/environment_store.dart';
import 'package:aplicacao_cliente_hibrida/store/experiment_card_store.dart';
import 'package:aplicacao_cliente_hibrida/store/generic_chart_store.dart';
import 'package:aplicacao_cliente_hibrida/store/iot_data_store.dart';
import 'package:aplicacao_cliente_hibrida/store/locale_store.dart';
import 'package:aplicacao_cliente_hibrida/store/mqtt_store.dart';
import 'package:aplicacao_cliente_hibrida/store/navigator_menu_store.dart';
import 'package:aplicacao_cliente_hibrida/store/responsive_store.dart';
import 'package:aplicacao_cliente_hibrida/store/tri_toggle_switch_store.dart';
import 'package:get_it/get_it.dart';
import 'package:my_api/config/my_config.dart';

class InitilizationApp {
  static Future<void> init() async {
    GetIt.I.registerSingleton(ResponsiveStore());
    GetIt.I.registerSingleton(await _connectMqtt());
    GetIt.I.registerSingleton(EnvironmentStore());
    GetIt.I.registerSingleton(TriToggleSwitchStore());
    GetIt.I.registerSingleton(AutomaticSelectorStore());
    GetIt.I.registerSingleton(ConstanteStore());
    GetIt.I.registerSingleton(IotDataStore());
    GetIt.I.registerSingleton(NavigatorMenuStore());

    GetIt.I.registerSingleton(ExperimentCardStore());
    GetIt.I.registerSingleton(GenericChartStore());
    GetIt.I.registerSingleton(LocaleStore());
  }

  static Future<MqttStore> _connectMqtt() async {
    var mqttStore;
    var rng = Random();
    int maxNumber = 999999999;
    int randomNumber = rng.nextInt(maxNumber);
    mqttStore = MqttStore(MyConfig.IP, "${randomNumber}client");

    try {
      await mqttStore.connect(MyConfig.USER_MQTT, MyConfig.PASSWORD_MQTT);
    } catch (e) {
      print("Falha ao conectar ao MQTT: $e");
      // Aqui você pode implementar lógicas adicionais em caso de falha,
      // como tentativas de reconexão ou notificações ao usuário.
    }
    return mqttStore;
  }
}
