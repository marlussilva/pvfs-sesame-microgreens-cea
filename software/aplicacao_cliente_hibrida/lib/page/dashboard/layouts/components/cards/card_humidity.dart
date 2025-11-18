import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:aplicacao_cliente_hibrida/page/dashboard/layouts/components/widgets/futuristic_humidity_sensor.dart';
import 'package:aplicacao_cliente_hibrida/store/futuristic_humidity_sensor_store.dart';
import 'package:my_api/model/iot_device.dart';
import 'package:aplicacao_cliente_hibrida/l10n/app_localizations.dart';

class CardHumidity extends StatefulWidget {
  final String topic;
  final IoTDevice ioTDevice;

  CardHumidity({
    Key? key,
    required this.topic,
    required this.ioTDevice,
  }) : super(key: key);

  @override
  State<CardHumidity> createState() => _CardHumidityState();
}

class _CardHumidityState extends State<CardHumidity> {
  late FuturisticHumiditySensorStore store;
  late Future _mqttFuture;

  @override
  void initState() {
    super.initState();
    store = FuturisticHumiditySensorStore();
    _mqttFuture = _connectAndSubscribe();
  }

  Future<void> _connectAndSubscribe() async {
    await store.connectMqtt();
    await store.inscrever(widget.topic);
  }

  @override
  void dispose() {
    store.disconnect();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
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
                var isMobile = MediaQuery.of(context).size.width < 600;

                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        AppLocalizations.of(context)!.humidity,
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
                          ? FractionallySizedBox(
                              widthFactor: 0.8,
                              heightFactor: 0.8,
                              child: FuturisticHumiditySensor(
                                humidity:
                                    store.currentIotData!.value.toDouble(),
                                size: size,
                              ),
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
