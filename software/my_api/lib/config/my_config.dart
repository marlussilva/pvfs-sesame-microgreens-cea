class MyConfig {
  static const String MONGO_USER = "root";
  static const String MONGO_PASSWORD = "example";
  //static const String IP = "192.168.1.80";
 static const String IP = "192.168.1.80";

  static const String URL_SERVER_FILE_IP = "http://$IP:8090";

  static const String URL_MONGO =
      "mongodb://$MONGO_USER:$MONGO_PASSWORD@$IP:27017/leav";

  //"mongodb://$MONGO_USER:$MONGO_PASSWORD@$IP:27017/leav";
  static const String URL_MY_API = "http://$IP:8080";
  static const String URL_MY_API_SOCKET = "ws://$IP:8080";
  static const String USER_MQTT = "guest";
  static const String PASSWORD_MQTT = "guest";

  //http://192.168.1.80:8080/iot_data/grafico-sem?startTimestamp=2024-02-28T12:10:00.000&endTimestamp=2024-02-28T16:10:00.000&mqttTopic=sc5/ppm_co2
  //http://192.168.1.80:8080/iot_data/grafico-sem?startTimestamp=2024-02-21T16:23:00.000&endTimestamp=2024-02-28T16:23:00.000&mqttTopic=sc5/ppm_co2
}
