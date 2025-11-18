// lib/page/dashboard/layouts/desktop/dashboard_desktop_page.dart
import 'package:aplicacao_cliente_hibrida/page/consultas/iot_data_query_screen.dart';
import 'package:aplicacao_cliente_hibrida/page/dashboard/layouts/components/action/action_component.dart';
import 'package:aplicacao_cliente_hibrida/page/dashboard/layouts/components/charts/experiment_card.dart';
import 'package:aplicacao_cliente_hibrida/page/dashboard/layouts/components/table_component.dart';
import 'package:aplicacao_cliente_hibrida/page/environment/layouts/mobile/environment/components/widgets/pulsating_circle.dart';
import 'package:aplicacao_cliente_hibrida/store/environment_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:get_it/get_it.dart';
import 'package:my_api/model/environment.dart';
import 'package:aplicacao_cliente_hibrida/l10n/app_localizations.dart';

class DashboardDesktopPage extends StatefulWidget {
  final Size size;
  const DashboardDesktopPage({super.key, required this.size});

  @override
  State<DashboardDesktopPage> createState() => _DashboardDesktopPageState();
}

class _DashboardDesktopPageState extends State<DashboardDesktopPage> {
  final store = GetIt.I<EnvironmentStore>();
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final environmentData = await store.fetchEnvironmentAndDevices();
      if (environmentData != null) store.setEnvironmentData(environmentData);
      if (mounted) setState(() => isLoading = false);
    });
  }

  void _handleBack() {
    Navigator.of(context).maybePop();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Observer(builder: (_) {
      final env = store.environmentData;

      // título com a mesma lógica do mobile
      String titleBar = store.environmentSelected?.name ?? "";
      if (titleBar == "Microverdes" &&
          Localizations.localeOf(context).languageCode == "en") {
        titleBar = "Microgreens"; // mantenho sua regra
      }

      final canGoBack = Navigator.of(context).canPop();

      return Scaffold(
        appBar: AppBar(
          elevation: 2,
          toolbarHeight: 56,
          automaticallyImplyLeading: canGoBack,
          leading: canGoBack ? BackButton(onPressed: _handleBack) : null,
          titleSpacing: 0,
          title: Text(titleBar, style: const TextStyle(fontSize: 12)),
          centerTitle: false,
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
              itemBuilder: (_) => [
                const PopupMenuItem(
                  value: 'generate_reports',
                  child: ListTile(
                    leading: Icon(Icons.pie_chart_outline),
                    title: Text('Gerar Relatórios'),
                  ),
                ),
                const PopupMenuItem(
                  value: 'export_mqtt',
                  child: ListTile(
                    leading: Icon(Icons.import_export),
                    title: Text('Exportar MQTT'),
                  ),
                ),
                PopupMenuItem(
                  value: 'schedule_environment',
                  child: ListTile(
                    leading: const Icon(Icons.schedule),
                    title: Text(AppLocalizations.of(context)!.programEnvironment),
                  ),
                ),
              ],
              onSelected: (value) {
                switch (value) {
                  case 'generate_reports':
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (_) => Scaffold(
                        appBar: AppBar(title: const Text('Gerar Relatórios')),
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
                    if (env != null) {
                      Navigator.of(context).push(MaterialPageRoute(
                        builder: (_) => Scaffold(
                          appBar: AppBar(title: const Text('Programar Ambiente')),
                          body: SingleChildScrollView(
                            child: ActionComponent(
                              size: MediaQuery.of(context).size,
                              environmentData: env,
                            ),
                          ),
                        ),
                      ));
                    }
                    break;
                }
              },
            ),
          ],
        ),
        body: (env == null)
            ? const SizedBox.shrink()
            : SizedBox(
                width: widget.size.width,
                child: SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minHeight: widget.size.height),
                    child: SizedBox(
                      height: 600,
                      child: TableComponent(
                        isTablet: false,
                        environmentData: env,
                        showAppBar: false, // IMPORTANTe: sem AppBar interno
                      ),
                    ),
                  ),
                ),
              ),
      );
    });
  }
}
