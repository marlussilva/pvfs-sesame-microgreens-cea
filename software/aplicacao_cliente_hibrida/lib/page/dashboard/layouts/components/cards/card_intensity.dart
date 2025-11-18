import 'package:aplicacao_cliente_hibrida/page/dashboard/layouts/components/widgets/intensity_display_sensor.dart';
import 'package:aplicacao_cliente_hibrida/store/intesity_display_store.dart';

import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:my_api/model/iot_device.dart';
import 'package:aplicacao_cliente_hibrida/l10n/app_localizations.dart';

class CardIntensity extends StatefulWidget {
  final String topic;
  final IoTDevice ioTDevice;
  const CardIntensity(
      {super.key, required this.topic, required this.ioTDevice});

  @override
  State<CardIntensity> createState() => _CardIntensity();
}

class _CardIntensity extends State<CardIntensity> {
  late IntesityDisplayStore store;
  late Future _mqttFuture;

  Future<void> _connectAndSubscribe() async {
    await store.connectMqtt();
    await store.inscrever(widget.topic);
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    store = IntesityDisplayStore();
    _mqttFuture = _connectAndSubscribe();
  }

  @override
  void dispose() {
    store.disconnect();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool isMobile = MediaQuery.of(context).size.width < 600;

    return FutureBuilder(
      future: _mqttFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(),
          );
        } else if (snapshot.hasError) {
          return Center(
            child: Text('Erro: ${snapshot.error}'),
          );
        }

        return Center(
          child: Container(
            width: double.infinity,
            height: 200,
            margin: EdgeInsets.all(10),
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.grey[850],
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.5),
                  spreadRadius: 2,
                  blurRadius: 5,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: Center(
              child: Observer(builder: (_) {
                String title = "";
                print(widget.ioTDevice.name);
                if ("Intensidade Azul [PPFD]" == widget.ioTDevice.name) {
                  title = AppLocalizations.of(context)!.dimBlue;
                }
                if ("Intensidade  Branca [PPFD]" == widget.ioTDevice.name) {
                  title = AppLocalizations.of(context)!.dimWhite;
                }
                if ("Intensidade RBW [PPFD]" == widget.ioTDevice.name) {
                  title = AppLocalizations.of(context)!.dimRBW;
                }
                if ("Intensidade Vermelho [PPFD]" == widget.ioTDevice.name) {
                  title = AppLocalizations.of(context)!.dimRed;
                }
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        title,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: (isMobile) ? 18 : 12,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Expanded(
                      child: store.currentIotData != null &&
                              store.currentIotData!.value != null
                          ? LightIntensitySensorDisplay(
                              store.currentIotData!.value.toDouble(),
                              size: Size(150,
                                  MediaQuery.of(context).size.height * 0.8),
                            )
                          : Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "Sensor não enviou informação... Aguardando",
                                  style: TextStyle(color: Colors.white),
                                ),
                                SizedBox(height: 16),
                                CircularProgressIndicator(color: Colors.white),
                              ],
                            ),
                    ),
                  ],
                );
              }),
            ),
          ),
        );
      },
    );
  }
}
