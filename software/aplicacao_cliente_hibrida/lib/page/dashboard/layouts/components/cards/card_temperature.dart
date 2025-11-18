import 'package:aplicacao_cliente_hibrida/page/dashboard/layouts/components/widgets/modern_thermometer.dart';
import 'package:aplicacao_cliente_hibrida/store/morden_thermometer_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:my_api/model/iot_device.dart';
import 'package:aplicacao_cliente_hibrida/l10n/app_localizations.dart';

class CardTemperature extends StatefulWidget {
  final String topic;
  final IoTDevice ioTDevice;

  const CardTemperature(
      {super.key, required this.topic, required this.ioTDevice});

  @override
  State<CardTemperature> createState() => _CardTemperatureState();
}

class _CardTemperatureState extends State<CardTemperature> {
  late MordenThermometerStore store;
  late Future _mqttFuture;

  Future<void> _connectAndSubscribe() async {
    await store.connectMqtt();
    await store.inscrever(widget.topic);
  }

  @override
  void initState() {
    super.initState();
    store = MordenThermometerStore();
    _mqttFuture = _connectAndSubscribe();
  }

  @override
  void dispose() {
    store.disconnect();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _mqttFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
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
                bool isMobile = MediaQuery.of(context).size.width < 600;
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        AppLocalizations.of(context)!.temperature,
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
                          ? ModernThermometer(
                              store.currentIotData!.value.toDouble(),
                              size: Size(60,
                                  MediaQuery.of(context).size.height * 0.35))
                          : Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  AppLocalizations.of(context)!.waitSensor,
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
