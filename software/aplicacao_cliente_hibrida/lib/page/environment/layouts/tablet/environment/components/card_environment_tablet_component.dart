import 'package:aplicacao_cliente_hibrida/store/environment_store.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';
import 'package:my_api/model/environment.dart';

class CardEnvironmentTabletComponent extends StatelessWidget {
  CardEnvironmentTabletComponent({super.key, required this.environment});
  Environment environment;
  final brazilianDateFormat = DateFormat('dd/MM/yyyy HH:mm', 'pt_BR');
  final store = GetIt.I<EnvironmentStore>();

  @override
  Widget build(BuildContext context) {
    if (environment == null) {
      return Container();
    }

    String imageName = (environment.type == 1) ? "indoor.jpg" : "estufa.jpg";

    return Card(
      child: Padding(
        padding: EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.white,
                backgroundImage: AssetImage("assets/image/$imageName"),
                radius: 25.0,
              ),
              title: Text(environment.name ?? 'N/A',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(environment.acronym ?? 'N/A'),
            ),
            Expanded(
              child: ListView(
                children: [
                  _buildInfoRow(Icons.description,
                      'Descrição: ${environment.description ?? 'N/A'}'),
                  _buildInfoRow(Icons.location_on,
                      'Localização: ${environment.location ?? 'N/A'}'),
                  _buildInfoRow(Icons.power_settings_new,
                      'Ativado: ${environment.activated ?? false ? 'Sim' : 'Não'}'),
                  _buildInfoRow(Icons.date_range,
                      'Atualizado em: ${brazilianDateFormat.format(environment.updatedAt ?? environment.createdAt!)}'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Icon(icon, size: 20),
          SizedBox(width: 8),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}
