import 'package:aplicacao_cliente_hibrida/page/consultas/iot_data_query_screen.dart';
import 'package:aplicacao_cliente_hibrida/page/dashboard/layouts/components/action/action_component.dart';
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
import 'package:aplicacao_cliente_hibrida/page/dashboard/layouts/components/charts/experiment_card.dart';
import 'package:aplicacao_cliente_hibrida/page/environment/layouts/mobile/environment/components/widgets/pulsating_circle.dart';
import 'package:aplicacao_cliente_hibrida/store/environment_store.dart';
import 'package:aplicacao_cliente_hibrida/util/icons_imagens.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:my_api/model/environment.dart';
import 'package:my_api/model/environment_data.dart';
import 'package:my_api/model/iot_device.dart';
import 'package:responsive_grid_list/responsive_grid_list.dart';
import 'package:aplicacao_cliente_hibrida/l10n/app_localizations.dart';

class TableComponent extends StatefulWidget {
  final EnvironmentData environmentData;
  final bool isTablet;
  final bool showAppBar; // <- permite embutir sem AppBar

  const TableComponent({
    super.key,
    required this.environmentData,
    required this.isTablet,
    this.showAppBar = true,
  });

  @override
  State<TableComponent> createState() => _TableComponentState();
}

class _TableComponentState extends State<TableComponent> {
  final store = GetIt.I<EnvironmentStore>();

  @override
  Widget build(BuildContext context) {
    // conteúdo principal (grid de cards)
    final grid = ResponsiveGridList(
      horizontalGridSpacing: 16,
      verticalGridSpacing: 16,
      horizontalGridMargin: 50,
      verticalGridMargin: 50,
      minItemWidth: 300,
      minItemsPerRow: widget.isTablet ? 4 : 6,
      maxItemsPerRow: widget.isTablet ? 5 : 6,
      children: _components(),
    );

    // quando embutido (desktop): sem Scaffold/AppBar
    if (!widget.showAppBar) {
      return grid;
    }

    // mobile/tablet: mantém Scaffold com AppBar
    return Scaffold(
      appBar: AppBar(
        title: Observer(
          builder: (_) => Text(
            widget.environmentData.environment?.name ?? "",
            style: const TextStyle(fontSize: 14),
          ),
        ),
        centerTitle: true,
        actions: [
          Observer(builder: (_) {
            final status = store.environmentSelected?.status;
            if (status == null) return const SizedBox.shrink();
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: PulsatingCircle(
                isOnline: status == ConnectionStatus.online,
              ),
            );
          }),
          PopupMenuButton<String>(
            onSelected: _handleMenuSelection,
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(
                value: 'generate_reports',
                child: ListTile(
                  leading: Icon(Icons.pie_chart_outline),
                  title: Text('Gerar Relatórios'),
                ),
              ),
              const PopupMenuItem<String>(
                value: 'export_mqtt',
                child: ListTile(
                  leading: Icon(Icons.import_export),
                  title: Text('Exportar MQTT'),
                ),
              ),
              PopupMenuItem<String>(
                value: 'schedule_environment',
                child: ListTile(
                  leading: const Icon(Icons.schedule),
                  title: Text(AppLocalizations.of(context)!.programEnvironment),
                ),
              ),
            ],
            icon: const Icon(Icons.more_vert),
          ),
        ],
      ),
      body: grid,
    );
  }

  void _handleMenuSelection(String value) {
    switch (value) {
      case 'generate_reports':
        Navigator.of(context).push(MaterialPageRoute(
          builder: (_) => Scaffold(
            appBar: AppBar(
              title: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.pie_chart_outline),
                  SizedBox(width: 8),
                  Text('Gerar Relatórios', style: TextStyle(fontSize: 14)),
                ],
              ),
              centerTitle: true,
            ),
            body: const ExperimentCard(),
          ),
        ));
        break;

      case 'export_mqtt':
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => IotDataQueryScreen()),
        );
        break;

      case 'schedule_environment':
        Navigator.of(context).push(MaterialPageRoute(
          builder: (_) => Scaffold(
            appBar: AppBar(
              title: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.schedule),
                  SizedBox(width: 8),
                  Text('Programar Ambiente', style: TextStyle(fontSize: 14)),
                ],
              ),
              centerTitle: true,
            ),
            body: SingleChildScrollView(
              child: ActionComponent(
                size: MediaQuery.of(context).size,
                environmentData: widget.environmentData,
              ),
            ),
          ),
        ));
        break;
    }
  }

  List<Widget> _components() {
    final List<IoTDevice>? devices = widget.environmentData.devices;
    final List<String>? topics = widget.environmentData.topics;
    final List<Widget> lista = [];

    if (devices == null || topics == null) return [];

    for (var i = 0; i < devices.length; i++) {
      final device = devices[i];
      final topic = topics[i];
      final card = _buildCardForDevice(device, topic);
      if (card != null) lista.add(card);
    }
    return lista;
    }

  Widget? _buildCardForDevice(IoTDevice device, String topic) {
    switch (device.icon) {
      case IconsImage.intensity:
        return CardIntensity(topic: topic, ioTDevice: device);
      case IconsImage.humidity:
        return CardHumidity(ioTDevice: device, topic: topic);
      case IconsImage.temperature:
        return CardTemperature(topic: topic, ioTDevice: device);
      case IconsImage.led:
        return device.viewReturn ?? false
            ? CardLed(topic: topic, ioTDevice: device)
            : null;
      case IconsImage.co2:
        return CardCo2(topic: topic, ioTDevice: device);
      case IconsImage.ph:
        return CardPH(topic: topic, ioTDevice: device);
      case IconsImage.energy:
        return CardKwh(topic: topic, ioTDevice: device);
      case IconsImage.watts:
        return CardWatts(topic: topic, ioTDevice: device);
      case IconsImage.wifi:
        return CardWifi(topic: topic, ioTDevice: device);
      case IconsImage.factor_power:
        return CardPowerFactor(topic: topic, ioTDevice: device);
      default:
        return null;
    }
  }
}
