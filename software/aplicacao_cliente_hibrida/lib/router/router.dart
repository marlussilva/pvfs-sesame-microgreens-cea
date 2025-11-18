import 'package:aplicacao_cliente_hibrida/page/ResponsivePage.dart';
import 'package:aplicacao_cliente_hibrida/page/consultas/iot_data_query_screen.dart';
import 'package:aplicacao_cliente_hibrida/page/dashboard/dashboard_layout_page.dart';

import 'package:go_router/go_router.dart';

// GoRouter configuration
final router = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const ResponsivePage(),
    ),
    GoRoute(
      path: '/dashboard',
      builder: (context, state) => const DashboardLayoutPage(),
    ),
  ],
);
