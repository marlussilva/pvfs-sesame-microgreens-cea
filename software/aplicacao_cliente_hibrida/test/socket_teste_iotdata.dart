import 'dart:convert';
import 'dart:io';

void listenForUpdates(String mqttTopic) {
  // Substitua com o URL correto do seu servidor WebSocket
  final String websocketUrl = 'ws://localhost:8080/iot_data/ws';

  // Inicia a conexão WebSocket
  WebSocket.connect(websocketUrl).then((WebSocket websocket) {
    print('Conectado ao WebSocket para o tópico $mqttTopic');

    websocket.listen((data) {
      // Recebe dados do servidor
      var decodedMessage = json.decode(utf8.decode(data));
      print('Nova atualização recebida: $decodedMessage');

      // Aqui você pode atualizar o gráfico ou a UI com os novos dados recebidos
    }, onDone: () {
      print('Conexão WebSocket encerrada');
    }, onError: (error) {
      print('Erro na conexão WebSocket: $error');
    });
  }).catchError((error) {
    print('Não foi possível conectar ao WebSocket: $error');
  });
}

void main() {
  listenForUpdates("sc5");
}
