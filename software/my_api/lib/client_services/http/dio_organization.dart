import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:my_api/config/my_config.dart';
import 'package:my_api/model/organization.dart';

class DioOrganization {
  static final Dio _dio = Dio();
  static final String _url = '${MyConfig.URL_MY_API}/organization/';

  static Future<bool> save(Organization organization) async {
    try {
      var data = organization.toMap();
      var headers = {'Content-Type': 'application/json'};
      var response = await _dio.post(_url,
          data: json.encode(data), options: Options(headers: headers));

      if (response.statusCode == 200) {
        print('Organization saved successfully!');
        return true;
      } else {
        return false;
        print('Error when saving Organization: ${response.statusCode}');
      }
    } catch (e) {
      print('An error occurred during the request: $e');
      return false;
    }
  }

  static Future<List<Organization>> fetchOrganizations() async {
    try {
      final response = await _dio.get(_url);

      if (response.statusCode == 200) {
        final List<Organization> organizations = (response.data as List)
            .map((i) => Organization.fromMap(i))
            .toList();
        return organizations;
      } else {
        throw Exception('Failed to load organizations');
      }
    } catch (error) {
      print(error.toString());
      throw error;
    }
  }

  static Future<Organization?> fetchOrganizationById(String id) async {
    try {
      final response = await _dio.get('$_url$id');

      if (response.statusCode == 200) {
        return Organization.fromMap(response.data);
      } else {
        throw Exception('Failed to load organization');
      }
    } catch (error) {
      print(error.toString());
      throw error;
    }
  }

  static Future<void> update(Organization organization) async {
    try {
      if (organization.id == null) {
        throw Exception('Organization to be updated must have a valid ID.');
      }

      var data = organization.toMap();
      var headers = {'Content-Type': 'application/json'};
      var response = await _dio.put('$_url${organization.id}',
          data: json.encode(data), options: Options(headers: headers));

      if (response.statusCode == 200) {
        print('Organization updated successfully!');
      } else {
        print('Error updating Organization: ${response.statusCode}');
      }
    } catch (e) {
      print('An error occurred during the request: $e');
    }
  }

  static Future<void> delete(String id) async {
    try {
      var headers = {'Content-Type': 'application/json'};
      var response =
          await _dio.delete('$_url$id', options: Options(headers: headers));

      if (response.statusCode == 200) {
        print('Organization deleted successfully!');
      } else {
        print('Error deleting Organization: ${response.statusCode}');
      }
    } catch (e) {
      print('An error occurred during the request: $e');
    }
  }
}
