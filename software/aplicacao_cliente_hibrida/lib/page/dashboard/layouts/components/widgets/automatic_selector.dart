import 'package:aplicacao_cliente_hibrida/page/dashboard/layouts/components/widgets/constante_page.dart';
import 'package:aplicacao_cliente_hibrida/page/dashboard/layouts/components/widgets/tab/icon_gauss.dart';
import 'package:aplicacao_cliente_hibrida/page/dashboard/layouts/components/widgets/tab/icon_linear.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:get_it/get_it.dart';

import 'package:aplicacao_cliente_hibrida/page/dashboard/layouts/components/widgets/gaussian_page.dart';
import 'package:aplicacao_cliente_hibrida/store/automatic_selector_store.dart';
import 'package:my_api/model/environment_data.dart';

class AutomaticSelector extends StatefulWidget {
  EnvironmentData environmentData;
  Size size;
  AutomaticSelector({
    Key? key,
    required this.environmentData,
    required this.size,
  }) : super(key: key);

  @override
  State<AutomaticSelector> createState() => _AutomaticSelectorState();
}

class _AutomaticSelectorState extends State<AutomaticSelector> {
  var store = GetIt.I<AutomaticSelectorStore>();

  @override
  void initState() {
    super.initState();
    // Inicialização do estado ou busca de dados necessários
  }

  @override
  Widget build(BuildContext context) {
    return Observer(builder: (_) {
      return DefaultTabController(
        length: store.lenght, // Garanta que 'store.lenght' seja pelo menos 2
        child: LayoutBuilder(
          builder: (context, constraints) => SizedBox(
            height: MediaQuery.of(context).size.height,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Material(
                  color: Colors.grey[850], // Cor do fundo da TabBar
                  child: TabBar(
                    indicatorColor:
                        Colors.transparent, // Remove a barra indicadora
                    tabs: [
                      Tab(
                        child: Column(
                          children: [
                            SizedBox(height: 19, child: IconGauss()),
                           const  SizedBox(
                              height: 6,
                            ),
                            const Text(
                              "Gaussiana",
                              style:
                                  TextStyle(color: Colors.white, fontSize: 8),
                            )
                          ],
                        ),
                      ), // Primeira aba
                      Tab(
                          icon: Column(
                        children: [
                          SizedBox(height: 19, child: IconLinear()),
                         const  SizedBox(
                            height: 6,
                          ),
                         const  Text(
                            "Constante",
                            style: TextStyle(color: Colors.white, fontSize: 8),
                          )
                        ],
                      )), // Segunda aba
                    ],
                  ),
                ),
                Expanded(
                  child: TabBarView(
                    children: [
                      // Conteúdo da primeira aba

                      GaussianPage(
                        size: widget.size,
                        environmentData: widget.environmentData,
                      ),

                      // Conteúdo da segunda aba
                      ConstantePage(
                        size: widget.size,
                        environmentData: widget.environmentData,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }
}
