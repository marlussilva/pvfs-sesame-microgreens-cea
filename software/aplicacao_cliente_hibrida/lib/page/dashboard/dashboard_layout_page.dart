import 'package:aplicacao_cliente_hibrida/page/dashboard/layouts/desktop/dashboard_desktop_page.dart';
import 'package:aplicacao_cliente_hibrida/page/dashboard/layouts/mobile/dashboard_mobile_page.dart';
import 'package:aplicacao_cliente_hibrida/page/dashboard/layouts/tablet/dashboard_table_page.dart';
import 'package:aplicacao_cliente_hibrida/store/responsive_store.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class DashboardLayoutPage extends StatefulWidget {
  const DashboardLayoutPage({super.key});

  @override
  State<DashboardLayoutPage> createState() => _DashboardLayoutPageState();
}

class _DashboardLayoutPageState extends State<DashboardLayoutPage> {
  final store = GetIt.I<ResponsiveStore>();

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    store.setScreenSize(size.width, size.height);

    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth, h = constraints.maxHeight;

        if (w < 850) {
          return DashboardMobilePage(size: Size(w, h));
        } else if (w < 1100) {
          return DashboardTabletPage(size: Size(w, h));
        } else {
          return DashboardDesktopPage(size: Size(w, h));
        }
      },
    );
  }
}
