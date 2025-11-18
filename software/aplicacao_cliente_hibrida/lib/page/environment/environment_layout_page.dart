import 'package:aplicacao_cliente_hibrida/page/drawer/side_menu.dart';
import 'package:aplicacao_cliente_hibrida/page/environment/layouts/desktop/environment/environment_desktop_page.dart';
import 'package:aplicacao_cliente_hibrida/page/environment/layouts/mobile/environment/environment_mobile_page.dart';
import 'package:aplicacao_cliente_hibrida/page/environment/layouts/tablet/environment/environment_tablet_page.dart';
import 'package:aplicacao_cliente_hibrida/store/responsive_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:get_it/get_it.dart';
import 'package:aplicacao_cliente_hibrida/l10n/app_localizations.dart';

class EnvironmentLayoutPage extends StatefulWidget {
  const EnvironmentLayoutPage({super.key});

  @override
  State<EnvironmentLayoutPage> createState() => _EnvironmentLayoutPageState();
}

class _EnvironmentLayoutPageState extends State<EnvironmentLayoutPage> {
  var store = GetIt.I<ResponsiveStore>();

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;

    // Atualizar o tamanho da tela no store
    store.setScreenSize(size.width, size.height);

    return Scaffold(
      appBar: AppBar(
          title: Text(
        AppLocalizations.of(context)!.environmentLeav,
        style: TextStyle(fontSize: 12),
      )),
      //drawer:
      //    size.width < 1100 ? SideMenu() : null, // Drawer para mobile e tablet
      body: Observer(
        builder: (_) {
          // Escolha o layout com base no tamanho armazenado no store
          if (store.screenWidth < 850) {
            return EnvironmentMobilePage(
                size: Size(store.screenWidth, store.screenHeight));
          } else if (store.screenWidth >= 850 && store.screenWidth < 1100) {
            return EnvironmentTabletPage(
                size: Size(store.screenWidth, store.screenHeight));
          } else {
            return EnvironmentDesktopPage(
                size: Size(store.screenWidth, store.screenHeight));
          }
        },
      ),
    );
  }
}
