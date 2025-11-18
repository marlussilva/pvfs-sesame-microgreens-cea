import 'dart:convert';
import 'dart:io';
import 'package:mongo_dart/mongo_dart.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:shelf_web_socket/shelf_web_socket.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class IoTDeviceRouter {
  Map<String, List<WebSocketChannel>> activeWebSockets = {};
  late final Db _db;

  IoTDeviceRouter(String databaseUrl) {
    _db = Db(databaseUrl);
    _db.open();
  }

  Future<void> _notifyWebSocketClients(String envId) async {
    final coll = _db.collection('iot_devices');
    final List<Map<String, dynamic>> devices =
        await coll.find(where.eq('environmentId', envId.trim())).toList();
    final jsonResponse = json.encode(devices);
    final encodedMessage = utf8.encode(jsonResponse);

    final List<WebSocketChannel> channels = activeWebSockets[envId] ?? [];
    for (final channel in channels) {
      channel.sink.add(encodedMessage);
    }
  }

  Future<bool> _doesTopicExist(String topic, String environmentId) async {
    final coll = _db.collection('iot_devices');
    final query = where.eq('topic', topic).eq('environmentId', environmentId);
    final count = await coll.count(query);
    return count > 0;
  }

  Future<bool> doesDeviceExistForEnvironment(String environmentId) async {
    final coll = _db.collection('iot_devices');
    final query = where.eq('environmentId', environmentId);
    final count = await coll.count(query);
    return count > 0;
  }

  Future<Response> _getEnvironmentDevices(Request request, String envId) async {
    try {
      final cleanedEnvId = envId.trim();
      if (!RegExp(r"^[0-9a-fA-F]{24}$").hasMatch(cleanedEnvId)) {
        return Response.badRequest(body: 'ID do ambiente fornecido é inválido');
      }

      final coll = _db.collection('iot_devices');
      final List<Map<String, dynamic>> devices =
          await coll.find(where.eq('environmentId', cleanedEnvId)).toList();
      final jsonResponse = json.encode(devices);
      return Response.ok(jsonResponse,
          headers: {HttpHeaders.contentTypeHeader: 'application/json'});
    } catch (e) {
      return Response.internalServerError(body: 'Erro ao buscar dispositivos');
    }
  }

  Future<Response> _getAllDevices(Request request) async {
    final coll = _db.collection('iot_devices');
    final List<Map<String, dynamic>> devices = await coll.find().toList();
    final jsonResponse = json.encode(devices);
    return Response.ok(jsonResponse,
        headers: {HttpHeaders.contentTypeHeader: 'application/json'});
  }

  Future<Response> _addDevice(Request request) async {
    final coll = _db.collection('iot_devices');
    final requestBody = await request.readAsString();
    final Map<String, dynamic> device = json.decode(requestBody);

    device['createdAt'] = DateTime.now().toUtc().toString();

    await coll.insertOne(device);

    final envId = device['environmentId'];
    if (envId != null) {
      await _notifyWebSocketClients(envId);
    }

    return Response.ok('IoT Device saved successfully!');
  }

  Future<Response> _updateDevice(Request request, String id) async {
    final coll = _db.collection('iot_devices');

    try {
      String decodedId = Uri.decodeComponent(id);

      if (decodedId.startsWith('"') && decodedId.endsWith('"')) {
        decodedId = decodedId.substring(1, decodedId.length - 1);
      }

      final requestBody = await request.readAsString();
      final Map<String, dynamic> device = json.decode(requestBody);
      final currentDevice = await coll
          .findOne(where.eq('_id', ObjectId.fromHexString(decodedId)));

      if (currentDevice == null) {
        return Response.notFound('IoT Device not found!');
      }

      device.remove('_id');
      device.remove('createdAt');
      device['updatedAt'] = DateTime.now().toUtc().toString();

      final updateDocument = {'\$set': device};
      final result = await coll.updateOne(
          where.eq('_id', ObjectId.fromHexString(decodedId)), updateDocument);

      if (result.isSuccess && result.nModified > 0) {
        final envId = device['environmentId'] ?? currentDevice['environmentId'];
        if (envId != null) {
          await _notifyWebSocketClients(envId);
        }
        return Response.ok('IoT Device updated successfully!');
      } else if (result.isSuccess && result.nModified == 0) {
        return Response.ok('No changes made but the process succeeded.');
      } else {
        return Response.notFound('IoT Device not found!');
      }
    } catch (e) {
      return Response.internalServerError(body: 'Internal Server Error');
    }
  }

  Future<Response> _deleteDevice(Request request, String id) async {
    final coll = _db.collection('iot_devices');
    final device = await coll.findOne(where.eq('_id', ObjectId.parse(id)));
    final result = await coll.remove(where.eq('_id', ObjectId.parse(id)));

    if (result['n'] > 0) {
      final envId = device?['environmentId'];
      if (envId != null) {
        await _notifyWebSocketClients(envId);
      }
      return Response.ok('IoT Device deleted successfully!');
    } else {
      return Response.notFound('IoT Device not found!');
    }
  }

  Future<Response> _searchDevice(Request request) async {
    final coll = _db.collection('iot_devices');
    final query = request.requestedUri.queryParameters['name'] ?? '';
    final regexQuery = RegExp('.*$query.*', caseSensitive: false);

    final List<Map<String, dynamic>> devices = await coll.find({
      'name': {'\$regex': regexQuery.pattern, '\$options': 'i'}
    }).toList();
    final jsonResponse = json.encode(devices);

    return Response.ok(jsonResponse,
        headers: {HttpHeaders.contentTypeHeader: 'application/json'});
  }

  Future<Response> _checkTopic(Request request) async {
    final topic = request.requestedUri.queryParameters['topic'];
    final environmentId = request.requestedUri.queryParameters['environmentId'];

    if (topic == null || environmentId == null) {
      return Response.badRequest(
          body: 'Topic and environmentId are required parameters.');
    }

    final bool topicExists = await _doesTopicExist(topic, environmentId);
    final jsonResponse = json.encode({'topicExists': topicExists});

    return Response.ok(jsonResponse,
        headers: {HttpHeaders.contentTypeHeader: 'application/json'});
  }

  Future<Response> _checkDeviceExistenceForEnvironment(
      Request request, String envId) async {
    final bool deviceExists = await doesDeviceExistForEnvironment(envId);
    final jsonResponse = json.encode({'deviceExists': deviceExists});
    return Response.ok(jsonResponse,
        headers: {HttpHeaders.contentTypeHeader: 'application/json'});
  }

  Future<Response> _getTopicsByEnvironment(
      Request request, String envId) async {
    try {
      final cleanedEnvId = envId.trim();
      if (!RegExp(r"^[0-9a-fA-F]{24}$").hasMatch(cleanedEnvId)) {
        return Response.badRequest(body: 'ID do ambiente fornecido é inválido');
      }

      final deviceColl = _db.collection('iot_devices');
      final environmentColl = _db.collection('environments');

      final List<Map<String, dynamic>> devices = await deviceColl
          .find(where.eq('environmentId', cleanedEnvId))
          .toList();

      final environment = await environmentColl
          .findOne(where.eq('_id', ObjectId.fromHexString(cleanedEnvId)));

      if (environment == null) {
        return Response.notFound('Ambiente não encontrado');
      }

      final List<String> topics = devices
          .map((device) => '${environment['acronym']}/${device['topic']}')
          .toList();

      final responseMap = {
        'environment': environment,
        'devices': devices,
        'topics': topics,
      };

      final jsonResponse = json.encode(responseMap);
      return Response.ok(jsonResponse,
          headers: {HttpHeaders.contentTypeHeader: 'application/json'});
    } catch (e) {
      return Response.internalServerError(body: 'Erro ao buscar dados');
    }
  }

  Future<void> _handleWebSocketConnection(
      WebSocketChannel webSocketChannel, String envId) async {
    // Adiciona o WebSocket ao conjunto de conexões ativas
    final list = activeWebSockets.putIfAbsent(envId, () => []);
    list.add(webSocketChannel);

    // Configura um manipulador para quando a conexão for fechada
    webSocketChannel.stream.listen(
      null,
      onDone: () {
        // Remove o WebSocket do conjunto de conexões ativas
        list.remove(webSocketChannel);
        print('Connection to $envId closed');
      },
      onError: (error) {
        // Handle errors if necessary
        print('Error in connection to $envId: $error');
      },
    );

    try {
      final coll = _db.collection('iot_devices');
      final List<Map<String, dynamic>> devices =
          await coll.find(where.eq('environmentId', envId.trim())).toList();
      final jsonResponse = json.encode(devices);
      webSocketChannel.sink.add(utf8.encode(jsonResponse));
    } catch (e) {
      print('Erro ao manipular a conexão WebSocket: $e');
      await webSocketChannel.sink.close();
    }
  }

  // Esta função retorna uma função de tratamento de WebSocket
  Function _getWebSocketHandler(String envId) {
    return (WebSocketChannel webSocketChannel) {
      return _handleWebSocketConnection(webSocketChannel, envId);
    };
  }

  Future<Response> _getDeviceByTopic(Request request, String topic) async {
    try {
      final coll = _db.collection('iot_devices');
      final device = await coll.findOne(where.eq('topic', topic.trim()));

      if (device == null) {
        return Response.notFound('IoT Device not found!');
      }

      final jsonResponse = json.encode(device);
      return Response.ok(jsonResponse,
          headers: {HttpHeaders.contentTypeHeader: 'application/json'});
    } catch (e) {
      return Response.internalServerError(body: 'Error fetching device: $e');
    }
  }

  Future<Response> _getByComposedKey(Request request) async {
    try {
      final composedKey = request.url.queryParameters['composedKey'];
      if (composedKey == null || composedKey.isEmpty) {
        return Response.badRequest(body: 'Parâmetro composedKey é necessário.');
      }
      final parts = composedKey.split('/');
      if (parts.length != 2) {
        return Response.badRequest(body: 'Chave composta inválida.');
      }
      final acronym = parts[0];
      final topic = parts[1];

      final environmentColl = _db.collection('environments');
      final deviceColl = _db.collection('iot_devices');

      final environment =
          await environmentColl.findOne(where.eq('acronym', acronym));
      if (environment == null) {
        return Response.notFound('Ambiente não encontrado.');
      }

      final device = await deviceColl.findOne(where
          .eq('environmentId', environment['_id'].toHexString())
          .eq('topic', topic));
      if (device == null) {
        return Response.notFound('Device não encontrado.');
      }

      final responseMap = {
        'environment': environment,
        'device': device,
      };

      final jsonResponse = json.encode(responseMap);
      return Response.ok(jsonResponse,
          headers: {HttpHeaders.contentTypeHeader: 'application/json'});
    } catch (e) {
      return Response.internalServerError(body: 'Erro ao buscar dados: $e');
    }
  }
 ///Passa a rota como parametro exemplo cv1/temperatura1 e retorna o device correspondente caso a rota esteja correta. 
  Future<Response> _getDeviceByComposedKey(
      Request request, String composedKey) async {
    try {
      // Dividir a chave composta em partes de acrônimo e tópico
      final parts = composedKey.split('/');
      if (parts.length != 2) {
        return Response.badRequest(body: 'Chave composta inválida.');
      }
      final acronym = parts[0];
      final topic = parts[1];

      // Obter coleções do banco de dados
      final environmentColl = _db.collection('environments');
      final deviceColl = _db.collection('iot_devices');

      // Buscar ambiente pelo acrônimo
      final environment =
          await environmentColl.findOne(where.eq('acronym', acronym));
      if (environment == null) {
        return Response.notFound('Ambiente não encontrado.');
      }

      // Buscar dispositivo pelo environmentId e tópico
      final device = await deviceColl.findOne(where
          .eq('environmentId', environment['_id'].toHexString())
          .eq('topic', topic));
      if (device == null) {
        return Response.notFound('Dispositivo IoT não encontrado.');
      }

      // Preparar e enviar resposta
      final responseMap = {
        'environment': environment,
        'device': device,
      };
      final jsonResponse = json.encode(responseMap);
      return Response.ok(jsonResponse,
          headers: {HttpHeaders.contentTypeHeader: 'application/json'});
    } catch (e) {
      return Response.internalServerError(
          body: 'Erro ao buscar dispositivo por chave composta: $e');
    }
  }

  Router get router {
    final router = Router();

    router
      ..get('/environment/<envId>', _getEnvironmentDevices)
      ..get('/', _getAllDevices)
      ..post('/', _addDevice)
      ..put('/<id>', _updateDevice)
      ..delete('/<id>', _deleteDevice)
      ..get('/search', _searchDevice)
      ..get('/topic', _checkTopic)
      ..get(
          '/existsForEnvironment/<envId>', _checkDeviceExistenceForEnvironment)
      ..get('/topics/by-environment/<envId>', _getTopicsByEnvironment)
      ..get('/ws', (Request request) {
        print("A rota /iot/ws foi atingida"); // Log aqui
        var envId = request.requestedUri.queryParameters['envId'];
        if (envId == null) {
          print("envId não foi fornecido"); // Log aqui
          return Response.badRequest(body: 'envId is required.');
        }
        print("Chamando webSocketHandler com envId: $envId"); // Log aqui
        return webSocketHandler(_getWebSocketHandler(envId))(request);
      })
      ..get('/by-topic/<topic>', _getDeviceByTopic)
      ..get('/by-composed-key', _getByComposedKey); // nova rota;

    return router;
  }
}
