import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:mongo_dart/mongo_dart.dart';
import 'package:my_api/model/organization.dart';
import 'package:shelf/shelf.dart' as shelf;
import 'package:shelf_router/shelf_router.dart';

class OrganizationRouter {
  late Db _db;

  OrganizationRouter(String databaseUrl) {
    _db = Db(databaseUrl);
    _db.open();
  }

  Router get router {
    final router = Router();

    router.get('/', _getAllOrganizations);
    router.post('/', _createOrganization);
    router.put('/<id>', _updateOrganization);
    router.delete('/<id>', _deleteOrganization);

    return router;
  }

  Future<shelf.Response> _getAllOrganizations(shelf.Request request) async {
    try {
      final coll = _db.collection('organizations');
      final organizations = await coll.find().toList();
      final jsonResponse = json.encode(organizations);
      return shelf.Response.ok(jsonResponse, headers: {
        HttpHeaders.contentTypeHeader: 'application/json',
      });
    } catch (e) {
      return shelf.Response.internalServerError(
          body: json.encode({'error': 'An error occurred: $e'}));
    }
  }

  Future<shelf.Response> _createOrganization(shelf.Request request) async {
    try {
      final coll = _db.collection('organizations');
      final body = json.decode(await request.readAsString());
      final organization = Organization.fromMap(body);
      await coll.insertOne(organization.toMap());
      return shelf.Response.ok(
          json.encode({'message': 'Organization created'}));
    } catch (e) {
      return shelf.Response.internalServerError(
          body: json.encode({'error': 'An error occurred: $e'}));
    }
  }

  Future<shelf.Response> _updateOrganization(
      shelf.Request request, String id) async {
    try {
      final coll = _db.collection('organizations');
      final updatedData = json.decode(await request.readAsString());

      final modifier = ModifierBuilder();
      updatedData.forEach((key, value) {
        if (key != '_id') {
          modifier.set(key, value);
        }
      });

      final updateResult = await coll.updateOne(
        where.id(ObjectId.parse(id)),
        modifier,
      );

      if (updateResult.isSuccess) {
        return shelf.Response.ok('Organization updated successfully!');
      } else {
        return shelf.Response.notFound('Organization not found!');
      }
    } catch (e) {
      return shelf.Response.internalServerError(
          body: json.encode({'error': 'An error occurred: $e'}));
    }
  }

  Future<shelf.Response> _deleteOrganization(
      shelf.Request request, String id) async {
    try {
      final coll = _db.collection('organizations');
      final deleteResult = await coll.deleteOne(where.id(ObjectId.parse(id)));

      if (deleteResult.isSuccess && deleteResult.nRemoved == 1) {
        return shelf.Response.ok(
            json.encode({'message': 'Organization deleted successfully'}));
      } else if (deleteResult.nRemoved == 0) {
        return shelf.Response.notFound(
            json.encode({'message': 'Organization not found'}));
      } else {
        // Esse caso pode não ser necessário, pois nRemoved não ser maior que 1
        // ou diferente de zero é improvável e pode indicar uma exceção lançada
        return shelf.Response.internalServerError(
            body: json.encode({'error': 'An unexpected error occurred'}));
      }
    } catch (e) {
      return shelf.Response.internalServerError(
          body: json.encode({
        'error': 'An error occurred while deleting the organization: $e'
      }));
    }
  }
}
