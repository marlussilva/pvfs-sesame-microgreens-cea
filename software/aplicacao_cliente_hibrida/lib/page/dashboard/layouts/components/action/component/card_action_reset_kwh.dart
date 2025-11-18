import 'package:aplicacao_cliente_hibrida/page/dashboard/layouts/components/action/widgets/reset_energy_button.dart';
import 'package:aplicacao_cliente_hibrida/store/kwh_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:my_api/model/environment_data.dart';
import 'package:my_api/model/iot_device.dart';
import 'package:aplicacao_cliente_hibrida/l10n/app_localizations.dart';

class CardActionResetKwh extends StatefulWidget {
  final EnvironmentData environmentData;
  final IoTDevice device;
  final Size size;
  const CardActionResetKwh(
      {super.key,
      required this.environmentData,
      required this.device,
      required this.size});

  @override
  State<CardActionResetKwh> createState() => _CardActionResetKwhState();
}

class _CardActionResetKwhState extends State<CardActionResetKwh> {
  late KwhStore store;
  late Future _mqttFuture;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    store = KwhStore();
    _mqttFuture = _connectAndSubscribe();
  }

  Future<void> _connectAndSubscribe() async {
    var subtopic = "reset_energy";
    var topic = "${widget.environmentData.environment!.acronym}/$subtopic";
    print("TOPIC $topic");
    await store.connectMqtt();
    await store.inscrever(topic);
  }

  @override
  void dispose() {
    store.disconnect();
    super.dispose();
  }

  void _showResetConfirmationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.warning, color: Colors.amber), // Símbolo de atenção
              SizedBox(width: 10), // Espaçamento entre o ícone e o texto
              Text('Confirmação'),
            ],
          ),
          content: Text('Deseja realmente resetar o kWh?'),
          actions: <Widget>[
            TextButton(
              onPressed: () =>
                  Navigator.of(context).pop(), // Fecha o diálogo sem fazer nada
              child: Row(
                children: [
                  Icon(Icons.thumb_down, color: Colors.red), // Ícone negativo
                  SizedBox(width: 5), // Espaçamento
                  Text('Não'),
                ],
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Fecha o diálogo
                _resetKwh(); // Chama a função de reset
              },
              child: Row(
                children: [
                  Icon(Icons.thumb_up, color: Colors.green), // Ícone positivo
                  SizedBox(width: 5), // Espaçamento
                  Text('Sim'),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  void _resetKwh() {
    var topic = "${widget.environmentData.environment!.acronym}/reset_energy";
    print(store.isConnected);
    store.sendCommandMqtt('reset_energy', topic, 1);
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
        var topic =
            "${widget.environmentData.environment!.acronym}/reset_energy";
        return Observer(
          builder: (_) => Container(
            margin: const EdgeInsets.all(10),
            padding: const EdgeInsets.all(10),
            width: widget.size.width,
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
            child: Column(
              children: [
                Text(
                  AppLocalizations.of(context)!.resetKwh,
                  style: TextStyle(
                    //fontSize: 12,
                    color: Colors.blue,
                  ),
                ),
                SizedBox(
                  width: 8,
                ),
                ResetEnergyButton(
                  onReset: _showResetConfirmationDialog, // Alteração aqui
                  size: Size(50, 50),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
