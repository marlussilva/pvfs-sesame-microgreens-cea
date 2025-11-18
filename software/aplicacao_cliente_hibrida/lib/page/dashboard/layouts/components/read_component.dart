import 'package:aplicacao_cliente_hibrida/page/dashboard/layouts/components/cards/card_co2.dart';
import 'package:aplicacao_cliente_hibrida/page/dashboard/layouts/components/cards/card_humidity.dart';
import 'package:aplicacao_cliente_hibrida/page/dashboard/layouts/components/cards/card_intensity.dart';
import 'package:aplicacao_cliente_hibrida/page/dashboard/layouts/components/cards/card_kwh.dart';
import 'package:aplicacao_cliente_hibrida/page/dashboard/layouts/components/cards/card_led.dart';
import 'package:aplicacao_cliente_hibrida/page/dashboard/layouts/components/cards/card_ph.dart';
import 'package:aplicacao_cliente_hibrida/page/dashboard/layouts/components/cards/card_power_factor.dart';
import 'package:aplicacao_cliente_hibrida/page/dashboard/layouts/components/cards/card_temperature.dart';
import 'package:aplicacao_cliente_hibrida/page/dashboard/layouts/components/cards/card_watts.dart';
import 'package:aplicacao_cliente_hibrida/page/dashboard/layouts/components/cards/card_wifi.dart';
import 'package:aplicacao_cliente_hibrida/util/icons_imagens.dart';
import 'package:flutter/material.dart';
import 'package:my_api/model/environment_data.dart';
import 'package:my_api/model/iot_device.dart';

class ReadComponent extends StatefulWidget {
  final Size size;
  final EnvironmentData environmentData;

  const ReadComponent(
      {super.key, required this.size, required this.environmentData});

  @override
  State<ReadComponent> createState() => _ReadComponentState();
}

class _ReadComponentState extends State<ReadComponent> {
  Widget build(BuildContext context) {
    return Container(
      width: widget.size.width,
      // height: size.height,
      child: Column(
        children: _components(),
      ),
    );
  }

  List<Widget> _components() {
    //comentário
    List<IoTDevice>? devices = widget.environmentData.devices;
    List<String>? topics = widget.environmentData.topics;
    List<Widget> lista = [];

    if (devices == null || topics == null) return [];
    for (var i = 0; i < devices.length; i++) {
      var element = devices[i];
      var topic = topics[i];

      if (element.icon == IconsImage.intensity) {
        lista.add(
          CardIntensity(
            topic: topic,
            ioTDevice: element,
          ),
        );
      }

      if (element.icon == IconsImage.humidity) {
        lista.add(CardHumidity(
          ioTDevice: element,
          topic: topic,
        ));
      }
      if (element.icon == IconsImage.temperature) {
        lista.add(
          CardTemperature(
            topic: topic,
            ioTDevice: element,
          ),
        );
      }
      if (element.viewReturn != null) {
        bool view = element.viewReturn!;
        if (element.icon == IconsImage.led && view) {
          lista.add(
            CardLed(
              topic: topic,
              ioTDevice: element,
            ),
          );
        }
      }
      if (element.icon == IconsImage.co2) {
        lista.add(
          CardCo2(
            topic: topic,
            ioTDevice: element,
          ),
        );
      }
      if (element.icon == IconsImage.ph) {
        lista.add(
          CardPH(
            topic: topic,
            ioTDevice: element,
          ),
        );
      }
      if (element.icon == IconsImage.energy) {
        lista.add(
          CardKwh(
            topic: topic,
            ioTDevice: element,
          ),
        );
      }
      if (element.icon == IconsImage.watts) {
        lista.add(
          CardWatts(
            topic: topic,
            ioTDevice: element,
          ),
        );
      }
      if (element.icon == IconsImage.wifi) {
        lista.add(
          CardWifi(
            topic: topic,
            ioTDevice: element,
          ),
        );
      }
      print("${element.icon}   ${IconsImage.factor_power}");
      if (element.icon == IconsImage.factor_power) {
        lista.add(
          CardPowerFactor(
            topic: topic,
            ioTDevice: element,
          ),
        );
      }
    } //for

    return lista;
  }
}
