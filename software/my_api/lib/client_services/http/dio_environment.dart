import 'package:mongo_dart/mongo_dart.dart';
import 'package:my_api/config/my_config.dart';
import 'package:my_api/model/environment.dart';

import 'dart:convert';
import 'package:dio/dio.dart';

// Supondo que a classe Environment esteja definida no mesmo arquivo ou importada

class DioEnvironment {
  static final Dio _dio = Dio();
  static final URL = '${MyConfig.URL_MY_API}/environment/';

  // Método para atualizar o status de um Environment e retornar o objeto atualizado
  // Método para atualizar o status de um Environment e retornar o objeto atualizado
  static Future<Environment> updateEnvironmentStatus(
      Environment environment) async {
    // Verificando se o ID é nulo
    if (environment.id == null) {
      throw Exception('O ambiente a ser atualizado precisa ter um ID válido.');
    }

    try {
      // Convertendo o ID para uma string hex
      final String idHexString = environment.id!.toHexString();

      // URL para a rota de atualização de status
      final String updateStatusUrl = '${URL}update-status/$idHexString';

      // Preparando os dados para serem enviados na requisição
      Map<String, dynamic> data = {
        'status': environment.status.toString().split('.').last
      };

      // Configurando os headers para a requisição
      var headers = {
        'Content-Type': 'application/json',
      };

      // Realizando a requisição PUT para atualizar o status
      var response = await _dio.put(updateStatusUrl,
          data: json.encode(data), options: Options(headers: headers));

      // Verificando o sucesso da resposta
      if (response.statusCode == 200) {
        print('Status do Environment atualizado com sucesso!');

        // Atualizando o objeto Environment com quaisquer dados retornados pela API, se necessário
        // Aqui você precisa decidir com base no seu backend. Se ele retornar o objeto atualizado, faça:
        // final Environment updatedEnvironment = Environment.fromMap(response.data);
        // return updatedEnvironment;

        // Se a API não retornar o objeto atualizado, simplesmente retorne o ambiente que foi passado:
        return environment;
      } else {
        print(
            'Erro ao atualizar o status do Environment: ${response.statusCode}');
        throw Exception('Erro ao atualizar o status do Environment');
      }
    } catch (e) {
      print('Ocorreu um erro na requisição de atualização de status: $e');
      throw e; // Relançando a exceção para ser tratada pelo chamador
    }
  }

  static Future<Environment> save(Environment environment) async {
    try {
      // Convertendo o objeto Environment para um mapa
      Map<String, dynamic> data = environment.toMap();
      // Configurando os headers se necessário (ajuste conforme a necessidade)
      var headers = {
        'Content-Type': 'application/json',
      };

      // Realizando a requisição POST
      var response = await _dio.post(URL,
          data: json.encode(data), options: Options(headers: headers));

      if (response.statusCode == 200) {
        print('Environment salvo com sucesso!');
        var newId = ObjectId.fromHexString(response.data['_id']);
        environment.id = newId;

        return environment; // Retornando o environment atualizado
      } else {
        print('Erro ao salvar Environment: ${response.statusCode}');
        throw Exception('Erro ao salvar Environment');
      }
    } catch (e) {
      print('Ocorreu um erro na requisição: $e');
      throw e; // Relançando a exceção para ser tratada pelo chamador
    }
  }

  static Future<List<Environment>> fetchEnvironments() async {
    try {
      final response = await _dio.get(URL);

      // Verifique se a solicitação foi bem-sucedida
      if (response.statusCode == 200) {
        // Converta a resposta em uma lista de objetos 'Environment'
        final List<Environment> environments =
            (response.data as List).map((i) => Environment.fromMap(i)).toList();
        return environments;
      } else {
        throw Exception('Failed to load environments');
      }
    } catch (error) {
      print(error.toString());
      throw error;
    }
  }

  static Future<List<Environment>> fetchEnvironmentsByName(String name) async {
    try {
      final response = await _dio.get("${URL}search?name=$name");

      // Verifique se a solicitação foi bem-sucedida
      if (response.statusCode == 200) {
        // Converta a resposta em uma lista de objetos 'Environment'
        final List<Environment> environments =
            (response.data as List).map((i) => Environment.fromMap(i)).toList();
        return environments;
      } else {
        throw Exception('Failed to load environments');
      }
    } catch (error) {
      print(error.toString());
      throw error;
    }
  }

  static Future<bool> doesAcronymExist(String acronym) async {
    try {
      final response = await _dio.get("${URL}check-acronym?acronym=$acronym");

      // Verifique se a solicitação foi bem-sucedida
      if (response.statusCode == 200) {
        // Verifique se a sigla existe com base na resposta
        return response.data['exists'] ?? false;
      } else {
        throw Exception('Failed to check acronym existence');
      }
    } catch (error) {
      print(error.toString());
      throw error;
    }
  }

  static Future<void> update(Environment environment) async {
    print("${URL}${environment.id!.toHexString()}");
    try {
      // Verificando se o ID é nulo
      if (environment.id == null) {
        throw Exception(
            'O ambiente a ser atualizado precisa ter um ID válido.');
      }

      // Convertendo o objeto Environment para um mapa
      Map<String, dynamic> data = environment.toMap();

      // Configurando os headers se necessário (ajuste conforme a necessidade)
      var headers = {
        'Content-Type': 'application/json',
      };

      // Realizando a requisição PUT
      var response = await _dio.put(
          "${URL}${environment.id!.toHexString()}", // Adicionando o ID à URL
          data: json.encode(data),
          options: Options(headers: headers));

      if (response.statusCode == 200) {
        print('Environment atualizado com sucesso!');
      } else {
        print('Erro ao atualizar Environment: ${response.statusCode}');
      }
    } catch (e) {
      print('Ocorreu um erro na requisição: $e');
    }
  }

  static Future<void> delete(String id) async {
    try {
      // Configurando os headers se necessário (ajuste conforme a necessidade)
      var headers = {
        'Content-Type': 'application/json',
      };

      // Realizando a requisição DELETE
      var response = await _dio.delete("${URL}$id", // Adicionando o ID à URL
          options: Options(headers: headers));

      if (response.statusCode == 200) {
        print('Environment deletado com sucesso!');
      } else {
        print('Erro ao deletar Environment: ${response.statusCode}');
      }
    } catch (e) {
      print('Ocorreu um erro na requisição: $e');
    }
  }

  static Future<Environment> fetchEnvironmentByAcronym(String acronym) async {
    try {
      // Realizando a requisição GET com o acronym
      var response = await _dio.get("${URL}by-acronym/$acronym");

      // Verifique se a solicitação foi bem-sucedida
      if (response.statusCode == 200) {
        // Converta a resposta em um objeto 'Environment'
        final Environment environment = Environment.fromMap(response.data);
        return environment;
      } else {
        throw Exception('Failed to load environment by acronym');
      }
    } catch (error) {
      print(error.toString());
      throw error; // Relançando a exceção para ser tratada pelo chamador
    }
  }
}
