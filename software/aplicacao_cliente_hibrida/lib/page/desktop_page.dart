import 'package:aplicacao_cliente_hibrida/page/drawer/side_menu.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:aplicacao_cliente_hibrida/store/responsive_store.dart';

class DesktopPage extends StatefulWidget {
  const DesktopPage({super.key});

  @override
  State<DesktopPage> createState() => _DesktopPageState();
}

class _DesktopPageState extends State<DesktopPage> {
  var store = GetIt.I<ResponsiveStore>();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Expanded(
            flex: 1,
            child: SideMenu(),
          ),
          Expanded(
            flex: 2,
            child: Container(
              color: Colors.red,
              child: Text("Desktop Layout"),
            ),
          ),
          Expanded(
            flex: 1,
            child: Container(
              color: Colors.blue,
              child: Text("Desktop Layout"),
            ),
          ),
        ],
      ),
    );
  }
}
