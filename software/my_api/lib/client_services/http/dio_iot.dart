import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:mongo_dart/mongo_dart.dart';
import 'package:my_api/config/my_config.dart';
import 'package:my_api/model/environment_data.dart';
import 'package:my_api/model/iot_device.dart';

class DioIot {
  static final Dio _dio = Dio();
  static const URL = '${MyConfig.URL_MY_API}/iot/';

  // Método que busca dados de dispositivo baseado em uma chave composta.
  // Método que busca dados de dispositivo baseado em uma chave composta.
  static Future<IoTDevice?> fetchDeviceByComposedKey(String composedKey) async {
    final url = '${URL}by-composed-key?composedKey=$composedKey';

    try {
      final response = await _dio.get(url);

      if (response.statusCode == 200) {
        // Quando bem-sucedido, deserializamos o JSON.
        if (response.data is! Map<String, dynamic>) {
          print('Erro: Formato de resposta inesperado');
          return null;
        }

        Map<String, dynamic> jsonData = response.data;

        // Verificamos se os dados são válidos e contêm as chaves necessárias.
        if (jsonData.containsKey('device')) {
          var device = jsonData['device'];

          if (device is! Map<String, dynamic>) {
            print('Erro: Estrutura de dados do dispositivo inválida');
            return null;
          }

          return IoTDevice.fromMap(device);
        } else {
          print('Erro: A chave "device" não existe no JSON recebido');
          return null;
        }
      } else {
        print(
            'Erro ao buscar o dispositivo: Status code ${response.statusCode}');
        return null;
      }
    } on DioException catch (dioError) {
      // Tratando erros específicos do Dio.
      print('Erro Dio: ${dioError.message}');

      return null;
    } catch (e) {
      // Se capturamos qualquer outra exceção, imprimimos no console.
      print('Erro inesperado: $e');
      return null;
    }
  }

  static Future<EnvironmentData> fetchEnvironmentAndDevices(
      ObjectId environmentId) async {
    final endpoint =
        '${URL}topics/by-environment/${environmentId.toHexString()}';
    try {
      final response = await _dio.get(endpoint);

      // Verificando o statusCode e se a resposta não é null
      if (response.statusCode == 200 && response.data != null) {
        // Você pode querer verificar o formato dos dados antes de retornar
        return EnvironmentData.fromMap(response.data);
      } else {
        print('Erro ao buscar ambiente e dispositivos: ${response.statusCode}');
        throw Exception(
            'Erro ao buscar ambiente e dispositivos. Código de resposta: ${response.statusCode}');
      }
    } on DioException catch (dioError) {
      // Captura erros específicos da biblioteca Dio
      print('Erro Dio na requisição: ${dioError.message}');
      throw Exception(
          'Erro na comunicação com o servidor: ${dioError.message}');
    } catch (e) {
      // Captura outros erros não previstos
      print('Ocorreu um erro inesperado na requisição: $e');
      throw Exception('Erro inesperado durante a requisição: $e');
    }
  }

  static Future<bool> deviceExistsForEnvironment(ObjectId environmentId) async {
    try {
      var response =
          await _dio.get(URL + 'environment/${environmentId.toHexString()}');

      // Se a resposta for 200 e houver pelo menos um dispositivo, retornar verdadeiro
      if (response.statusCode == 200 && response.data != null) {
        var jsonData = response.data as List;
        return jsonData
            .isNotEmpty; // Retorna verdadeiro se a lista não estiver vazia
      } else {
        print(
            'Erro ao verificar a existência do dispositivo: ${response.statusCode}');
        return false; // Retorna falso se a resposta não for 200 ou não houver dados
      }
    } on DioException catch (dioError) {
      // Captura erros específicos da biblioteca Dio
      print('Erro Dio na requisição: ${dioError.message}');
      return false; // Retorna falso se houver um erro de conexão ou resposta
    } catch (e) {
      // Captura outros erros não previstos
      print('Ocorreu um erro inesperado na requisição: $e');
      return false; // Retorna falso para erros inesperados
    }
  }

