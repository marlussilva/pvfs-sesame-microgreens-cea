import 'package:aplicacao_cliente_hibrida/store/locale_store.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_mobx/flutter_mobx.dart';

import 'router/router.dart';
import 'util/constants.dart';
import 'util/initilization_app.dart';
import 'util/time_convert.dart';
import 'package:aplicacao_cliente_hibrida/l10n/app_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await InitilizationApp.init();
  TimeConverter.initializeTimeZone();

  runApp(const MyApp()); // apenas um MaterialApp.router
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final LocaleStore localeStore = GetIt.I<LocaleStore>();

    return Observer(
      builder: (_) {
        return MaterialApp.router(
          locale: localeStore.locale,
          debugShowCheckedModeBanner: false,
          title: 'Flutter Demo',
          theme: ThemeData.dark().copyWith(
            scaffoldBackgroundColor: bgColor,
            textTheme: GoogleFonts.poppinsTextTheme(
              Theme.of(context).textTheme,
            ).apply(bodyColor: Colors.white),
            canvasColor: secondaryColor,
          ),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          routerConfig: router,
          debugShowMaterialGrid: false,
        );
      },
    );
  }
}
