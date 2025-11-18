import 'package:aplicacao_cliente_hibrida/page/environment/layouts/mobile/environment/components/widgets/pulsating_circle.dart';
import 'package:aplicacao_cliente_hibrida/page/environment/layouts/tablet/environment/components/card_environment_tablet_component.dart';
import 'package:aplicacao_cliente_hibrida/store/environment_store.dart';
import 'package:aplicacao_cliente_hibrida/util/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:my_api/model/environment.dart';

class EnvironmentTabletPage extends StatefulWidget {
  final Size size;

  const EnvironmentTabletPage({super.key, required this.size});

  @override
  State<EnvironmentTabletPage> createState() => _EnvironmentTabletPageState();
}

class _EnvironmentTabletPageState extends State<EnvironmentTabletPage> {
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
    var crossAxisCount = 3;
    double childAspectRatio = 1.2;
    return Observer(builder: (_) {
      return SizedBox(
        width: MediaQuery.of(context).size.width,
        child: GridView.builder(
//physics: NeverScrollableScrollPhysics(),
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
                onTap: () {
                  store.setEnvironmentSelected(environment);

                  context.push<bool>("/dashboard");
                },
                child: Stack(
                  children: [
                    CardEnvironmentTabletComponent(
                      environment: environment,
                    ),
                    Positioned(
                      top: 5,
                      right: 5,
                      child: PulsatingCircle(
                          isOnline:
                              environment.status == ConnectionStatus.online),
                    ),
                  ],
                ));
          },
        ),
      );
    });
  }
}
