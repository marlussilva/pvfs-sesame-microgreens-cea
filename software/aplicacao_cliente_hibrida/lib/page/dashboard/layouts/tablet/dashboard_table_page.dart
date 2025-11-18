import 'package:aplicacao_cliente_hibrida/page/consultas/iot_data_query_screen.dart';
import 'package:aplicacao_cliente_hibrida/page/dashboard/layouts/components/table_component.dart';
import 'package:aplicacao_cliente_hibrida/store/environment_store.dart';
import 'package:aplicacao_cliente_hibrida/store/navigator_menu_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:get_it/get_it.dart';
import 'package:my_api/model/environment_data.dart';

class DashboardTabletPage extends StatefulWidget {
  final Size size;

  const DashboardTabletPage({Key? key, required this.size}) : super(key: key);

  @override
  State<DashboardTabletPage> createState() => _DashboardTabletPageState();
}

class _DashboardTabletPageState extends State<DashboardTabletPage> {
  var store = GetIt.I<EnvironmentStore>();
  var storeMenu = GetIt.I<NavigatorMenuStore>();
  bool isLoading = true;

  Widget getTela(int index, EnvironmentData env) {
    switch (index) {
      case 0:
        {
          return TableComponent(
            environmentData: env,
            isTablet: true,
          );
        }

      case 1:
        {
          return IotDataQueryScreen();
        }
      default:
        return Container();
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      print("WIDGETS ");
      print(store.environmentSelected);
      var environmentData = await store.fetchEnvironmentAndDevices();
      if (environmentData != null) {
        store.setEnvironmentData(environmentData);
      }
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
    return (isLoading)
        ? buildLoadingScreen()
        : Observer(builder: (_) {
            var env = store.environmentData;

            if (env != null) {
              Widget tela = getTela(storeMenu.value, env);
              return Container(
                width: widget.size.width,
                child: SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: widget.size.height,
                    ),
                    child: SizedBox(
                        height: 600, // Definir uma altura apropriada aqui
                        child: tela),
                  ),
                ),
              );
            } else {
              return Container();
            }
          });
  }
}
