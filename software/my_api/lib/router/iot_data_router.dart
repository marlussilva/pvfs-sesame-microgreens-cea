import 'dart:convert';

import 'dart:io';
import 'package:intl/intl.dart';
import 'package:mongo_dart/mongo_dart.dart';
import 'package:my_api/model/iot_data.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:shelf_web_socket/shelf_web_socket.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class IotDataRouter {
  final Db _db;
  Map<String, List<WebSocketChannel>> activeWebSockets = {};

  IotDataRouter(String databaseUrl) : _db = Db(databaseUrl) {
    _db.open();
  }

  Future<void> _notifyWebSocketClients() async {
    final coll = _db.collection('iot_data');
    final List<Map<String, dynamic>> data = await coll.find().toList();
    final jsonResponse = json.encode(data);
    final encodedMessage = utf8.encode(jsonResponse);

    for (final channels in activeWebSockets.values) {
      for (final channel in channels) {
        channel.sink.add(encodedMessage);
      }
    }
  }

  Future<void> _notifyWebSocketGraphics(
      String mqttTopic, List<Map<String, dynamic>> newData) async {
    final jsonResponse = json.encode(newData);
    final encodedMessage = utf8.encode(jsonResponse);

    // Notifica apenas os clientes interessados no tópico MQTT especificado
    activeWebSockets[mqttTopic]?.forEach((channel) {
      channel.sink.add(encodedMessage);
    });
  }

  Future<void> _handleWebSocketConnection(
      WebSocketChannel webSocketChannel) async {
    print("debugando o servidor ");
    final list = activeWebSockets.putIfAbsent("iot_data", () => []);
    list.add(webSocketChannel);

    webSocketChannel.stream.listen(
      null,
      onDone: () {
        list.remove(webSocketChannel);
        print('Connection closed');
      },
      onError: (error) {
        print('Error in connection: $error');
      },
    );

    try {
      final coll = _db.collection('iot_data');
      final List<Map<String, dynamic>> data = await coll.find().toList();
      final jsonResponse = json.encode(data);
      webSocketChannel.sink.add(utf8.encode(jsonResponse));
    } catch (e) {
      print('Error handling WebSocket connection: $e');
      await webSocketChannel.sink.close();
    }
  }

  Function _getWebSocketHandler() {
    return (WebSocketChannel webSocketChannel) {
      return _handleWebSocketConnection(webSocketChannel);
    };
  }

  Future<void> _ensureIndexes(DbCollection coll) async {
    // Lista de índices necessários, especificando claramente o tipo dos campos 'key' e 'name'
    List<Map<String, dynamic>> indexesNeeded = [
      {
        'key': {'receivedAt': 1, 'mqttTopic': 1} as Map<String, dynamic>,
        'name': 'receivedAt_mqttTopic_index'
      }
      // Adicione outros índices conforme necessário, seguindo a mesma estrutura
    ];

    // Obtém a lista de índices existentes na coleção
    var existingIndexes = await coll.getIndexes();

    // Verifica cada índice necessário
    for (var index in indexesNeeded) {
      var indexExists = existingIndexes.any((existingIndex) {
        // Verifica se o nome do índice existe
        return existingIndex['name'] == index['name'];
      });

      // Se o índice não existe, cria-o
      if (!indexExists) {
        await coll.createIndex(keys: index['key'], name: index['name']);
        print('Índice ${index['name']} criado.');
      }
    }
  }

  Future<Response> _getGrafico(Request request) async {
    final DbCollection coll = _db.collection('iot_data');
    await _ensureIndexes(coll);
    // Extrair parâmetros da query string
    final String startTimestamp =
        request.url.queryParameters['startTimestamp']!;
    final String endTimestamp = request.url.queryParameters['endTimestamp']!;
    final String mqttTopic = request.url.queryParameters['mqttTopic']!;

    // Convertendo datas para UTC
    final DateTime start = DateTime.parse(startTimestamp).toUtc();
    final DateTime end = DateTime.parse(endTimestamp).toUtc();

    // Calculando o intervalo total em milissegundos
    final int totalInterval = end.difference(start).inMilliseconds;

    // Dividindo o intervalo total por 20 para obter o tamanho de cada intervalo/bucket
    final int intervalSize = totalInterval ~/ 100;

    // Pipeline de agregação ajustado
    var pipeline = [
      {
        '\$match': {
          'receivedAt': {'\$gte': start, '\$lte': end},
          'mqttTopic': mqttTopic
        }
      },
      {
        '\$addFields': {
          'numericValue': {
            '\$toDouble': '\$value' // Converte o valor de string para double
          },
          'interval': {
            // Calculando a diferença em milissegundos
            '\$subtract': [
              {
                '\$toLong': {'\$toDate': '\$receivedAt'}
              },
              {'\$toLong': start.millisecondsSinceEpoch}
            ]
          }
        }
      },
      {
        '\$addFields': {
          'bucket': {
            '\$floor': {
              '\$divide': [
                '\$interval',
                intervalSize // Tamanho de cada bucket, calculado previamente
              ]
            }
          }
        }
      },
      {
        '\$group': {
          '_id': '\$bucket',
          'averageValue': {
            '\$avg': '\$numericValue'
          } // Usa o valor convertido para calcular a média
        }
      },
      {
        '\$sort': {'_id': 1}
      }
    ];

    var cursor = await coll.aggregateToStream(pipeline, allowDiskUse: true);

    // Processar o resultado
    Map<int, Map<String, dynamic>> aggregatedDataMap = {};
    await for (var doc in cursor) {
      int bucketId = (doc['_id'] as num).toInt(); // Converte _id para int
      DateTime bucketStartDate =
          start.add(Duration(milliseconds: intervalSize * bucketId));
      String bucketStartDateStr = bucketStartDate.toIso8601String();

      aggregatedDataMap[bucketId] = {
        'date':
            bucketStartDateStr, // Data de início do bucket como string ISO 8601
        'averageValue': doc['averageValue'],
      };
    }

    // Garantir que todos os 20 buckets estejam representados
    List<Map<String, dynamic>> aggregatedData = [];
    for (int i = 0; i < 100; i++) {
      DateTime bucketStartDate =
          start.add(Duration(milliseconds: intervalSize * i));
      String bucketStartDateStr = bucketStartDate.toIso8601String();

      if (!aggregatedDataMap.containsKey(i)) {
        aggregatedData.add({
          'date': bucketStartDateStr,
          'averageValue':
              0, // Use `null` ou `0`, conforme sua preferência para buckets sem dados
        });
      } else {
        aggregatedData.add(aggregatedDataMap[i]!);
      }
    }

    final String jsonData = json.encode(aggregatedData);
    return Response.ok(jsonData,
        headers: {HttpHeaders.contentTypeHeader: 'application/json'});
  }

  Future<Response> _getGraficoSemInterpolacao(Request request) async {
    final DbCollection coll = _db.collection('iot_data');

    // Verifique se os parâmetros necessários estão presentes
    final String? startTimestamp =
        request.url.queryParameters['startTimestamp'];
    final String? endTimestamp = request.url.queryParameters['endTimestamp'];
    final String? mqttTopic = request.url.queryParameters['mqttTopic'];

    // Certifique-se de que todos os parâmetros necessários foram fornecidos
    if (startTimestamp == null || endTimestamp == null || mqttTopic == null) {
      return Response.badRequest(body: 'Missing required query parameters.');
    }

    try {
      // Convertendo datas para UTC
      final DateTime start = DateTime.parse(startTimestamp).toUtc();
      final DateTime end = DateTime.parse(endTimestamp).toUtc();

      // Pipeline de agregação com conversão de valor para double
      var pipeline = [
        {
          '\$match': {
            'receivedAt': {'\$gte': start, '\$lte': end},
            'mqttTopic': mqttTopic
          }
        },
        {
          '\$addFields': {
            'numericValue': {'\$toDouble': '\$value'}
          }
        },
        {
          '\$project': {
            '_id':
                0, // Opcional: remover se desejar manter o _id nos resultados
            'receivedAt': 1,
            'mqttTopic': 1,
            'numericValue': 1
          }
        },
        {
          '\$sort': {
            'receivedAt': 1
          } // Ordena os documentos pela data de recebimento
        }
      ];

      var cursor = await coll.aggregateToStream(pipeline, allowDiskUse: true);

      // Processar o resultado
      List<Map<String, dynamic>> data = [];
      await for (var doc in cursor) {
        var docAsMap = doc as Map<String, dynamic>;

        // Converte DateTime para String no campo 'receivedAt', se estiver presente
        if (docAsMap.containsKey('receivedAt') &&
            docAsMap['receivedAt'] is DateTime) {
          docAsMap['receivedAt'] =
              (docAsMap['receivedAt'] as DateTime).toIso8601String();
        }

        // Adiciona o documento convertido à lista de dados
        data.add(docAsMap);
      }

      final String jsonData = json.encode(data);

      return Response.ok(jsonData,
          headers: {HttpHeaders.contentTypeHeader: 'application/json'});
    } catch (e) {
      return Response.internalServerError(body: 'Error processing request: $e');
    }
  }

  Router get router {
    final router = Router();

    router
          ..get('/', _getAllIotData)
          ..get('/grafico', _getGrafico)
          ..get('/grafico-sem', _getGraficoSemInterpolacao)
          //grafico
          ..get('/search-and-notify', _searchIotDataAndUpdateClients)
          ..get('/search', _getIotDataByTimestampAndTopic)
          ..get('/device/<deviceId>', _getIotDataByDeviceId)
          ..get('/ws', (Request request) {
            // Adicionando a rota WebSocket
            return webSocketHandler(_getWebSocketHandler())(request);
          })
          ..get('/<id>', _getIotDataById)
          ..post('/', _addIotData)
          ..put('/<id>', _updateIotData)
          ..delete('/<id>', _deleteIotData)
        // Mova esta linha acima da rota `/<id>`
        ;

    return router;
  }

  Future<Response> _searchIotDataAndUpdateClients(Request request) async {
    final coll = _db.collection('iot_data');

    // Extrair parâmetros da query string
    String? startTimestamp = request.url.queryParameters['startTimestamp'];
    String? endTimestamp = request.url.queryParameters['endTimestamp'];
    String? mqttTopic = request.url.queryParameters['mqttTopic'];

    // Verificar se os parâmetros necessários foram fornecidos
    if (startTimestamp == null || endTimestamp == null || mqttTopic == null) {
      return Response.badRequest(body: 'Missing required query parameters.');
    }

    final query = where
        .gte('timestamp', DateTime.parse(startTimestamp))
        .lte('timestamp', DateTime.parse(endTimestamp))
        .eq('mqttTopic', mqttTopic)
        .sortBy('timestamp');

    // Executar a consulta e coletar os resultados
    final iotDataList = await coll.find(query).toList();

    // Notificar clientes WebSocket interessados neste tópico MQTT específico
    await _notifyWebSocketClientsForSearch(mqttTopic, iotDataList);

    // Retornar os dados encontrados em formato JSON
    return Response.ok(json.encode(iotDataList),
        headers: {HttpHeaders.contentTypeHeader: 'application/json'});
  }

  Future<void> _notifyWebSocketClientsForSearch(
      String mqttTopic, List<Map<String, dynamic>> newData) async {
    final jsonResponse = json.encode(newData);
    final encodedMessage = utf8.encode(jsonResponse);

    // Notifica apenas os clientes interessados no tópico MQTT especificado
    activeWebSockets[mqttTopic]?.forEach((channel) {
      channel.sink.add(encodedMessage);
    });
  }

  Future<Response> _getAllIotData(Request request) async {
    final coll = _db.collection('iot_data');
    final iotDataList = await coll.find().toList();
    return Response.ok(json.encode(iotDataList),
        headers: {HttpHeaders.contentTypeHeader: 'application/json'});
  }

  Future<Response> _addIotData(Request request) async {
    final coll = _db.collection('iot_data');
    try {
      final requestBody = await request.readAsString();

      // Verificar se a requestBody é válida
      if (requestBody.isEmpty) {
        return Response.badRequest(body: 'Request body is empty.');
      }

      final iotDataMap = json.decode(requestBody);

      // Certificar-se de que o mapa contém campos essenciais
      if (iotDataMap['value'] == null || iotDataMap['deviceId'] == null) {
        return Response.badRequest(
            body: 'Essential fields are missing in request.');
      }

      final iotData = IoTData.fromMap(iotDataMap);

      // Definindo o campo receivedAt com a data e hora atual
      iotData.receivedAt = DateTime.now().toUtc();

      WriteResult write = await coll.insertOne(iotData.toMap());

      /*if (write.isSuccess) {
        await _notifyWebSocketClients(); // Add this line at the end
        var topic = iotData.mqttTopic;
        if (topic != null) {
          await _notifyWebSocketGraphics(topic, [iotData.toMap()]);
        }
      }*/

      return Response.ok('IoT data saved successfully!');
    } catch (e) {
      print(e);
      if (e is FormatException) {
        return Response.badRequest(body: 'Invalid data format.');
      } else {
        // Esse bloco de catch irá capturar quaisquer outros erros não esperados.
        print(
            "Unexpected error: $e"); // Você pode registrar o erro ou fazer outra ação necessária aqui
        return Response.internalServerError(
            body: 'An unexpected error occurred.');
      }
    }
  }

  Future<Response> _updateIotData(Request request, String id) async {
    final coll = _db.collection('iot_data');
    final requestBody = await request.readAsString();
    final iotDataMap = json.decode(requestBody);
    final updateDocument = {'\$set': iotDataMap};
    final result = await coll.updateOne(
        where.eq('_id', ObjectId.parse(id)), updateDocument);

    if (result.isSuccess && result.nModified > 0) {
      await _notifyWebSocketClients(); // Add this line at the end
      return Response.ok('IoT data updated successfully!');
    } else if (result.isSuccess && result.nModified == 0) {
      return Response.ok('No changes made but the process succeeded.');
    } else {
      return Response.notFound('IoT data not found!');
    }
  }

  Future<Response> _deleteIotData(Request request, String id) async {
    final coll = _db.collection('iot_data');
    final result = await coll.remove(where.eq('_id', ObjectId.parse(id)));
    if (result['n'] > 0) {
      await _notifyWebSocketClients(); // Add this line at the end
      return Response.ok('IoT data deleted successfully!');
    } else {
      return Response.notFound('IoT data not found!');
    }
  }

  Future<Response> _getIotDataById(Request request, String id) async {
    final coll = _db.collection('iot_data');

    // Tente analisar o ID. Se falhar, retorne uma resposta de erro.
    ObjectId? objectId;
    try {
      objectId = ObjectId.parse(id);
    } catch (e) {
      print('Invalid ObjectId format.      $id');
      return Response.badRequest(body: 'Invalid ObjectId format.');
    }

    Map<String, dynamic>? iotData;
    try {
      iotData = await coll.findOne(where.eq('_id', objectId));
    } catch (e) {
      print('Error fetching data from database: $e');
      return Response.internalServerError(
          body: 'Error fetching data from database.');
    }

    if (iotData == null) {
      return Response.notFound('IoT data not found!');
    }

    String jsonData;
    try {
      jsonData = json.encode(iotData);
    } catch (e) {
      print('Error converting data to JSON: $e');
      return Response.internalServerError(
          body: 'Error converting data to JSON.');
    }

    return Response.ok(jsonData,
        headers: {HttpHeaders.contentTypeHeader: 'application/json'});
  }

  Future<Response> _getIotDataByDeviceId(
      Request request, String deviceId) async {
    final coll = _db.collection('iot_data');

    final iotDataList = await coll
        .find(
            where.eq('deviceId', ObjectId.parse(deviceId)).sortBy('receivedAt'))
        .toList();

    if (iotDataList.isNotEmpty) {
      return Response.ok(json.encode(iotDataList),
          headers: {HttpHeaders.contentTypeHeader: 'application/json'});
    } else {
      return Response.notFound('No IoT data found for the provided deviceId!');
    }
  }

  Future<Response> _getIotDataByTimestampAndTopic(Request request) async {
    final coll = _db.collection('iot_data');

    // Extrair parâmetros da query string
    String startTimestamp = request.url.queryParameters['startTimestamp']!;
    String endTimestamp = request.url.queryParameters['endTimestamp']!;
    String mqttTopic = request.url.queryParameters['mqttTopic']!;

    // Convertendo datas para UTC
    final DateTime start = DateTime.parse(startTimestamp).toUtc();
    final DateTime end = DateTime.parse(endTimestamp).toUtc();

    // Não é mais necessário converter os timestamps para DateTime, pois serão usados como strings
    // DateTime start = DateTime.parse(startTimestamp);
    // DateTime end = DateTime.parse(endTimestamp);

    // Construir a query usando strings para 'receivedAt'
    final query = where
        .gte('receivedAt', start)
        .lte('receivedAt', end)
        .eq('mqttTopic', mqttTopic)
        .sortBy(
            'receivedAt'); // Garanta que o campo utilizado aqui corresponde ao que você deseja ordenar

    // Executar a consulta e coletar os resultados
    final iotDataList = await coll.find(query).toList();

    /*if (iotDataList.isEmpty) {
    return Response.notFound('No IoT data found for the specified criteria.');
  }*/
    // Converter a lista de documentos para JSON
    final jsonData = json.encode(iotDataList);
    return Response.ok(jsonData,
        headers: {HttpHeaders.contentTypeHeader: 'application/json'});
  }
}
