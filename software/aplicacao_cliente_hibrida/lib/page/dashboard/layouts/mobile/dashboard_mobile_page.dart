import 'package:aplicacao_cliente_hibrida/page/consultas/iot_data_query_screen.dart';
import 'package:aplicacao_cliente_hibrida/page/dashboard/layouts/components/charts/experiment_card.dart';
import 'package:aplicacao_cliente_hibrida/page/environment/layouts/mobile/environment/components/widgets/pulsating_circle.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:get_it/get_it.dart';
import 'package:aplicacao_cliente_hibrida/page/dashboard/layouts/components/action/action_component.dart';
import 'package:aplicacao_cliente_hibrida/page/dashboard/layouts/components/read_component.dart';
import 'package:aplicacao_cliente_hibrida/store/environment_store.dart';
import 'package:my_api/model/environment.dart';
import 'package:aplicacao_cliente_hibrida/l10n/app_localizations.dart';

class DashboardMobilePage extends StatefulWidget {
  final Size size;

  const DashboardMobilePage({super.key, required this.size});

  @override
  State<DashboardMobilePage> createState() => _DashboardMobilePageState();
}

class _DashboardMobilePageState extends State<DashboardMobilePage> {
  var store = GetIt.I<EnvironmentStore>();
  bool isLoading = true; // Passo 1: Adicione um estado de carregamento

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      var environmentData = await store.fetchEnvironmentAndDevices();
      if (environmentData != null) store.setEnvironmentData(environmentData);
      setState(() {
        isLoading = false; // Passo 3: Atualize o estado de carregamento
      });
    });
  }

  Widget buildLoadingScreen() {
    // Uma tela simples com um CircularProgressIndicator
    return Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    String titleBar = store.environmentSelected?.name ?? "";
    if (titleBar == "Microverdes" &&
        Localizations.localeOf(context).languageCode == "en") {
          titleBar = "Microgreens";
    }

    return (isLoading)
        ? buildLoadingScreen()
        : DefaultTabController(
            length: 3,
            child: Scaffold(
              appBar: AppBar(
                title: Observer(
                  builder: (_) => Text(
                   titleBar,
                    style: TextStyle(fontSize: 12),
                  ),
                ),
                titleSpacing: 0,
                actions: [
                  Observer(builder: (_) {
                    var status = store.environmentSelected?.status;
                    if (status != null)
                      return PulsatingCircle(
                          isOnline: status == ConnectionStatus.online);
                    else
                      return Container();
                  }),
                  IconButton(
                    icon: Icon(Icons.more_vert),
                    onPressed: () {
                      // Mostrar o menu na posição do botão
                      showMenu(
                        context: context,
                        position: RelativeRect.fromLTRB(100.0, 100.0, 0.0,
                            0.0), // Você pode ajustar esses valores conforme necessário
                        items: [
                          PopupMenuItem<String>(
                            value: 'relatorio',
                            child: Text('Exportar'),
                          ),
                          PopupMenuItem<String>(
                            value: 'configuracoes',
                            child: Text('Configurações'),
                          ),
                        ],
                      ).then((value) {
                        // Tratar a opção selecionada aqui
                        if (value != null) {
                          if (value == 'relatorio') {
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (c) => IotDataQueryScreen()));
                            // Implementar ação para Relatório
                          } else if (value == 'configuracoes') {
                            // Implementar ação para Configurações
                          }
                        }
                      });
                    },
                  ),
                ],
                bottom: TabBar(
                  indicatorSize: TabBarIndicatorSize.tab,
                  tabs: [
                    Tab(
                      child: Row(
                        children: [
                          Icon(
                            Icons.dashboard,
                            size: 12,
                          ),
                          SizedBox(
                            width: 8,
                          ),
                          Text(
                            AppLocalizations.of(context)!.monitor,
                            style: TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                    Tab(
                      child: Row(
                        children: [
                          Icon(
                            Icons.show_chart,
                            size: 12,
                          ),
                          SizedBox(
                            width: 8,
                          ),
                          Text(
                            AppLocalizations.of(context)!.charts,
                            style: TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                    Tab(
                      child: Row(
                        children: [
                          Icon(
                            Icons.schedule,
                            size: 12,
                          ),
                          SizedBox(
                            width: 8,
                          ),
                          Text(
                            AppLocalizations.of(context)!.program,
                            style: TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              body: TabBarView(
                children: [
                  buildMonitoringPage(),
                  //IotDataQueryScreen(),
                  ExperimentCard(),
                  Observer(builder: (_) {
                    var env = store.environmentData;
                    return (env != null)
                        ? SingleChildScrollView(
                            child: ActionComponent(
                                size: widget.size, environmentData: env))
                        : Container();
                  })
                ],
              ),
            ),
          );
  }

  Widget buildMonitoringPage() {
    return SingleChildScrollView(
      child: Container(
        width: widget.size.width,
        child: Column(
          children: [
            Observer(builder: (_) {
              var env = store.environmentData;
              if (env != null) {
                return Column(
                  children: [
                    ReadComponent(size: widget.size, environmentData: env),
                  ],
                );
              } else {
                return Container();
              }
            }),
          ],
        ),
      ),
    );
  }
}
