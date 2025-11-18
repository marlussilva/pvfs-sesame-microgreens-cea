import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:mongo_dart/mongo_dart.dart';
import 'package:my_api/config/my_config.dart';
import 'package:my_api/model/iot_data.dart';

class DioIotData {
  static final Dio _dio = Dio();
  static const URL = '${MyConfig.URL_MY_API}/iot_data/';

  static Future<List<Map<String, dynamic>>> grafico({
    required String mqttTopic,
    required DateTime startTimestamp,
    required DateTime endTimestamp,
  }) async {
    // Formatando os timestamps para serem compatíveis com ISO 8601
    final String start = startTimestamp.toIso8601String();
    final String end = endTimestamp.toIso8601String();

    // Construindo a URL com parâmetros de consulta
    final String endpoint =
        '${URL}grafico?startTimestamp=$start&endTimestamp=$end&mqttTopic=$mqttTopic';

    try {
      final response = await _dio.get(endpoint);

      // Verificar se a resposta é bem-sucedida
      if (response.statusCode == 200 && response.data != null) {
        // Aqui assumimos que a resposta é diretamente uma lista de objetos
        // Portanto, fazemos a conversão diretamente
        List<Map<String, dynamic>> dataList =
            List<Map<String, dynamic>>.from(response.data);
        return dataList;
      } else {
        print('Erro ao buscar dados: ${response.statusCode}');
        throw Exception(
            'Erro ao buscar dados. Código de resposta: ${response.statusCode}');
      }
    } catch (e) {
      print('Erro na requisição: $e');
      throw Exception('Erro na comunicação com o servidor: $e');
    }
  }

  static Future<List<Map<String, dynamic>>> graficoSemInterpolacao({
    required String mqttTopic,
    required DateTime startTimestamp,
    required DateTime endTimestamp,
  }) async {
    // Formatando os timestamps para serem compatíveis com ISO 8601
    final String start = startTimestamp.toIso8601String();
    final String end = endTimestamp.toIso8601String();

    // Construindo a URL com parâmetros de consulta
    final String endpoint =
        '${URL}grafico-sem?startTimestamp=$start&endTimestamp=$end&mqttTopic=$mqttTopic';
    print(endpoint);
    try {
      final response = await _dio.get(endpoint);

      // Verificar se a resposta é bem-sucedida
      if (response.statusCode == 200 && response.data != null) {
        // Aqui assumimos que a resposta é diretamente uma lista de objetos
        // Portanto, fazemos a conversão diretamente
        List<Map<String, dynamic>> dataList =
            List<Map<String, dynamic>>.from(response.data);
        return dataList;
      } else {
        print('Erro ao buscar dados: ${response.statusCode}');
        throw Exception(
            'Erro ao buscar dados. Código de resposta: ${response.statusCode}');
      }
    } catch (e) {
      print('Erro na requisição: $e');
      throw Exception('Erro na comunicação com o servidor: $e');
    }
  }

  static Future<List<IoTData>> fetchIotDataByTopicAndTimestampRange({
    required String mqttTopic,
    required DateTime startTimestamp,
    required DateTime endTimestamp,
  }) async {
    // Formatando os timestamps para serem compatíveis com ISO 8601
    final String start = startTimestamp.toIso8601String();
    final String end = endTimestamp.toIso8601String();

    // Construindo a URL com parâmetros de consulta
    final String endpoint =
        '${URL}search-and-notify?startTimestamp=$start&endTimestamp=$end&mqttTopic=$mqttTopic';

    try {
      final response = await _dio.get(endpoint);

      // Verificar se a resposta é bem-sucedida
      if (response.statusCode == 200 && response.data != null) {
        // Convertendo os dados da resposta em uma lista de IoTData
        List<IoTData> dataList = (response.data as List)
            .map((data) => IoTData.fromMap(data))
            .toList();
        return dataList;
      } else {
        print('Erro ao buscar dados: ${response.statusCode}');
        throw Exception(
            'Erro ao buscar dados. Código de resposta: ${response.statusCode}');
      }
    } catch (e) {
      print('Erro na requisição: $e');
      throw Exception('Erro na comunicação com o servidor: $e');
    }
  }

