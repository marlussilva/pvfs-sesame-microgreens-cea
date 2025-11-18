

import 'package:my_api/config/my_config.dart';
import 'package:my_api/router/environment_router.dart';
import 'package:my_api/router/iot_device_router.dart';
import 'package:my_api/router/iot_data_router.dart';
import 'package:my_api/router/organization_router.dart';
import 'package:my_api/router/user_router.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as io;
import 'package:shelf_router/shelf_router.dart';
import 'package:shelf_cors_headers/shelf_cors_headers.dart'; // Import the shelf_cors_headers package

void main() async {



  final app = Router();

  // Adicione o UserRouter como um manipulador de rotas
  app.mount('/user/', UserRouter(MyConfig.URL_MONGO).router); //usuários
  app.mount('/environment/',
      EnvironmentRouter(MyConfig.URL_MONGO).router); //ambientes
  app.mount('/iot/', IoTDeviceRouter(MyConfig.URL_MONGO).router);
  app.mount('/iot_data/', IotDataRouter(MyConfig.URL_MONGO).router);
  app.mount('/organization/', OrganizationRouter(MyConfig.URL_MONGO).router);

  // Crie um middleware que imprime os detalhes de cada requisição
  var logMiddleware = createMiddleware(requestHandler: (request) {
    var isWebSocket = request.headers['upgrade']?.toLowerCase() == 'websocket';
    var protocol = isWebSocket ? 'WebSocket' : 'HTTP';
    print('Acesso: $protocol ${request.method} ${request.requestedUri}');
    return null;
  });

  final corsMiddleware = corsHeaders(); // Create the CORS middleware

  // Integrate the logMiddleware and the corsMiddleware
  final handler = const Pipeline()
      .addMiddleware(logMiddleware)
      .addMiddleware(corsMiddleware)
      .addHandler(app);

  final server = await io.serve(handler, '0.0.0.0', 8080);
  print('Servidor rodando em http://${server.address.host}:${server.port}');
}
