import 'package:mongo_dart/mongo_dart.dart';

import '../model/user.dart';

class UserRepository {
  final Db db;
  final String collectionName = 'users';

  UserRepository(this.db);

  Future<List<User>> getAll() async {
    final collection = db.collection(collectionName);
    final users = await collection.find().toList();
    return users.map((u) => User.fromMap(u)).toList();
  }

  Future<User?> getById(String id) async {
    final collection = db.collection(collectionName);
    final user = await collection.findOne(where.id(ObjectId.parse(id)));
    return user != null ? User.fromMap(user) : null;
  }

  Future<User> create(User user) async {
    final collection = db.collection(collectionName);
    final result = await collection.insertOne(user.toMap());
    return user.copyWith(id: result.nInserted as ObjectId);
  }

  Future<void> update(String id, User user) async {
    final collection = db.collection(collectionName);
    await collection.updateOne(where.id(ObjectId.parse(id)), user.toMap());
  }

  Future<void> delete(String id) async {
    final collection = db.collection(collectionName);
    await collection.deleteOne(where.id(ObjectId.parse(id)));
  }
}
