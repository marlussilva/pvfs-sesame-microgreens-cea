import 'package:mongo_dart/mongo_dart.dart';

// Definindo um enum para os estados de conexão
enum ConnectionStatus { online, offline }

class Environment {
  ObjectId? id;
  String? name;
  String? acronym;
  String? description;
  int? type;
  String? location;
  bool? activated;
  DateTime? createdAt;
  DateTime? updatedAt;
  ConnectionStatus? status; // Adicionando o novo campo "status"

  Environment({
    this.id,
    this.name,
    this.acronym,
    this.description,
    this.type,
    this.location,
    this.activated,
    this.createdAt,
    this.updatedAt,
    this.status, // Adicionando o novo parâmetro "status"
  });

  // Modificando fromMap para lidar com o novo campo "status"
  Environment.fromMap(Map<String, dynamic> map) {
    print(map);
    if (map['_id'] is ObjectId) {
      id = map['_id'];
    } else if (map['_id'] is String) {
      id = ObjectId.fromHexString(map['_id']);
    }
    name = map['name'];
    acronym = map['acronym'];
    description = map['description'];
    type = map['type'];
    location = map['location'];
    activated = map['activated'];
    if (map['createdAt'] != null) {
      createdAt = DateTime.parse(map['createdAt'].toString());
    }
    if (map['updatedAt'] != null) {
      updatedAt = DateTime.parse(map['updatedAt'].toString());
    }
    // Convertendo o status de string para enum
    if (map['status'] != null) {
      status = ConnectionStatus.values.firstWhere(
        (e) => e.toString().split('.').last == map['status'],
        orElse: () => ConnectionStatus.offline, // Default ou erro
      );
    }
  }

  // Modificando toMap para incluir o campo "status"
  Map<String, dynamic> toMap() {
    return {
      '_id': id,
      'name': name,
      'acronym': acronym,
      'description': description,
      'type': type,
      'location': location,
      'activated': activated,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'status':
          status?.toString().split('.').last, // Convertendo enum para string
    };
  }

  @override
  String toString() {
    return 'Environment {'
        'id: $id, '
        'name: $name, '
        'acronym: $acronym, '
        'description: $description, '
        'type: $type, '
        'location: $location, '
        'activated: $activated, '
        'createdAt: $createdAt, '
        'updatedAt: $updatedAt, '
        'status: ${status?.toString().split('.').last}' // Adicionando "status" à representação de string
        '}';
  }
}