  static Future<bool> save(IoTDevice ioTDevice) async {
    try {
      // Convertendo o objeto Environment para um mapa

      Map<String, dynamic> data = ioTDevice.toMap();

      // Configurando os headers se necessário (ajuste conforme a necessidade)
      var headers = {
        'Content-Type': 'application/json',
      };

      // Realizando a requisição POST
      var response = await _dio.post(URL,
          data: json.encode(data), options: Options(headers: headers));

      if (response.statusCode == 200) {
        print('Environment salvo com sucesso!');
        return true;
      } else {
        print('Erro ao salvar Environment: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('Ocorreu um erro na requisição: $e');
      return false;
    }
  }

  static Future<List<IoTDevice>> fetchAll(ObjectId environmentId) async {
    print(URL + 'environment/${environmentId.toHexString()}');
    try {
      var response =
          await _dio.get(URL + 'environment/${environmentId.toHexString()}');

      // Verificando o statusCode e se a resposta não é null
      if (response.statusCode == 200 && response.data != null) {
        var jsonData = response.data as List;
        List<IoTDevice> devices =
            jsonData.map((data) => IoTDevice.fromMap(data)).toList();
        return devices;
      } else {
        print('Erro ao buscar dispositivos: ${response.statusCode}');
        // Você pode lançar um erro personalizado ou retornar uma lista vazia
        throw Exception(
            'Erro ao buscar dispositivos. Código de resposta: ${response.statusCode}');
      }
    } on DioException catch (dioError) {
      // Captura erros específicos da biblioteca Dio
      print('Erro Dio na requisição: ${dioError.message}');
      throw Exception(
          'Erro na comunicação com o servidor: ${dioError.message}');
    } catch (e) {
      // Captura outros erros não previstos
      print('Ocorreu um erro inesperado na requisição: $e');
      throw Exception('Erro inesperado durante a requisição: $e');
    }
  }

  static Future<bool> update(IoTDevice ioTDevice) async {
    var urlUpdate;
    print(urlUpdate);
    try {
      // Convertendo o objeto IoTDevice para um mapa
      Map<String, dynamic> data = ioTDevice.toMap();

      // Se o IoTDevice não tiver um ID, não podemos atualizá-lo
      if (ioTDevice.id == null) {
        print('Erro: IoTDevice sem ID não pode ser atualizado.');
        return false;
      } else {
        urlUpdate = '$URL${ioTDevice.id?.toHexString()}';
      }

      // Configurando os headers se necessário (ajuste conforme a necessidade)
      var headers = {
        'Content-Type': 'application/json',
      };

      // Realizando a requisição PUT (ou PATCH se preferir)
      var response = await _dio.put(urlUpdate,
          data: json.encode(data), options: Options(headers: headers));

      if (response.statusCode == 200) {
        print('IoTDevice atualizado com sucesso!');
        return true;
      } else {
        print('Erro ao atualizar IoTDevice: ${response.statusCode}');
        return false;
      }
    } on DioException catch (e) {
      // Tratando erros específicos do Dio
      if (e.response != null) {
        print('Erro ao atualizar IoTDevice: ${e.response!.data}');
      } else {
        print('Erro ao enviar requisição: ${e.message}');
      }
      return false;
    } catch (e) {
      print('Ocorreu um erro inesperado: $e');
      return false;
    }
  }

  static Future<bool> delete(IoTDevice ioTDevice) async {
    print('$URL${ioTDevice.id!.toHexString()}');
    try {
      // Configurando os headers se necessário (ajuste conforme a necessidade)
      var headers = {
        'Content-Type': 'application/json',
      };

      // Realizando a requisição DELETE
      var response = await _dio.delete(
        '$URL${ioTDevice.id!.toHexString()}', // A URL deveria ser algo como /devices/{id} para excluir um dispositivo específico
        options: Options(headers: headers),
      );

      if (response.statusCode == 200) {
        print('IoT Device excluído com sucesso!');
        return true;
      } else {
        print('Erro ao excluir IoT Device: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('Ocorreu um erro na requisição: $e');
      return false;
    }
  }

  static Future<bool> isTopicUnique(String topic, String environmentId) async {
    try {
      // Realizando a requisição GET
      var response = await _dio.get(
        '${URL}topic',
        queryParameters: {
          'topic': topic,
          'environmentId': environmentId,
        },
      );

      // Verificando o statusCode e se a resposta não é null
      if (response.statusCode == 200 && response.data != null) {
        var jsonData = response.data;
        print(jsonData);
        return jsonData['exists'] ??
            false; // Se 'exists' for true, o tópico é único; caso contrário, não é.
      } else {
        print('Erro ao verificar unicidade do tópico: ${response.statusCode}');
        return false;
      }
    } on DioException catch (dioError) {
      // Captura erros específicos da biblioteca Dio
      print('Erro Dio na requisição: ${dioError.message}');
      return false;
    } catch (e) {
      // Captura outros erros não previstos
      print('Ocorreu um erro inesperado na requisição: $e');
      return false;
    }
  }

  static Future<EnvironmentData> fetchByComposedKey(String composedKey) async {
    // Adicionando o composedKey como uma query string
    //http://localhost:8080/iot/by-composed-key?composedKey=cv1/temperatura1
    final endpoint = '${URL}by-composed-key?composedKey=$composedKey';
    try {
      final response = await _dio.get(endpoint);

      if (response.statusCode == 200 && response.data != null) {
        // Converte os dados de resposta em um mapa e então cria um objeto EnvironmentData
        return EnvironmentData.fromMap(response.data);
      } else {
        print('Erro ao buscar ambiente e dispositivo: ${response.statusCode}');
        throw Exception(
            'Erro ao buscar ambiente e dispositivo. Código de resposta: ${response.statusCode}');
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
}
