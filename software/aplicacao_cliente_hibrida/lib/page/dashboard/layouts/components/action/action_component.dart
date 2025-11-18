import 'package:aplicacao_cliente_hibrida/page/dashboard/layouts/components/action/component/card_action_reset_kwh.dart';
import 'package:aplicacao_cliente_hibrida/page/dashboard/layouts/components/widgets/tri_toggle_switch.dart';
import 'package:aplicacao_cliente_hibrida/util/icons_imagens.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:my_api/model/environment_data.dart';
import 'package:my_api/model/iot_device.dart';

class ActionComponent extends StatelessWidget {
  final Size size;
  final EnvironmentData environmentData;

  const ActionComponent(
      {super.key, required this.size, required this.environmentData});

  Widget build(BuildContext context) {
    return Container(
      width: size.width,
      // height: size.height,
      child: Column(
        children: _components(),
      ),
    );
  }

  List<Widget> _components() {
    List<IoTDevice>? devices = environmentData.devices;
    List<Widget> lista = [];
    if (devices == null) return [];

    for (var element in devices) {
      if (element.icon == IconsImage.switch_on) {
        lista.add(
          Observer(builder: (_) {
            return TriToggleSwitch(
              device: element,
              environmentData: environmentData,
              size: size,
            );
          }),
        );
      }
      if (element.icon == IconsImage.factor_power) {
        lista.add(
          Observer(builder: (_) {
            return CardActionResetKwh(
              device: element,
              environmentData: environmentData,
              size: size,
            );
          }),
        );
      }
    }
    return lista;
  }
}
