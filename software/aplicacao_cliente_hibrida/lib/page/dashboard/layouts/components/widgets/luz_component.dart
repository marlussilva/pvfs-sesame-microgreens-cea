import 'package:aplicacao_cliente_hibrida/store/luz_component_store.dart';
import 'package:aplicacao_cliente_hibrida/util/icons_imagens.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:my_api/model/environment_data.dart';
import 'package:aplicacao_cliente_hibrida/l10n/app_localizations.dart';

class LuzComponent extends StatefulWidget {
  final EnvironmentData environmentData;

  const LuzComponent({super.key, required this.environmentData});

  @override
  State<LuzComponent> createState() => _LuzComponentState();
}

class _LuzComponentState extends State<LuzComponent> {
  List<LuzComponentStore>? stores;

  bool statusClick = false;

  @override
  void initState() {
    super.initState();
    initStores();
  }

  Future<void> initStores() async {
    var devices = widget.environmentData.devices
            ?.where((device) => device.icon == IconsImage.led)
            .toList() ??
        [];

    stores = await Future.wait(devices.map((device) async {
      var store = LuzComponentStore();
      await store.connectMqtt();
      // Adicione qualquer lógica adicional necessária aqui
      return store;
    }));
    if (mounted)
      setState(() {}); // Atualiza o estado após a inicialização dos stores
  }

  @override
  void dispose() {
    // TODO: implement dispose
    if (stores != null)
      for (var element in stores!) {
        element.disconnect();
      }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Observer(builder: (_) {
      if (stores != null) {
        return Column(
          children: _tela(),
        );
      } else {
        return Container();
      }
    });
  }

  List<Widget> _tela() {
    var devices = widget.environmentData.devices
        ?.where((device) => device.icon == IconsImage.led)
        .toList();
    var environment = widget.environmentData.environment;
    // var lastMessage = GetIt.I<LastMessageMqttStore>();

    if (devices != null && devices.isNotEmpty) {
      return List<Widget>.generate(devices.length, (index) {
        var device = devices[index];

        var store = stores![index];
        var TOPIC = "${environment?.acronym}/${device.topic}";
        store.mqttStore.subscribe(TOPIC);
        if (!statusClick) {
          store.setValue(double.tryParse(store.mqttStore.value) ?? 0);
        }
        String title = "";
        if ("Dimerização Vermelha [%]" == device.name) {
          title = AppLocalizations.of(context)!.dimRed;
        }
        if ("Dimerização RBW [%]" == device.name) {
          title = AppLocalizations.of(context)!.dimRBW;
        }
        if ("Dimerização Branca [%]" == device.name) {
          title = AppLocalizations.of(context)!.dimWhite;
        }
        if ("Dimerização Azul [%]" == device.name) {
          title = AppLocalizations.of(context)!.dimBlue;
        }

        return Column(
          children: [
            Text(title),
            Row(
              children: [
                Column(
                  children: [
                    Icon(Icons.light, color: Colors.blue),
                    Observer(
                      builder: (_) {
                        var teste = store.ioTData;
                        if (TOPIC == store.ioTData?.mqttTopic)
                          return Text(
                            '${teste?.value ?? 0}',
                            style: const TextStyle(color: Colors.red),
                          );
                        else
                          return Column(
                            children: [
                              Container(
                                  height: 10,
                                  width: 10,
                                  child: CircularProgressIndicator(
                                    color: Colors.blue,
                                    strokeWidth: 1,
                                  )),
                              Text(
                                "...",
                                style: TextStyle(color: Colors.blue),
                              ),
                            ],
                          );
                      },
                    )
                  ],
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Observer(builder: (_) {
                    return Slider(
                      key: ValueKey(device.id),
                      activeColor: Colors.blue,
                      value: store.value,
                      max: 100,
                      divisions: 20,
                      onChanged: (newValue) {
                        // Apenas atualiza o valor visualmente enquanto arrasta
                        store.setValue(newValue);
                      },
                      onChangeEnd: (newValue) {
                        // Este é o valor final quando o usuário termina de arrastar
                        statusClick = true;
                        store.setValue(newValue);

                        store.sendCommandMqtt(
                            device.topic ?? '',
                            "${environment?.acronym}/${device.topic}",
                            newValue);
                      },
                      label: "${store.value.round()}",
                    );
                  }),
                ),
              ],
            ),
          ],
        );
      });
    }
    return [];
  }
}
