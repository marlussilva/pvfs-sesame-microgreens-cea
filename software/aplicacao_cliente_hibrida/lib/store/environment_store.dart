import 'package:mobx/mobx.dart';
import 'package:my_api/config/my_config.dart';
import 'package:my_api/model/environment.dart';
import 'package:my_api/model/environment_data.dart';
import 'package:my_api/client_services/http/dio_iot.dart';
import 'package:web_socket_channel/io.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

part 'environment_store.g.dart';

class EnvironmentStore = _EnvironmentStore with _$EnvironmentStore;

abstract class _EnvironmentStore with Store {
  final String apiUrl = MyConfig.URL_MY_API;
  final _channel = IOWebSocketChannel.connect(
      '${MyConfig.URL_MY_API_SOCKET}/environment/ws');

  _EnvironmentStore() {
    print("INICIALIZANDO SOCKET + ");
    _channel.stream.listen((message) {
      print(message);
      try {
        final decodedMessage = json.decode(message);
        print(decodedMessage);
        if (!decodedMessage.containsKey('action')) return;

        final action = decodedMessage['action'];
        print(action);
        switch (action) {
          case 'updated_environment':
            if (decodedMessage.containsKey('environment')) {
              final Map<String, dynamic> updatedEnvironment =
                  json.decode(decodedMessage['environment']);
              _updateLocalEnvironmentDirectly(updatedEnvironment);
            }
            break;

          case 'new_environment':
            if (decodedMessage.containsKey('environment')) {
              final Map<String, dynamic> environment =
                  json.decode(decodedMessage['environment']);
              environments.add(environment);
            }
            break;

          case 'updated_status': // Adicionando tratamento para 'updated_status'
            print("Status do ambiente atualizado recebido: $decodedMessage");
            if (decodedMessage.containsKey('environment')) {
              // A variável updatedEnvironment já é um Map<String, dynamic>, não precisa decodificar novamente
              final Map<String, dynamic> updatedEnvironment =
                  decodedMessage['environment'];
              _updateLocalEnvironmentDirectly(updatedEnvironment);
            }
            break;

          case 'deleted_environment':
            if (decodedMessage.containsKey('environment')) {
              final Map<String, dynamic> environment =
                  json.decode(decodedMessage['environment']);
              final String id = environment['_id'];
              _removeLocalEnvironment(id);
            }
            break;

          default:
            print('Unknown WebSocket action: $action');
        }
      } catch (e) {
        print('Error decoding JSON: $e');
      }
    });
  }

  @observable
  ConnectionStatus status = ConnectionStatus.offline;

  @action
  void setConnectionStatus(ConnectionStatus v) => status = v;

  @observable
  ObservableList<Map<String, dynamic>> environments = ObservableList();

  @observable
  Environment? environmentSelected;

  @action
  void setEnvironmentSelected(Environment v) => environmentSelected = v;

  @observable
  EnvironmentData? environmentData;

  @action
  void setEnvironmentData(EnvironmentData d) => environmentData = d;

  @observable
  bool isLoading = false;

  @action
  Future<void> fetchEnvironments() async {
    isLoading = true;
    try {
      final response = await http.get(Uri.parse('$apiUrl/environment/'));
      if (response.statusCode == 200) {
        List<Map<String, dynamic>> fetchedEnvironments =
            List<Map<String, dynamic>>.from(json.decode(response.body));
        environments.clear();
        environments.addAll(fetchedEnvironments);
      } else {
        print(
            'Error in fetchEnvironments: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Error fetching environments: $e');
    } finally {
      isLoading = false;
    }
  }

  @action
  Future<void> addEnvironment(Map<String, dynamic> environment) async {
    try {
      final response = await http.post(
        Uri.parse('$apiUrl/environment/'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(environment),
      );

      if (response.statusCode != 200) {
        print(
            'Error adding environment: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Error adding environment: $e');
    }
  }

  @action
  Future<void> updateEnvironment(
      String id, Map<String, dynamic> environment) async {
    try {
      final response = await http.put(
        Uri.parse('$apiUrl/environment/$id'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(environment),
      );

      if (response.statusCode != 200) {
        print(
            'Error updating environment: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Error updating environment: $e');
    }
  }

  @action
  Future<void> deleteEnvironment(String id) async {
    try {
      final response = await http.delete(Uri.parse('$apiUrl/environment/$id'));
      if (response.statusCode != 200) {
        print(
            'Error deleting environment: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Error deleting environment: $e');
    }
  }

  @action
  void _updateLocalEnvironmentDirectly(
      Map<String, dynamic> updatedEnvironment) {
    final id = updatedEnvironment['_id'];
    final index = environments.indexWhere((e) => e['_id'] == id);
    if (index != -1) {
      environments[index] = updatedEnvironment;
    }
  }

  @action
  void _removeLocalEnvironment(String id) {
    environments.removeWhere((env) => env['_id'] == id);
  }

  @action
  void dispose() {
    _channel.sink.close();
  }

  Future<EnvironmentData?> fetchEnvironmentAndDevices() async {
    if (environmentSelected == null) {
      return null;
    }
    if (environmentSelected?.id != null) {
      var id = environmentSelected!.id!;

      var data = await DioIot.fetchEnvironmentAndDevices(id);
      return data;
    }
    return null;
  }
}
