import 'package:aplicacao_cliente_hibrida/page/dashboard/layouts/components/widgets/co2_sensor_display.dart';
import 'package:aplicacao_cliente_hibrida/store/modern_led_light_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:my_api/model/iot_device.dart';

class CardCo2 extends StatefulWidget {
  final String topic;
  final IoTDevice ioTDevice;
  const CardCo2({super.key, required this.topic, required this.ioTDevice});

  @override
  State<CardCo2> createState() => _CardLedState();
}

class _CardLedState extends State<CardCo2> {
  late ModernLedLightStore store;
  late Future _mqttFuture;

  Future<void> _connectAndSubscribe() async {
    await store.connectMqtt();
    await store.inscrever(widget.topic);
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    store = ModernLedLightStore();
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
                bool isMobile = MediaQuery.of(context).size.width < 600;
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        widget.ioTDevice.name ?? "",
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
                          ? (isMobile)
                              ? CO2SensorDisplay(
                                  store.currentIotData!.value.toDouble(),
                                  size: Size(
                                      150,
                                      MediaQuery.of(context).size.height *
                                          0.35),
                                )
                              : Container(
                                  height: 100,
                                  width: 100,
                                  child: CO2SensorDisplay(
                                    store.currentIotData!.value.toDouble(),
                                    size: Size(
                                        80,
                                        MediaQuery.of(context).size.height *
                                            0.35),
                                  ))
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
