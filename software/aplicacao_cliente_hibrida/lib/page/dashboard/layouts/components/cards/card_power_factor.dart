// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:aplicacao_cliente_hibrida/page/dashboard/layouts/components/widgets/power_factor_indicator.dart';
import 'package:aplicacao_cliente_hibrida/store/power_factor_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:my_api/model/iot_device.dart';
import 'package:aplicacao_cliente_hibrida/l10n/app_localizations.dart';

class CardPowerFactor extends StatefulWidget {
  final String topic;
  final IoTDevice ioTDevice;
  const CardPowerFactor({
    Key? key,
    required this.topic,
    required this.ioTDevice,
  }) : super(key: key);

  @override
  State<CardPowerFactor> createState() => _CardPowerFactorState();
}

class _CardPowerFactorState extends State<CardPowerFactor> {
  late PowerFactorStore store;
  late Future _mqttFuture;

  Future<void> _connectAndSubscribe() async {
    await store.connectMqtt();
    await store.inscrever(widget.topic);
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    store = PowerFactorStore();
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
                        AppLocalizations.of(context)!.factorPower,
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
                              ? PowerFactorIndicator(
                                  store.currentIotData!.value.toDouble(),
                                  size: Size(
                                      150,
                                      MediaQuery.of(context).size.height *
                                          0.35),
                                )
                              : Container(
                                  height: 100,
                                  width: 100,
                                  child: PowerFactorIndicator(
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
