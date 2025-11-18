import 'package:aplicacao_cliente_hibrida/page/dashboard/layouts/components/widgets/ph_display.dart';
import 'package:aplicacao_cliente_hibrida/store/ph_display_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:my_api/model/iot_device.dart';

class CardPH extends StatefulWidget {
  final String topic;
  final IoTDevice ioTDevice;
  const CardPH({
    super.key,
    required this.topic,
    required this.ioTDevice,
  });

  @override
  State<CardPH> createState() => _CardPHState();
}

class _CardPHState extends State<CardPH> {
  late PhDiplayStore store;
  late Future _mqttFuture;

  Future<void> _connectAndSubscribe() async {
    await store.connectMqtt();
    await store.inscrever(widget.topic);
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    store = PhDiplayStore();
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
            margin: const EdgeInsets.all(10),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.grey[850],
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.5),
                  spreadRadius: 2,
                  blurRadius: 5,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Center(
              child: Observer(builder: (_) {
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        widget.ioTDevice.name ?? "",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Expanded(
                      child: store.currentIotData != null &&
                              store.currentIotData!.value != null
                          ? PHDisplay(
                              store.currentIotData!.value.toDouble(),
                              size: Size(150,
                                  MediaQuery.of(context).size.height * 0.35),
                            )
                          : const Column(
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
