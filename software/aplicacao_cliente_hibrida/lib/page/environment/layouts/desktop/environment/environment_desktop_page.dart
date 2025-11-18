import 'package:aplicacao_cliente_hibrida/page/drawer/side_menu.dart';
import 'package:aplicacao_cliente_hibrida/page/environment/layouts/desktop/environment/components/card_environment_desktop_component.dart';
import 'package:aplicacao_cliente_hibrida/page/environment/layouts/mobile/environment/components/widgets/pulsating_circle.dart';
import 'package:aplicacao_cliente_hibrida/store/environment_store.dart';
import 'package:aplicacao_cliente_hibrida/store/responsive_store.dart';
import 'package:aplicacao_cliente_hibrida/util/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:my_api/model/environment.dart';

class EnvironmentDesktopPage extends StatefulWidget {
  final Size size;

  const EnvironmentDesktopPage({super.key, required this.size});

  @override
  State<EnvironmentDesktopPage> createState() => _EnvironmentDesktopPageState();
}

class _EnvironmentDesktopPageState extends State<EnvironmentDesktopPage> {
  var store = GetIt.I<EnvironmentStore>();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      store.fetchEnvironments();
    });
  }

  @override
  Widget build(BuildContext context) {
    var screenWidth = MediaQuery.of(context).size.width;
    var crossAxisCount = screenWidth < 1400 ? 2 : 3; // Ajuste dinâmico da grade
    double childAspectRatio = screenWidth < 1400 ? 1.6 : 1.8;

    return SizedBox(
      width: screenWidth,
      child: Observer(
        builder: (context) => Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /* const Expanded(
            flex: 1,
            child: SideMenu(),
          ),*/
            Expanded(
              flex: 4,
              child: GridView.builder(
                shrinkWrap: true,
                itemCount: store.environments.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: defaultPadding,
                  mainAxisSpacing: defaultPadding,
                  childAspectRatio: childAspectRatio,
                ),
                itemBuilder: (context, index) {
                  Environment environment =
                      Environment.fromMap(store.environments[index]);

                  return InkWell(
                    child: Stack(
                      children: [
                        CardEnvironmentDesktopComponent(
                          environment: environment,
                        ),
                        Positioned(
                          top: 5,
                          right: 5,
                          child: PulsatingCircle(
                              isOnline: environment.status ==
                                  ConnectionStatus.online),
                        ),
                      ],
                    ),
                    onTap: () {
                      store.setEnvironmentSelected(environment);

                      context.push<bool>("/dashboard");
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
