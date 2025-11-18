import 'dart:async';
import 'package:aplicacao_cliente_hibrida/page/dashboard/layouts/components/widgets/automatic_selector.dart';
import 'package:aplicacao_cliente_hibrida/page/dashboard/layouts/components/widgets/gaussian_page.dart';

import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:get_it/get_it.dart';
import 'package:my_api/model/iot_device.dart';
import 'package:my_api/model/environment_data.dart';
import 'package:aplicacao_cliente_hibrida/store/tri_toggle_switch_store.dart';
import 'package:aplicacao_cliente_hibrida/page/dashboard/layouts/components/widgets/luz_component.dart';
import 'package:aplicacao_cliente_hibrida/l10n/app_localizations.dart';
import 'package:aplicacao_cliente_hibrida/l10n/app_localizations.dart';

class TriToggleSwitch extends StatefulWidget {
  final EnvironmentData environmentData;
  final IoTDevice device;
  final Size size;

  const TriToggleSwitch({
    Key? key,
    required this.environmentData,
    required this.device,
    required this.size,
  }) : super(key: key);

  @override
  State<TriToggleSwitch> createState() => _TriToggleSwitchState();
}

class _TriToggleSwitchState extends State<TriToggleSwitch> {
  late TriToggleSwitchStore store = GetIt.I<TriToggleSwitchStore>();

  @override
  void initState() {
    store.inscrever("${widget.environmentData.environment?.acronym}/dim_mode");
    super.initState();
    Future.delayed(Duration(seconds: 2), () {
      // Este bloco de código será executado após 2 segundos
      store.setStatus(true);
      var i = store.ioTData?.value.toString() ?? 0;
      store.setIndex(int.tryParse(i.toString()) ?? 0);
    });
  }

  @override
  void dispose() {
    /* if (shouldDisconnect()) {
      store.disconnect();
    }*/
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
          mainAxisSize: MainAxisSize.min,
          children: [
            Observer(builder: (context) {
              return Column(
                mainAxisSize: MainAxisSize
                    .min, // Para manter a coluna com o tamanho dos filhos
                children: [
                  Text(
                    store.status
                        ? AppLocalizations.of(context)!.synchronized
                        : AppLocalizations.of(context)!.synchronizing,
                    style: TextStyle(
                      color: store.status ? Colors.blue : Colors.red,
                    ),
                  ),
                  if (!store
                      .status) // O CircularProgressIndicator será exibido apenas quando store.status for false
                    SizedBox(
                      height: 15.0, // Altura do SizedBox
                      width: 15.0, // Largura do SizedBox
                      child: CircularProgressIndicator(
                        strokeWidth:
                            2.0, // Largura do traço do CircularProgressIndicator
                        color: Colors.red,
                      ),
                    ),
                ],
              );
            }),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                buildOption(Icons.power_settings_new,
                    AppLocalizations.of(context)!.off, 0, Colors.red),
                const SizedBox(width: 16),
                buildOption(Icons.lightbulb, AppLocalizations.of(context)!.on,
                    1, Colors.blue),
                const SizedBox(width: 16),
                buildOption(Icons.auto_awesome,
                    AppLocalizations.of(context)!.automatic, 2, Colors.teal),
              ],
            ),
            if (store.currentIndex == 1)
              LuzComponent(
                key: const ValueKey("LuzComponent"),
                environmentData: widget.environmentData,
              ),
            if (store.currentIndex == 2)
              AutomaticSelector(
                size: MediaQuery.of(context).size,
                environmentData: widget.environmentData,
              ),
          ],
        ),
      ),
    );
  }

  Widget buildOption(IconData icon, String label, int index, Color color) {
    return InkWell(
      onTap: () {
        store.setIndex(index);
        var environment = widget.environmentData.environment;
        if (environment != null && index > -1) {
          store.sendCommandMqtt(
            widget.device.topic ?? "",
            "${environment.acronym}/${widget.device.topic}",
            double.parse(index.toString()),
          );
        }
      },
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon,
                color: store.currentIndex == index ? color : Colors.grey[500]),
            const SizedBox(height: 8),
            Text(label,
                style: TextStyle(
                    color: store.currentIndex == index
                        ? color
                        : Colors.grey[500])),
          ],
        ),
      ),
    );
  }
}
