import 'package:aplicacao_cliente_hibrida/page/environment/layouts/mobile/environment/components/widgets/pulsating_circle.dart';
import 'package:aplicacao_cliente_hibrida/store/environment_store.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';
import 'package:my_api/model/environment.dart';

class CardEnvironmentComponent extends StatelessWidget {
  CardEnvironmentComponent({super.key, required this.environment});

  Environment environment;

  var brazilianDateFormat = DateFormat('dd/MM/yyyy HH:mm', 'pt_BR');

  final store = GetIt.I<EnvironmentStore>();

  void _showBottomSheet(BuildContext context) {

    showModalBottomSheet(
        context: context,
        builder: (BuildContext bc) {
          if (environment != null) {
            String imageName =
                (environment.type == 1) ? "indoor.jpg" : "estufa.jpg";
            return Container(
              width: MediaQuery.of(context).size.width * .9,
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircleAvatar(
                        backgroundColor: Colors.white,
                        backgroundImage: AssetImage("assets/image/$imageName"),
                        radius: 25.0, // Tamanho ajustado
                      ),
                    ],
                  ),
                  SizedBox(height: 8), // Espaçamento
                  Wrap(
                    children: [
                      Icon(Icons.label),
                      SizedBox(width: 4),
                      Text('Nome: ${environment.name ?? 'N/A'}'),
                    ],
                  ),
                  Wrap(
                    children: [
                      Icon(Icons.ac_unit), // Substitua pelo ícone desejado
                      SizedBox(width: 4),
                      Text('Sigla: ${environment.acronym ?? 'N/A'}'),
                    ],
                  ),
                  Wrap(
                    children: [
                      Icon(Icons.description), // Substitua pelo ícone desejado
                      SizedBox(width: 4),
                      Text('Descrição: ${environment.description ?? 'N/A'}'),
                    ],
                  ),
                  Wrap(
                    children: [
                      Icon(Icons.location_on), // Substitua pelo ícone desejado
                      SizedBox(width: 4),
                      Text('Localização: ${environment.location ?? 'N/A'}'),
                    ],
                  ),
                  Wrap(
                    children: [
                      Icon(Icons
                          .power_settings_new), // Substitua pelo ícone desejado
                      SizedBox(width: 4),
                      Text(
                          'Ativado: ${environment.activated ?? false ? 'Sim' : 'Não'}'),
                    ],
                  ),
                  Wrap(
                    children: [
                      Icon(Icons.date_range), // Substitua pelo ícone desejado
                      SizedBox(width: 4),
                      Text(
                          '${brazilianDateFormat.format(environment.updatedAt ?? environment.createdAt!)}'),
                    ],
                  ),
                ],
              ),
            );
          } else
            return Container();
        });
  }

  @override
  Widget build(BuildContext context) {
    if (environment == null) {
      return Container();
    }

    String imageName = (environment.type == 1) ? "indoor.jpg" : "estufa.jpg";
    String label = (environment.type == 1) ? "Controlado" : "Protegido";

      String displayName = environment.name ?? "N/A";
      print(displayName);
    if (displayName == "Microverdes" &&
        Localizations.localeOf(context).languageCode == "en") {
      displayName = "Microgreens";
      if(label == "Controlado") label = "Controlled";
      if(label == "Protegido") label = "Protected";
    }


   if (displayName == "Ambiente de Teste" &&
        Localizations.localeOf(context).languageCode == "en") {
      displayName = "Test Environment";
      if(label == "Controlado") label = "Controlled";
      if(label == "Protegido") label = "Protected";
    }
   
    return Card(
      child: Stack(
        alignment: Alignment.center,
        children: [
          SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 100.0,
                  height: 100.0,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.blue,
                      width: 5.0,
                    ),
                  ),
                  child: CircleAvatar(
                    backgroundColor: Colors.white,
                    backgroundImage: AssetImage("assets/image/$imageName"),
                    radius: 50.0,
                    child: Center(
                      child: Text(
                        label,
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  displayName,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          Positioned(
            top: 5,
            right: 5,
            child: PulsatingCircle(
                isOnline: environment.status == ConnectionStatus.online),
          ),
          Positioned(
            bottom: -15,
            right: -10,
            child: IconButton(
              icon: Icon(Icons.more_horiz),
              onPressed: () => _showBottomSheet(context),
            ),
          ),
        ],
      ),
    );
  }
}
