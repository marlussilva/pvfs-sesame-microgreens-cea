import 'package:aplicacao_cliente_hibrida/page/environment/layouts/mobile/environment/components/card_environment_component.dart';
import 'package:aplicacao_cliente_hibrida/store/environment_store.dart';
import 'package:aplicacao_cliente_hibrida/util/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:my_api/model/environment.dart';

class EnvironmentMobilePage extends StatefulWidget {
  final Size size;

  EnvironmentMobilePage({super.key, required this.size});

  @override
  State<EnvironmentMobilePage> createState() => _EnvironmentMobilePageState();
}

class _EnvironmentMobilePageState extends State<EnvironmentMobilePage> {
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
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    store.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var crossAxisCount = widget.size.width < 650 ? 2 : 4;
    double childAspectRatio =
        widget.size.width < 650 && widget.size.width > 350 ? 1.0 : 1;
    return Observer(builder: (_) {
      return Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
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
              child: CardEnvironmentComponent(
                environment: environment,
              ),
              onTap: () {
                store.setEnvironmentSelected(environment);

                context.push<bool>("/dashboard");
              },
            );
          },
        ),
      );
    });
  }
}
