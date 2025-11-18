import 'package:aplicacao_cliente_hibrida/page/desktop_page.dart';
import 'package:aplicacao_cliente_hibrida/page/drawer/side_menu.dart';
import 'package:aplicacao_cliente_hibrida/page/environment/layouts/desktop/environment/environment_desktop_page.dart';
import 'package:aplicacao_cliente_hibrida/page/environment/layouts/mobile/environment/environment_mobile_page.dart';
import 'package:aplicacao_cliente_hibrida/page/environment/layouts/tablet/environment/environment_tablet_page.dart';
import 'package:aplicacao_cliente_hibrida/store/locale_store.dart';
import 'package:aplicacao_cliente_hibrida/store/responsive_store.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:aplicacao_cliente_hibrida/l10n/app_localizations.dart';

class ResponsivePage extends StatefulWidget {
  const ResponsivePage({super.key});

  @override
  State<ResponsivePage> createState() => _ResponsivePageState();
}

class _ResponsivePageState extends State<ResponsivePage> {
  var store = GetIt.I<ResponsiveStore>();
  var localeStore = GetIt.I<LocaleStore>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Observer(
          builder: (_) => Text(
            AppLocalizations.of(context)!.environmentLeav,
            style: TextStyle(fontSize: 12),
          ),
        ),
        actions: [
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: Icon(Icons.language,
                    color: Colors.white10.withOpacity(0.3)),
                onPressed: () {
                  // Alterna entre inglês e português
                  Locale newLocale = localeStore.locale.languageCode == 'en'
                      ? Locale('pt', '')
                      : Locale('en', '');
                  localeStore.changeLocale(newLocale);
                },
              ),
              Positioned(
                top: 8,
                child: Text(
                  localeStore.locale.languageCode == 'en' ? 'EN' : 'PT',
                  style: TextStyle(
                      fontSize: 12,
                      color: Colors.blue,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          PopupMenuButton<String>(
            onSelected: (String result) {
              // Ação ao selecionar um item do menu
              if (result == 'option1') {
                // Faça algo para a opção 1
              } else if (result == 'option2') {
                // Faça algo para a opção 2
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(
                value: 'option1',
                child: Text('Option 1'),
              ),
              const PopupMenuItem<String>(
                value: 'option2',
                child: Text('Option 2'),
              ),
            ],
          ),
        ],
      ),
      // drawer: MediaQuery.of(context).size.width < 1100 ? SideMenu() : null,
      body: LayoutBuilder(
        builder: (context, constraints) {
          store.setScreenSize(constraints.maxWidth, constraints.maxHeight);

          if (constraints.maxWidth < 850) {
            return EnvironmentMobilePage(
                size: Size(constraints.maxWidth, constraints.maxHeight));
          } else if (constraints.maxWidth >= 850 &&
              constraints.maxWidth < 1100) {
            return EnvironmentTabletPage(
                size: Size(constraints.maxWidth, constraints.maxHeight));
          } else {
            return EnvironmentDesktopPage(
                size: Size(constraints.maxWidth, constraints.maxHeight));
          }
        },
      ),
    );
  }
}
