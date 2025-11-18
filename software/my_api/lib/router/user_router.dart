import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:mongo_dart/mongo_dart.dart';
import 'package:my_api/config/my_config.dart';
import 'package:shelf/shelf.dart' as shelf;
import 'package:shelf_router/shelf_router.dart';

class UserRouter {
  late Db _db;
  final Dio _dio = Dio();

  UserRouter(String databaseUrl) {
    _db = Db(databaseUrl);
    _db.open();
  }

  Future<void> saveImage(Uint8List imageBytes, String fileName) async {
    final formData = FormData.fromMap({
      'file': MultipartFile.fromBytes(imageBytes, filename: fileName),
    });

    try {
      final response = await _dio.post(
        '${MyConfig.URL_SERVER_FILE_IP}/upload/',
        data: formData,
        options: Options(
          headers: {'file-name': fileName},
        ),
      );
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<Uint8List> consolidate(Stream<List<int>> stream) async {
    final completer = Completer<Uint8List>();
    final chunks = <Uint8List>[];
    int totalLength = 0;

    stream.listen(
      (chunk) {
        chunks.add(Uint8List.fromList(chunk));
        totalLength += chunk.length;
      },
      onDone: () {
        final bytes = Uint8List(totalLength);
        int offset = 0;
        for (final chunk in chunks) {
          bytes.setRange(offset, offset + chunk.length, chunk);
          offset += chunk.length;
        }
        completer.complete(bytes);
      },
      onError: completer.completeError,
    );

    return completer.future;
  }

  String generateSalt([int length = 32]) {
    final rand = Random.secure();
    var salt = <int>[];
    for (var i = 0; i < length; i++) {
      salt.add(rand.nextInt(256));
    }
    return base64Encode(salt);
  }

  String hashPassword(String password, String salt) {
    final bytes = utf8.encode('$password$salt');
    return sha256.convert(bytes).toString();
  }

  Router get router {
    final router = Router();

    router.get('/', (shelf.Request request) async {
      final coll = _db.collection('users');
      final List<Map<String, dynamic>> users =
          await coll.find(where.eq('is_deleted', false)).toList();
      final jsonResponse = json.encode(users);
      return shelf.Response.ok(jsonResponse,
          headers: {HttpHeaders.contentTypeHeader: 'application/json'});
    });

    router.post('/', (shelf.Request request) async {
      final coll = _db.collection('users');
      final Map<String, dynamic> user =
          json.decode(await request.readAsString());

      String salt = generateSalt();
      user['salt'] = salt;
      user['password'] = hashPassword(user['password'], salt);
      user['createdAt'] = DateTime.now().toUtc().toString();

      await coll.insertOne(user);

      // Omitir senha e salt da resposta
      user.remove('password');
      user.remove('salt');

      final jsonResponse =
          json.encode({'message': 'User saved successfully!', 'user': user});

      return shelf.Response.ok(jsonResponse,
          headers: {HttpHeaders.contentTypeHeader: 'application/json'});
    });

    router.put('/<id>', (shelf.Request request, String id) async {
      final coll = _db.collection('users');
      final Map<String, dynamic> user =
          json.decode(await request.readAsString());

      user['updatedAt'] = DateTime.now().toUtc().toString();

      final result =
          await coll.update(where.eq('_id', ObjectId.parse(id)), user);
      if (result['updatedExisting']) {
        return shelf.Response.ok('User updated successfully!');
      } else {
        return shelf.Response.notFound('User not found!');
      }
    });

    router.delete('/<id>', (shelf.Request request, String id) async {
      final coll = _db.collection('users');
      final updateInfo = {
        '\$set': {
          'is_deleted': true,
          'deletedAt': DateTime.now().toUtc().toString(),
        }
      };
      final result =
          await coll.update(where.eq('_id', ObjectId.parse(id)), updateInfo);
      if (result['n'] > 0) {
        return shelf.Response.ok('User deleted successfully!');
      } else {
        return shelf.Response.notFound('User not found!');
      }
    });

    router.post('/login', (shelf.Request request) async {
      final coll = _db.collection('users');
      final Map<String, dynamic> data =
          json.decode(await request.readAsString());

      final cpf = data['cpf'];
      final password = data['password'];

      final user = await coll.findOne(where.eq('cpf', cpf));

      if (user == null) {
        return shelf.Response(401,
            body: json.encode({'message': 'User not found'}));
      }

      // Hash the provided password with the user's salt
      final hashedPassword = hashPassword(password, user['salt']);

      if (hashedPassword == user['password']) {
        // Remove sensitive fields from the user object
        user.remove('salt');
        user.remove('password');

        return shelf.Response.ok(
            json.encode({'message': 'Login successful', 'user': user}));
      } else {
        return shelf.Response(401,
            body: json.encode({'message': 'Incorrect password'}));
      }
    });

    router.post('/avatar', (shelf.Request request) async {
      final imageStream = request.read();
      final imageBytes = await consolidate(imageStream);
      final fileName = request.headers['file-name'];
      if (fileName == null) {
        return shelf.Response(400, body: 'file-name header is required');
      }
      await saveImage(imageBytes, fileName);
      return shelf.Response.ok(
        imageBytes,
        headers: {'content-type': 'image/jpeg'},
      );
    });

    router.post('/checkcpf', (shelf.Request request) async {
      final coll = _db.collection('users');
      final Map<String, dynamic> data =
          json.decode(await request.readAsString());
      final cpf = data['cpf'];
      final user = await coll.findOne(where.eq('cpf', cpf));
      if (user != null) {
        final jsonResponse = json.encode({'exists': true, 'user': user});
        return shelf.Response.ok(jsonResponse,
            headers: {HttpHeaders.contentTypeHeader: 'application/json'});
      } else {
        final jsonResponse = json.encode({'exists': false});
        return shelf.Response.ok(jsonResponse,
            headers: {HttpHeaders.contentTypeHeader: 'application/json'});
      }
    });

    return router;
  }
}
