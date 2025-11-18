import 'dart:convert';
import 'dart:io';
import 'package:mongo_dart/mongo_dart.dart';
import 'package:my_api/model/environment.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:shelf_web_socket/shelf_web_socket.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class EnvironmentRouter {
  final Db _db;
  final _connectedSockets = <WebSocketChannel>[];

  EnvironmentRouter(String databaseUrl) : _db = Db(databaseUrl) {
    _db.open();
  }

  Router get router {
    final router = Router();

    // WebSocket endpoint
    router.get('/ws', webSocketHandler(_handleWebSocket));

    // Outros endpoints
    router.get('/', _getAllEnvironments);
    router.post('/', _addEnvironment);
    router.put('/update-status/<id>', _updateEnvironmentStatus);
    router.put('/<id>', _updateEnvironment);
    router.delete('/<id>', _deleteEnvironment);
    router.get('/search', _searchEnvironments);
    router.get('/check-acronym', _checkAcronym);
    router.get(
        '/<id>', _getEnvironmentById); // Adicionado método para buscar por ID
    // Adicionando o novo endpoint
    router.get('/by-acronym/<acronym>', _getEnvironmentByAcronym);
    return router;
  }

  // Método para buscar environment pelo acronym
  Future<Response> _getEnvironmentByAcronym(
      Request request, String acronym) async {
    final coll = _db.collection('environments');
    final environment = await coll.findOne(where.eq('acronym', acronym));

    if (environment != null) {
      // Convertendo o documento para o objeto Environment
      final environmentObj = Environment.fromMap(environment);
      // Retornando o objeto Environment como JSON
      return Response.ok(json.encode(environmentObj.toMap()),
          headers: {HttpHeaders.contentTypeHeader: 'application/json'});
    } else {
      return Response.notFound(
          'Environment not found for the provided acronym!');
    }
  }

  Future<Response> _updateEnvironmentStatus(Request request, String id) async {
    final coll = _db.collection('environments');

    // Extrai o status do corpo da requisição
    final payload = json.decode(await request.readAsString());
    final String status = payload['status'];

    final updateDocument = {
      '\$set': {'status': status}
    };
    final result =
        await coll.updateOne(where.id(ObjectId.parse(id)), updateDocument);

    if (result.isSuccess && result.nModified > 0) {
      final updatedEnvironmentMap =
          await coll.findOne(where.id(ObjectId.parse(id)));
      if (updatedEnvironmentMap != null) {
        // Criando um objeto Environment a partir do mapa

        // Passando o objeto Environment atualizado para o método _broadcastMessage
        _broadcastMessage('updated_status', updatedEnvironmentMap);

        return Response.ok(
            json.encode({
              'success': true,
              'message': 'Environment status updated successfully'
            }),
            headers: {HttpHeaders.contentTypeHeader: 'application/json'});
      }
      return Response.internalServerError(
          body: 'Failed to retrieve updated environment.');
    } else if (result.isSuccess && result.nModified == 0) {
      return Response.ok(
          json.encode({
            'success': true,
            'message': 'No changes made but the process succeeded'
          }),
          headers: {HttpHeaders.contentTypeHeader: 'application/json'});
    } else {
      return Response.notFound('Environment not found!');
    }
  }

  Future<Response> _getEnvironmentById(Request request, String id) async {
    final coll = _db.collection('environments');
    final environment = await coll.findOne(where.eq('_id', ObjectId.parse(id)));

    if (environment != null) {
      return Response.ok(json.encode(environment),
          headers: {HttpHeaders.contentTypeHeader: 'application/json'});
    } else {
      return Response.notFound('Environment not found!');
    }
  }

  Future<Response> _getAllEnvironments(Request request) async {
    final coll = _db.collection('environments');
    final environments = await coll.find().toList();
    return Response.ok(json.encode(environments),
        headers: {HttpHeaders.contentTypeHeader: 'application/json'});
  }

  Future<Response> _addEnvironment(Request request) async {
    final coll = _db.collection('environments');
    final requestBody = await request.readAsString();
    final environment = json.decode(requestBody);
    environment['createdAt'] = DateTime.now().toUtc().toString();
    await coll.insertOne(environment);

    final insertedEnvironment = await coll.findOne(environment);

    if (insertedEnvironment != null) {
      _broadcastMessage('new_environment', insertedEnvironment);

      // Retornando o ambiente inserido como resposta JSON
      return Response.ok(json.encode(insertedEnvironment),
          headers: {HttpHeaders.contentTypeHeader: 'application/json'});
    } else {
      // Retornando um erro caso o ambiente não tenha sido inserido
      return Response.internalServerError(body: 'Error saving the environment');
    }
  }

  Future<Response> _updateEnvironment(Request request, String id) async {
    final coll = _db.collection('environments');
    final requestBody = await request.readAsString();
    final environment = json.decode(requestBody);
    environment.remove('_id');
    environment['updatedAt'] = DateTime.now().toUtc().toString();
    final updateDocument = {'\$set': environment};
    final result = await coll.updateOne(
        where.eq('_id', ObjectId.parse(id)), updateDocument);

    if (result.isSuccess && result.nModified > 0) {
      final updatedEnvironment =
          await coll.findOne(where.eq('_id', ObjectId.parse(id)));
      if (updatedEnvironment != null) {
        _broadcastMessage('updated_environment', updatedEnvironment);
      }
      return Response.ok('Environment updated successfully!');
    } else if (result.isSuccess && result.nModified == 0) {
      return Response.ok('No changes made but the process succeeded.');
    } else {
      return Response.notFound('Environment not found!');
    }
  }

  Future<Response> _deleteEnvironment(Request request, String id) async {
    final coll = _db.collection('environments');
    final environmentToDelete =
        await coll.findOne(where.eq('_id', ObjectId.parse(id)));

    final result = await coll.remove(where.eq('_id', ObjectId.parse(id)));
    if (result['n'] > 0) {
      if (environmentToDelete != null) {
        _broadcastMessage('deleted_environment', environmentToDelete);
      }
      return Response.ok('Environment deleted successfully!');
    } else {
      return Response.notFound('Environment not found!');
    }
  }

  Future<Response> _searchEnvironments(Request request) async {
    final coll = _db.collection('environments');
    final query = request.requestedUri.queryParameters['name'] ?? '';
    final regexQuery = RegExp('.*$query.*', caseSensitive: false);
    final environments = await coll.find({
      'name': {'\$regex': regexQuery.pattern, '\$options': 'i'}
    }).toList();
    return Response.ok(json.encode(environments),
        headers: {HttpHeaders.contentTypeHeader: 'application/json'});
  }

  Future<Response> _checkAcronym(Request request) async {
    final coll = _db.collection('environments');
    final acronym = request.requestedUri.queryParameters['acronym'] ?? '';
    final existingEnvironment =
        await coll.findOne(where.eq('acronym', acronym));
    if (existingEnvironment != null) {
      return Response.ok(json.encode({'exists': true}),
          headers: {HttpHeaders.contentTypeHeader: 'application/json'});
    } else {
      return Response.ok(json.encode({'exists': false}),
          headers: {HttpHeaders.contentTypeHeader: 'application/json'});
    }
  }

  void _handleWebSocket(WebSocketChannel webSocketChannel) {
    _connectedSockets.add(webSocketChannel);
    webSocketChannel.stream.listen((message) {
      // Ouvir mensagens recebidas, se necessário
    }, onDone: () {
      _connectedSockets.remove(webSocketChannel);
    });
  }

  void _broadcastMessage(String action, [Map<String, dynamic>? environment]) {
    Map<String, dynamic>? messageContent = {'action': action};

    if (environment != null &&
            (action == 'new_environment' ||
                action == 'deleted_environment' ||
                action == 'updated_environment') ||
        action == "updated_status") {
      messageContent['environment'] = environment;
    }

    final message = json.encode(messageContent);

    for (final channel in _connectedSockets) {
      channel.sink.add(message);
    }
  }
}
