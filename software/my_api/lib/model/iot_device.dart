import 'package:mongo_dart/mongo_dart.dart';

/// Representa um dispositivo da Internet das Coisas (IoT).
class IoTDevice {
  ObjectId? id;
  ObjectId? environmentId;
  String? name;
  String? description;
  String? topic;
  String? icon;
  bool? activated;
  DateTime? createdAt;
  DateTime? updatedAt;
  bool? viewReturn; // Novo atributo 'viewReturn'

  /// Cria uma nova instância de IoTDevice.
  ///
  /// Recebe parâmetros opcionais para todas as propriedades do dispositivo.
  IoTDevice({
    this.id,
    this.environmentId,
    this.name,
    this.description,
    this.topic,
    this.icon,
    this.activated,
    this.createdAt,
    this.updatedAt,
    this.viewReturn, // Adicionado ao construtor
  });

  /// Cria um novo IoTDevice a partir de um mapa fornecido.
  ///
  /// O mapa geralmente vem de um banco de dados ou outra fonte de dados.
  IoTDevice.fromMap(Map<String, dynamic> map) {
    if (map['_id'] is ObjectId) {
      id = map['_id'];
    } else if (map['_id'] is String) {
      id = ObjectId.fromHexString(map['_id']);
    }
    try {
      environmentId = ObjectId.fromHexString(map['environmentId'] ?? '');
    } catch (e) {
      print('Erro ao interpretar environmentId: $e');
    }

    name = map['name'];
    description = map['description'];
    topic = map['topic'];
    icon = map['icon'];
    activated = map['activated'];
    viewReturn = map['viewReturn']; // Adicionado conversão do 'viewReturn'

    try {
      if (map['createdAt'] != null) {
        createdAt = DateTime.parse(map['createdAt'].toString());
      }
      if (map['updatedAt'] != null) {
        updatedAt = DateTime.parse(map['updatedAt'].toString());
      }
    } catch (e) {
      print('Erro ao interpretar DateTime: $e');
    }
  }

  /// Converte a instância de IoTDevice em um mapa.
  ///
  /// Isso pode ser útil ao armazenar o objeto em um banco de dados.
  /// Retorna uma representação em mapa do IoTDevice.
  Map<String, dynamic> toMap() {
    Map<String, dynamic> resultMap = {};
    if (id != null) {
      resultMap['_id'] = id;
    }

    if (environmentId != null) {
      resultMap['environmentId'] = environmentId;
    }

    resultMap
      ..['name'] = name
      ..['description'] = description
      ..['topic'] = topic
      ..['icon'] = icon
      ..['activated'] = activated
      ..['viewReturn'] = viewReturn // Adicionado 'viewReturn' ao mapa
      ..['createdAt'] = createdAt?.toIso8601String()
      ..['updatedAt'] = updatedAt?.toIso8601String();

    return resultMap;
  }

  @override

  /// Retorna uma representação em string da instância de IoTDevice.
  String toString() {
    return 'IoTDevice {'
        'id: $id, '
        'environmentId: $environmentId, '
        'name: $name, '
        'description: $description, '
        'topic: $topic, '
        'icon: $icon, '
        'activated: $activated, '
        'createdAt: $createdAt, '
        'updatedAt: $updatedAt, '
        'viewReturn: $viewReturn' // Adicionado 'viewReturn' à representação em string
        '}';
  }
}
