import 'package:mongo_dart/mongo_dart.dart';

class IoTData {
  ObjectId? id;
  dynamic value;
  DateTime? timestamp;
  DateTime? receivedAt;
  ObjectId? deviceId;
  String? mqttTopic;
  String? unit;

  IoTData({
    this.id,
    this.value,
    this.timestamp,
    this.receivedAt,
    this.deviceId,
    this.mqttTopic,
    this.unit,
  });

  // Método para converter um mapa em uma instância de IoTData
IoTData.fromMap(Map<String, dynamic> map) {
  id = map['_id'] is ObjectId ? map['_id'] : (map['_id'] != null ? ObjectId.fromHexString(map['_id']) : null);
  value = map['value'];
  timestamp = _parseDateTime(map['timestamp']);
  receivedAt = _parseDateTime(map['receivedAt']);
  deviceId = map['deviceId'] is ObjectId ? map['deviceId'] : (map['deviceId'] != null ? ObjectId.fromHexString(map['deviceId']) : null);
  mqttTopic = map['mqttTopic'];
  unit = map['unit'];
}


  static DateTime? _parseDateTime(dynamic value) {
  
    if (value is DateTime) {
      return value;
    } else if (value is String) {
      String isoDateString = value.toString();
     DateTime dateTime = DateTime.parse(isoDateString);
     
      return dateTime;
    }
    return null;
  }

  // Método para converter uma instância de IoTData em um mapa
  Map<String, dynamic> toMap() {
    return {
      if (id != null) '_id': id,
      if (value != null) 'value': value,
      if (timestamp != null) 'timestamp': timestamp,
      if (receivedAt != null) 'receivedAt': receivedAt,
      if (deviceId != null) 'deviceId': deviceId,
      if (mqttTopic != null) 'mqttTopic': mqttTopic,
      if (unit != null) 'unit': unit,
    };
  }

  @override
  String toString() {
    return 'IoTData {'
        'id: $id, '
        'value: $value, '
        'timestamp: $timestamp, '
        'receivedAt: $receivedAt, '
        'deviceId: $deviceId, '
        'mqttTopic: $mqttTopic, '
        'unit: $unit'
        '}';
  }
}
