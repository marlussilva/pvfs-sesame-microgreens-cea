import 'package:mongo_dart/mongo_dart.dart';

Future<void> main() async {
  final db = Db("mongodb://root:example@192.168.1.80:27017/leav");

  try {
    await db.open();
    print("Connected to MongoDB successfully.");
  } catch (e) {
    print("Error connecting to MongoDB: $e");
  } finally {
    await db.close();
  }
}