  static Future<List<IoTData>> fetchIotDataByTimestampAndTopic({
    required DateTime startTimestamp,
    required DateTime endTimestamp,
    required String mqttTopic,
  }) async {
    // Formatando os timestamps para serem compatíveis com ISO 8601
    final String start = startTimestamp.toIso8601String();
    final String end = endTimestamp.toIso8601String();

    // Construindo a URL com parâmetros de consulta
    final String endpoint =
        '${URL}search?startTimestamp=$start&endTimestamp=$end&mqttTopic=$mqttTopic';
    print(endpoint);
    try {
      final response = await _dio.get(endpoint);

      // Verificar se a resposta é bem-sucedida
      if (response.statusCode == 200 && response.data != null) {
        // Convertendo os dados da resposta em uma lista de IoTData
        List<IoTData> dataList = (response.data as List)
            .map((data) => IoTData.fromMap(data))
            .toList();
        return dataList;
      } else {
        print('Erro ao buscar dados: ${response.statusCode}');
        throw Exception(
            'Erro ao buscar dados. Código de resposta: ${response.statusCode}');
      }
    } on DioException catch (dioError) {
      print('Erro na requisição Dio: ${dioError.message}');
      throw Exception(
          'Erro na comunicação com o servidor: ${dioError.message}');
    } catch (e) {
      print('Erro inesperado na requisição: $e');
      throw Exception('Erro inesperado durante a requisição: $e');
    }
  }

  static Future<IoTData> fetchIotData(ObjectId deviceId) async {
    final endpoint = '${URL}${deviceId.toHexString()}';
    try {
      final response = await _dio.get(endpoint);

      if (response.statusCode == 200 && response.data != null) {
        return IoTData.fromMap(response.data);
      } else {
        print('Erro ao buscar dados do dispositivo: ${response.statusCode}');
        throw Exception(
            'Erro ao buscar dados do dispositivo. Código de resposta: ${response.statusCode}');
      }
    } on DioException catch (dioError) {
      print('Erro Dio na requisição: ${dioError.message}');
      throw Exception(
          'Erro na comunicação com o servidor: ${dioError.message}');
    } catch (e) {
      print('Ocorreu um erro inesperado na requisição: $e');
      throw Exception('Erro inesperado durante a requisição: $e');
    }
  }

  static Future<bool> saveIotData(
    IoTData iotData,
  ) async {
    print(iotData);
    try {
      Map<String, dynamic> data = iotData.toMap();

      if (iotData.receivedAt != null)
        data['receivedAt'] = iotData.receivedAt?.toIso8601String();
      if (iotData.timestamp != null)
        data['timestamp'] = iotData.timestamp?.toIso8601String();
      var enviar = json.encode(data);

      var headers = {
        'Content-Type': 'application/json',
      };
      var response = await _dio.post(URL,
          data: enviar, options: Options(headers: headers));

      if (response.statusCode == 200) {
        print('Dados IoT salvos com sucesso!');
        return true;
      } else {
        print('Erro ao salvar dados IoT: ${response.statusCode}');
        return false;
      }
    } on DioException catch (e) {
      handleDioError(e);
      return false;
    }
  }

  static Future<List<IoTData>> fetchAllIotDataByDeviceId(
      ObjectId deviceId) async {
    final endpoint = '${URL}device/${deviceId.toHexString()}';
    try {
      final response = await _dio.get(endpoint);

      if (response.statusCode == 200 && response.data != null) {
        List<IoTData> dataList = (response.data as List)
            .map((data) => IoTData.fromMap(data))
            .toList();
        return dataList;
      } else {
        print('Erro ao buscar dados do dispositivo: ${response.statusCode}');
        throw Exception(
            'Erro ao buscar dados do dispositivo. Código de resposta: ${response.statusCode}');
      }
    } on DioException catch (dioError) {
      print('Erro Dio na requisição: ${dioError.message}');
      throw Exception(
          'Erro na comunicação com o servidor: ${dioError.message}');
    } catch (e) {
      print('Ocorreu um erro inesperado na requisição: $e');
      throw Exception('Erro inesperado durante a requisição: $e');
    }
  }

  static void handleDioError(DioException e) {
    String message;
    // Atualizado para a nova terminologia

    // Ajuste do switch case para lidar com o novo DioExceptionType
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
        message = "Connection timeout with server";
        break;
      case DioExceptionType.sendTimeout:
        message = "Send timeout in connection with server";
        break;
      case DioExceptionType.receiveTimeout:
        message = "Receive timeout in connection with server";
        break;
      case DioExceptionType.connectionError:
        message = "Received invalid status code: ${e.response?.statusCode}";
        // Você pode querer verificar o `e.response?.data` para mais detalhes fornecidos pelo servidor
        break;
      case DioExceptionType.cancel:
        message = "Request to server was cancelled";
        break;
      case DioExceptionType.unknown:
        message = "Other error: ${e.message}";
        break;
      default:
        message = "Unknown error: ${e.message}";
    }

    // Manipulação das mensagens de erro
    print(message);

    // Dependendo da gravidade do erro, você pode querer lançar a exceção novamente ou lidar com ela de maneira específica.
  }

  // Outros métodos para editar, deletar, ou listar os dados de IoT podem seguir um padrão similar
}
