//#define FEED_BACK_LIGHT_CONTROL

#include <soc/rtc_wdt.h>
#include <esp32/rom/rtc.h>

#include <ArduinoOTA.h>
#include <WiFi.h>
#include <time.h>
#include <PubSubClient.h>
#include <ArduinoJson.h>
#include <DHT.h>
#include <Wire.h>
#include <Adafruit_MCP4725.h>
#include <RTClib.h>
#include <FS.h>
#include <SD.h>
#include <SPI.h>
#include <MHZCO2.h>
//#include <pwmWrite.h>
#include <BH1750.h>
#include <EEPROM.h>
#include <PZEM004Tv30.h>

// NTP server to request epoch time
const char* ntpServer = "pool.ntp.org";

float temperature;
int dac1_in;
int dac2_in;
int dac3_in;
int dac4_in;
//int dac5_in;
//int dac6_in;
//int dac7_in;
//int dac8_in;
int dim1_out;
int dim2_out;
int dim3_out;
int dim4_out;
//int dim5_out;
//int dim6_out;
//int dim7_out;
//int dim8_out;
float humidity;
int dim_mode;
//dimming

// Configurações WiFi
const char* ssid = "STARLINK_2";
const char* password = "1fg01@n02024st@rl1nk";
//const char* ssid = "LEAVBETA";
//const char* password = "12345678";
//const char* ssid = "Injerauto";
//const char* password = "injerauto040316";
//const char* ssid = "Martinho";
//const char* password = "m@rl1m@rt1nh0";

// Configurações MQTT
const char* mqtt_server = "192.168.1.80";
const char* mqtt_user = "guest";
const char* mqtt_pass = "guest";

//###//
const char* mqtt_dim_mode = "sc5/dim_mode";
const char* mqtt_command_dim_mode = "sc5/dim_mode/cmd"; // Tópico para receber comandos
//###//
const char* mqtt_dim1 = "sc5/dim1";
const char* mqtt_command_dim1 = "sc5/dim1/cmd"; // Tópico para receber comandos
const char* mqtt_dim2 = "sc5/dim2";
const char* mqtt_command_dim2 = "sc5/dim2/cmd"; // Tópico para receber comandos
const char* mqtt_dim3 = "sc5/dim3";
const char* mqtt_command_dim3 = "sc5/dim3/cmd"; // Tópico para receber comandos
const char* mqtt_dim4 = "sc5/dim4";
const char* mqtt_command_dim4 = "sc5/dim4/cmd"; // Tópico para receber comandos
//const char* mqtt_dim5 = "sc5/dim5";
//const char* mqtt_command_dim5 = "sc5/dim5/cmd"; // Tópico para receber comandos
//const char* mqtt_dim6 = "sc5/dim6";
//const char* mqtt_command_dim6 = "sc5/dim6/cmd"; // Tópico para receber comandos
//const char* mqtt_dim7 = "sc5/dim7";
//const char* mqtt_command_dim7 = "sc5/dim7/cmd"; // Tópico para receber comandos
//const char* mqtt_dim8 = "sc5/dim8";
//const char* mqtt_command_dim8 = "sc5/dim8/cmd"; // Tópico para receber comandos
//###//
const char* mqtt_temperature = "sc5/temperature";
const char* mqtt_command_temperature = "sc5/temperature/cmd"; // Tópico para receber comandos
const char* mqtt_humidity = "sc5/humidity";
const char* mqtt_command_humidity = "sc5/humidity/cmd"; // Tópico para receber comandos
const char* mqtt_ppm_co2 = "sc5/ppm_co2";
const char* mqtt_command_ppm_co2 = "sc5/ppm_co2/cmd"; // Tópico para receber comandos
//###//
//const char* mqtt_power = "sc5/power";
//const char* mqtt_command_power = "sc5/power/cmd";
//const char* mqtt_energy = "sc5/energy";
//const char* mqtt_command_energy = "sc5/energy/cmd";

const char* mqtt_power = "sc5/watts";
const char* mqtt_command_power = "sc5/watts/cmd";
const char* mqtt_energy = "sc5/kwh";
const char* mqtt_command_energy = "sc5/kwh/cmd";

const char* mqtt_reset_energy = "sc5/reset_energy";
const char* mqtt_command_reset_energy = "sc5/reset_energy/cmd";

const char* mqtt_voltage = "sc5/voltage";
const char* mqtt_command_voltage = "sc5/voltage/cmd";
const char* mqtt_current = "sc5/current";
const char* mqtt_command_current = "sc5/current/cmd";
const char* mqtt_frequency = "sc5/frequency";
const char* mqtt_command_frequency = "sc5/frequency/cmd";
const char* mqtt_power_factor = "sc5/power_factor";
const char* mqtt_command_power_factor = "sc5/power_factor/cmd";
const char* mqtt_cost = "sc5/cost";
const char* mqtt_command_cost = "sc5/cost/cmd";
const char* mqtt_cost_kwh = "sc5/cost_kwh";
const char* mqtt_command_cost_kwh = "sc5/cost_kwh/cmd";
const char* mqtt_cost_others = "sc5/cost_others";
const char* mqtt_command_cost_others = "sc5/cost_others/cmd";

const char* mqtt_ppfd_total_ch1 = "sc5/ppfd_total_ch1";
const char* mqtt_command_ppfd_total_ch1 = "sc5/ppfd_total_ch1/cmd";
const char* mqtt_ppfd_total_ch2 = "sc5/ppfd_total_ch2";
const char* mqtt_command_ppfd_total_ch2 = "sc5/ppfd_total_ch2/cmd";
const char* mqtt_ppfd_total_ch3 = "sc5/ppfd_total_ch3";
const char* mqtt_command_ppfd_total_ch3 = "sc5/ppfd_total_ch3/cmd";
const char* mqtt_ppfd_total_ch4 = "sc5/ppfd_total_ch4";
const char* mqtt_command_ppfd_total_ch4 = "sc5/ppfd_total_ch4/cmd";
//###//
const char* mqtt_rssi = "sc5/rssi";
const char* mqtt_command_rssi = "sc5/rssi/cmd"; // Tópico para receber comandos
//###//
const char* mqtt_dimming = "sc5/dimming";
const char* mqtt_command_dimming = "sc5/dimming/cmd"; // Tópico para receber comandos
//###//
//const char* mqtt_ = "sc5/";
//const char* mqtt_command_ = "sc5//cmd";

unsigned long lastReconnectAttempt = 0;
unsigned long intervaloEnvio = 500; // Intervalo padrão de 5 segundos para envio de mensagens
unsigned long ultimoEnvio = 0; // Controla a última vez que uma mensagem foi enviada

bool enviarInformacoes = true; // Controla se as informações devem ser enviadas

WiFiClient espClient;
PubSubClient client(espClient);

#define DHT_PIN 25
#define DHT_TYPE DHT22
#define DHT_TEMPERATURE_OFFSET 0.0
#define DHT_HUMIDITY_OFFSET +0.0
#define DHT_TEMPERATURE_GAIN +1.0
#define DHT_HUMIDITY_GAIN +1.0

#define HSPI_MISO   13
#define HSPI_MOSI   14
#define HSPI_SCLK   27
#define HSPI_SS     26

#define _SDA1 22
#define _SCL1 23
#define _SDA2 32
#define _SCL2 33

#define RELAY_PIN_1 15

//#define PWM_PIN_1 5
//#define PWM_PIN_2 18
//#define PWM_PIN_3 19
//#define PWM_PIN_4 21

//#define WTD_PIN 19
#define RTC_WDT_TIME 30000

//DAC 0,00 - 5,00 V
#define DIMMING_MIN_DAC 5   // 0,25 V - 0,05 A
#define DIMMING_MAX_DAC 95  // 4,75 V - 0,50 A
//PWM
//#define DIMMING_MAX_PWM 90
//#define DIMMING_MIN_PWM 10

DHT dht( DHT_PIN, DHT_TYPE );

TwoWire _Wire1 = TwoWire( 0 );
TwoWire _Wire2 = TwoWire( 1 );

Adafruit_MCP4725 dac1_out, dac2_out, dac3_out, dac4_out;

RTC_DS3231 rtc;
DateTime now;
//Pwm pwm = Pwm();

MHZ19B MHZ19B;
float MHZ19B_PPM_GAIN = 1.0;
float MHZ19B_PPM_OFFSET = 0.0;
float ppm_co2;

long millisPrev;
long loopPeriod = 1 * 1000;
 
//uint8_t cloudDisconnectedCounter = 0;

//int32_t DefaultPWMduty = 0;
//float DefaultPWMfrequency = 1000;
//uint8_t DefaultPWMresolution = 12;
//uint32_t DefaultPWMphase = 0;

uint16_t prevHour = 0;
bool clockInSync = 0;  /////////////////////////////////////////////////////////////////////////////////
char daysOfTheWeek[7][12] = {"Domingo", "Segunda", "Terça", "Quarta", "Quinta", "Sexta", "Sábado"};

#define DIMMING_POINTS_MAX 50
typedef struct dimming_t {

  uint8_t dimmingPoints;
  uint8_t hours[ DIMMING_POINTS_MAX ];
  uint8_t minutes[ DIMMING_POINTS_MAX ];
  uint8_t seconds[ DIMMING_POINTS_MAX ];
  long secondsSinceStart[ DIMMING_POINTS_MAX ];
  int value[ DIMMING_POINTS_MAX ];

} dimming_t;

dimming_t dimCH1;
dimming_t dimCH2;
dimming_t dimCH3;
dimming_t dimCH4;
//dimming_t dimCH5;
//dimming_t dimCH6;
//dimming_t dimCH7;
//dimming_t dimCH8;

int dim;
int dim1, dim2, dim3, dim4;// dim5, dim6, dim7, dim8;

int client_counter = 1;

bool photoPeriodFlag = 0;
float ppfd_total_target_ch1;
float ppfd_total_target_ch2;
float ppfd_total_target_ch3;
float ppfd_total_target_ch4;
//float ppfd_total_target_ch5;
//float ppfd_total_target_ch6;
//float ppfd_total_target_ch7;
//float ppfd_total_target_ch8;
float ppfd_lamp_target_ch1;
float ppfd_lamp_target_ch2;
float ppfd_lamp_target_ch3;
float ppfd_lamp_target_ch4;
//float ppfd_lamp_target_ch5;
//float ppfd_lamp_target_ch6;
//float ppfd_lamp_target_ch7;
//float ppfd_lamp_target_ch8;
float ppfd_lamp_ch1;
float ppfd_lamp_ch2;
float ppfd_lamp_ch3;
float ppfd_lamp_ch4;
//float ppfd_lamp_ch5;
//float ppfd_lamp_ch6;
//float ppfd_lamp_ch7;
//float ppfd_lamp_ch8;
float ppfd_total_ch1;
float ppfd_total_ch2;
float ppfd_total_ch3;
float ppfd_total_ch4;
//float ppfd_total_ch5;
//float ppfd_total_ch6;
//float ppfd_total_ch7;
//float ppfd_total_ch8;
float dli_ch1;
float dli_ch2;
float dli_ch3;
float dli_ch4;
//float dli_ch5;
//float dli_ch6;
//float dli_ch7;
//float dli_ch8;
float dli_sun;
float ppfd_sun = 0.0;
int dt;
float illuminance;

///// SEM LENTES ////
// Azul
float PPFD_MIN_CH1 = 103.6;
float PPFD_MAX_CH1 = 608.7;
// Branco
float PPFD_MIN_CH2 = 101.6;
float PPFD_MAX_CH2 = 564.4;
// RBW
float PPFD_MIN_CH3 = 92.7;
float PPFD_MAX_CH3 = 637.2;
// Vermelho
float PPFD_MIN_CH4 = 106.5;
float PPFD_MAX_CH4 = 712.2;

/*
///// COM LENTES ////
// Azul
float PPFD_MIN_CH1 = 125.0;
float PPFD_MAX_CH1 = 699.0;
// Branco
float PPFD_MIN_CH2 = 111.0;
float PPFD_MAX_CH2 = 643.0;
// RBW
float PPFD_MIN_CH3 = 97.0;
float PPFD_MAX_CH3 = 774.0;
// Vermelho
float PPFD_MIN_CH4 = 117.0;
float PPFD_MAX_CH4 = 803.0;
*/

///// EXEMPLO ////
// Reservado
//float PPFD_MIN_CH5 = 100.0;
//float PPFD_MAX_CH5 = 750.0;
// Reservado
//float PPFD_MIN_CH6 = 100.0;
//float PPFD_MAX_CH6 = 750.0;
// Reservado
//float PPFD_MIN_CH7 = 100.0;
//float PPFD_MAX_CH7 = 750.0;
// Reservado
//float PPFD_MIN_CH8 = 100.0;
//float PPFD_MAX_CH8 = 750.0;

BH1750 lightMeterBH1750;

float BH1750_ILLUMINANCE_GAIN = 1.0;
float LAMP_TRANSMITTANCE = 1.0;
float LUX_TO_PPFD = 0.01755;

int rssi;

float cost;
float cost_kwh;
float cost_others;
float current;
float energy;
float frequency;
float power;
float power_factor;
float voltage;
bool reset_energy;

#define PZEM_RX_PIN 18
#define PZEM_TX_PIN 19
#define PZEM_SERIAL Serial1
PZEM004Tv30 pzem(PZEM_SERIAL, PZEM_RX_PIN, PZEM_TX_PIN);

#define EEPROM_SIZE 5
#define DIM_MODE_ADDRESS 0
#define DAC1_IN_ADDRESS 1
#define DAC2_IN_ADDRESS 2
#define DAC3_IN_ADDRESS 3
#define DAC4_IN_ADDRESS 4

void setup() {

  configRTCwatchdog();

  pinMode( RELAY_PIN_1, OUTPUT ); digitalWrite( RELAY_PIN_1, LOW );
  pinMode( LED_BUILTIN, OUTPUT );

  // Initialize serial and wait for port to open:
  Serial.begin( 115200 );

  // This delay gives the chance to wait for a Serial Monitor without blocking if none is found
  delay( 1500 );
  
  Serial.println("\n\nStart...");
  digitalWrite( LED_BUILTIN, HIGH ); delay(300);
  digitalWrite( LED_BUILTIN, LOW );  delay(300);
  digitalWrite( LED_BUILTIN, HIGH ); delay(300);
  digitalWrite( LED_BUILTIN, LOW );  delay(300);
  digitalWrite( LED_BUILTIN, HIGH ); delay(50);
  digitalWrite( LED_BUILTIN, LOW );

  EEPROM.begin( EEPROM_SIZE );

  loadEEPROMconfig();

  _Wire1.begin( _SDA1, _SCL1, 400000ul );
  _Wire2.begin( _SDA2, _SCL2, 400000ul );

  dht.begin();

  dac1_out.begin( 0x61, &_Wire1 );
  dac2_out.begin( 0x60, &_Wire1 );
  dac3_out.begin( 0x61, &_Wire2 );
  dac4_out.begin( 0x60, &_Wire2 );
  
  #ifdef FEED_BACK_LIGHT_CONTROL
    lightMeterBH1750.begin( BH1750::CONTINUOUS_HIGH_RES_MODE, 0x23, &_Wire1 );   // Measurement at 1 lux resolution. Measurement time is approx 120ms.
    lightMeterBH1750.setMTreg( 31 );
  #endif
  
  MHZ19B.begin( &Serial2 );
  Serial2.begin( 9600 );

  if ( !rtc.begin( &_Wire1 ) ) {
    Serial.println("Couldn't find RTC");
    Serial.flush();
    Serial.println(F("Reiniciando ESP32..."));
    ESP.restart();
  }

  SPIClass *spi = NULL;
  spi = new SPIClass( HSPI );
  spi->begin( HSPI_SCLK, HSPI_MISO, HSPI_MOSI, HSPI_SS );

  if ( !SD.begin( HSPI_SS, *spi ) ) {
    Serial.println("Card Mount Failed");
    Serial.println(F("Reiniciando ESP32..."));
    ESP.restart();
  }

  uint8_t cardType = SD.cardType();
  if ( cardType == CARD_NONE ) {
    Serial.println("No SD card attached");
    Serial.println(F("Reiniciando ESP32..."));
    ESP.restart();
  }

  Serial.print("SD Card Type: ");
  if (cardType == CARD_MMC) Serial.println("MMC");
  else if (cardType == CARD_SD) Serial.println("SDSC");
  else if (cardType == CARD_SDHC) Serial.println("SDHC");
  else Serial.println("UNKNOWN");

  uint64_t cardSize = SD.cardSize() / (1024 * 1024);
  Serial.printf("SD Card Size: %lluMB\n", cardSize);
  Serial.printf("Total space: %lluMB\n", SD.totalBytes() / (1024 * 1024));
  Serial.printf("Used space: %lluMB\n", SD.usedBytes() / (1024 * 1024));

  getDimmingTable();

  bootLog();

  /*
     The following function allows you to obtain more information
     related to the state of network and IoT Cloud connection and errors
     the higher number the more granular information you’ll get.
     The default is 0 (only errors).
     Maximum is 4
  */
  //setDebugMessageLevel( 4 );
  //ArduinoCloud.printDebugInfo();

  // Conectando-se à rede WiFi
  WiFi.begin(ssid, password);
  while (WiFi.status() != WL_CONNECTED) {
    delay(500);
    Serial.print(".");
  }
  Serial.println("");
  Serial.println("WiFi conectado");
  Serial.println("Endereço IP: ");
  Serial.println(WiFi.localIP());

  ArduinoOTA.begin();

  configTime(0, 0, ntpServer);

  client.setBufferSize( 512 );
  client.setServer(mqtt_server, 1883);
  client.setCallback(callback);

  _connect(); // Conecta ao servidor MQTT pela primeira vez

  millisPrev = millis();

}
void callback(char* topic, byte* message, unsigned int length) { // do front pro back
  
  Serial.print("Mensagem recebida ["); Serial.print(topic); Serial.println("]");

  char msg[length + 1];
  memcpy(msg, message, length);
  msg[length] = '\0'; // Adiciona o terminador de string
  Serial.println(msg); // Exibe a mensagem

  StaticJsonDocument<500> doc;
  DeserializationError error = deserializeJson(doc, msg);

  if (error) {
    Serial.print("deserializeJson() falhou: ");
    Serial.println(error.c_str());
    return;
  }

  const char* comando = doc["comando"];

  // Processa o comando recebido
         if (strcmp(comando, "dim1") == 0) {
    const char* value = doc["value"];
    //Serial.print("value: "); Serial.println(value);
    dac1_in = atoi(value);
    if( (int)EEPROM.read( DAC1_IN_ADDRESS ) != dac1_in ){
      EEPROM.write( DAC1_IN_ADDRESS , dac1_in );
      EEPROM.commit();
    }
  } else if (strcmp(comando, "dim2") == 0) {
    const char* value = doc["value"];
    //Serial.print("value: "); Serial.println(value);
    dac2_in = atoi(value);
    if( (int)EEPROM.read( DAC2_IN_ADDRESS ) != dac2_in ){
      EEPROM.write( DAC2_IN_ADDRESS , dac2_in );
      EEPROM.commit();
    }
  } else if (strcmp(comando, "dim3") == 0) {
    const char* value = doc["value"];
    //Serial.print("value: "); Serial.println(value);
    dac3_in = atoi(value);
    if( (int)EEPROM.read( DAC3_IN_ADDRESS ) != dac3_in ){
      EEPROM.write( DAC3_IN_ADDRESS , dac3_in );
      EEPROM.commit();
    }
  } else if (strcmp(comando, "dim4") == 0) {
    const char* value = doc["value"];
    //Serial.print("value: "); Serial.println(value);
    dac4_in = atoi(value);
    if( (int)EEPROM.read( DAC4_IN_ADDRESS ) != dac4_in ){
      EEPROM.write( DAC4_IN_ADDRESS , dac4_in );
      EEPROM.commit();
    }
  /*
  } else if (strcmp(comando, "dim5") == 0) {
    const char* value = doc["value"];
    //Serial.print("value: "); Serial.println(value);
    dac5_in = atoi(value);
  } else if (strcmp(comando, "dim6") == 0) {
    const char* value = doc["value"];
    //Serial.print("value: "); Serial.println(value);
    dac6_in = atoi(value);
  } else if (strcmp(comando, "dim7") == 0) {
    const char* value = doc["value"];
    //Serial.print("value: "); Serial.println(value);
    dac7_in = atoi(value);
  } else if (strcmp(comando, "dim8") == 0) {
    const char* value = doc["value"];
    //Serial.print("value: "); Serial.println(value);
    dac8_in = atoi(value);
    */
  } else if (strcmp(comando, "dim_mode") == 0) {
    const char* value = doc["value"];
    //Serial.print("value: "); Serial.println(value);
    dim_mode = atoi(value);
    if( (int)EEPROM.read( DIM_MODE_ADDRESS ) != dim_mode ){
      EEPROM.write( DIM_MODE_ADDRESS , dim_mode );
      EEPROM.commit();
    }
  } else if (strcmp(comando, "dimming") == 0) {
    const char* value = doc["value"];

    Serial.print("#value: "); Serial.println(value);

    setDimmingTable( value, &dimCH1, "/ch1.txt" );
    setDimmingTable( value, &dimCH2, "/ch2.txt" );
    setDimmingTable( value, &dimCH3, "/ch3.txt" );
    setDimmingTable( value, &dimCH4, "/ch4.txt" );
    //setDimmingTable( value, &dimCH5, "/ch5.txt" );
    //setDimmingTable( value, &dimCH6, "/ch6.txt" );
    //setDimmingTable( value, &dimCH7, "/ch7.txt" );
    //setDimmingTable( value, &dimCH8, "/ch8.txt" );

  } else if (strcmp(comando, "reset_energy") == 0) {
    const char* value = doc["value"];
    //Serial.print("value: "); Serial.println(value);
    reset_energy = atoi(value);
  } else Serial.println("\n\n!!! Default !!!\n\n");

}
bool tryReconnect() {
  // Loop até estar conectado
  
  WiFi.disconnect();
  WiFi.begin(ssid, password);
  while (WiFi.status() != WL_CONNECTED) {
    delay(500);
    Serial.print(".");
  }
  Serial.println("");
  Serial.println("WiFi conectado");
  Serial.println("Endereço IP: ");
  Serial.println(WiFi.localIP());
  
  String client_id = "ESP32Client";
  client_id += client_counter;
  Serial.print("client_id: "); Serial.println(client_id);

  if ( client.connect( client_id.c_str(), mqtt_user, mqtt_pass) ) {
    // Assina o tópico de comandos
      client.subscribe(mqtt_command_dim_mode        );
      client.subscribe(mqtt_command_dim1            );
      client.subscribe(mqtt_command_dim2            );
      client.subscribe(mqtt_command_dim3            );
      client.subscribe(mqtt_command_dim4            );
      //client.subscribe(mqtt_command_dim5          );
      //client.subscribe(mqtt_command_dim6          );
      //client.subscribe(mqtt_command_dim7          );
      //client.subscribe(mqtt_command_dim8          );
      client.subscribe(mqtt_command_ppfd_total_ch1  );
      client.subscribe(mqtt_command_ppfd_total_ch2  );
      client.subscribe(mqtt_command_ppfd_total_ch3  );
      client.subscribe(mqtt_command_ppfd_total_ch4  );
      client.subscribe(mqtt_command_temperature     );
      client.subscribe(mqtt_command_humidity        );
      client.subscribe(mqtt_command_ppm_co2         );
      client.subscribe(mqtt_command_rssi            );
      client.subscribe(mqtt_command_power           );
      client.subscribe(mqtt_command_power_factor    );
      client.subscribe(mqtt_command_energy          );
      client.subscribe(mqtt_command_reset_energy    );

      client.subscribe(mqtt_command_dimming     );

  }
  
  //client_counter++;

  return client.connected();

}
void _connect() {
  // Loop até estar conectado
  
  String client_id = "ESP32Client";
  client_id += client_counter;
  Serial.print("client_id: "); Serial.println(client_id);

  while ( !client.connected() ) {

    Serial.println("Conectando ao MQTT...");
    
    if ( client.connect( client_id.c_str() , mqtt_user , mqtt_pass ) ) {

      Serial.println("Conectado ao MQTT!");

      // Se conectado, assina o tópico de comandos e envia uma mensagem de confirmação
      client.subscribe(mqtt_command_dim_mode        );
      client.subscribe(mqtt_command_dim1            );
      client.subscribe(mqtt_command_dim2            );
      client.subscribe(mqtt_command_dim3            );
      client.subscribe(mqtt_command_dim4            );
      //client.subscribe(mqtt_command_dim5          );
      //client.subscribe(mqtt_command_dim6          );
      //client.subscribe(mqtt_command_dim7          );
      //client.subscribe(mqtt_command_dim8          );
      client.subscribe(mqtt_command_ppfd_total_ch1  );
      client.subscribe(mqtt_command_ppfd_total_ch2  );
      client.subscribe(mqtt_command_ppfd_total_ch3  );
      client.subscribe(mqtt_command_ppfd_total_ch4  );
      client.subscribe(mqtt_command_temperature     );
      client.subscribe(mqtt_command_humidity        );
      client.subscribe(mqtt_command_ppm_co2         );
      client.subscribe(mqtt_command_rssi            );
      client.subscribe(mqtt_command_power           );
      client.subscribe(mqtt_command_power_factor    );
      client.subscribe(mqtt_command_energy          );
      client.subscribe(mqtt_command_reset_energy    );

      client.subscribe(mqtt_command_dimming     );

    } else {
      Serial.print("falhou, rc=");
      Serial.print(client.state());
      Serial.println(" tentando novamente em 5 segundos");
      // Aguarda 5 segundos antes de tentar novamente
      delay( 5000 );
    }

  }
  
  //client_counter++;

}
void MarlusCloudUpdate() {

  if ( !client.connected() ) {

    Serial.println("Cliente desconectado!");

    unsigned long now = millis();
    if (now - lastReconnectAttempt > 5000) {

      Serial.println("Tentando reconectar...");

      lastReconnectAttempt = now;
      // Tentativa de reconexão
      if ( tryReconnect() ) {
        lastReconnectAttempt = 0;
      }
    }
  } else {
    // Se conectado, então processa as chegadas de mensagens
    client.loop();
  }

  // Se o envio de informações estiver parado, pisca o LED continuamente
  if ( !enviarInformacoes ) {
    digitalWrite( LED_BUILTIN, HIGH );
    delay( 100 ); // Este valor determina a velocidade do piscar
    digitalWrite( LED_BUILTIN, LOW) ;
    delay( 100 );
  } else if ( millis() - ultimoEnvio > intervaloEnvio ) {
    ultimoEnvio = millis(); // Atualiza o tempo do último envio

    // Cria o payload JSON
    String payload_dim_mode = "{"
                              "\"value\": " + String(dim_mode) + ","
                              "\"mqttTopic\": \"sc5/dim_mode\","
                              "\"unit\" : \" \""
                              "}";

    String payload_dim1 = "{"
                          "\"value\": " + String(dim1_out) + ","
                          "\"mqttTopic\": \"sc5/dim1\","
                          "\"unit\" : \"%\""
                          "}";

    String payload_dim2 = "{"
                          "\"value\": " + String(dim2_out) + ","
                          "\"mqttTopic\": \"sc5/dim2\","
                          "\"unit\" : \"%\""
                          "}";

    String payload_dim3 = "{"
                          "\"value\": " + String(dim3_out) + ","
                          "\"mqttTopic\": \"sc5/dim3\","
                          "\"unit\" : \"%\""
                          "}";

    String payload_dim4 = "{"
                          "\"value\": " + String(dim4_out) + ","
                          "\"mqttTopic\": \"sc5/dim4\","
                          "\"unit\" : \"%\""
                          "}";

    String payload_ppfd_total_ch1 = "{"
                          "\"value\": " + String(ppfd_total_ch1) + ","
                          "\"mqttTopic\": \"sc5/ppfd_total_ch1\","
                          "\"unit\" : \"PPFD\""
                          "}";
    
    String payload_ppfd_total_ch2 = "{"
                          "\"value\": " + String(ppfd_total_ch2) + ","
                          "\"mqttTopic\": \"sc5/ppfd_total_ch2\","
                          "\"unit\" : \"PPFD\""
                          "}";
    
    String payload_ppfd_total_ch3 = "{"
                          "\"value\": " + String(ppfd_total_ch3) + ","
                          "\"mqttTopic\": \"sc5/ppfd_total_ch3\","
                          "\"unit\" : \"PPFD\""
                          "}";
    
    String payload_ppfd_total_ch4 = "{"
                          "\"value\": " + String(ppfd_total_ch4) + ","
                          "\"mqttTopic\": \"sc5/ppfd_total_ch4\","
                          "\"unit\" : \"PPFD\""
                          "}";

/*
    String payload_dim5 = "{"
                          "\"value\": " + String(dim5_out) + ","
                          "\"mqttTopic\": \"sc5/dim5\","
                          "\"unit\" : \"%\""
                          "}";

    String payload_dim6 = "{"
                          "\"value\": " + String(dim6_out) + ","
                          "\"mqttTopic\": \"sc5/dim6\","
                          "\"unit\" : \"%\""
                          "}";

    String payload_dim7 = "{"
                          "\"value\": " + String(dim7_out) + ","
                          "\"mqttTopic\": \"sc5/dim7\","
                          "\"unit\" : \"%\""
                          "}";

    String payload_dim8 = "{"
                          "\"value\": " + String(dim8_out) + ","
                          "\"mqttTopic\": \"sc5/dim8\","
                          "\"unit\" : \"%\""
                          "}";
*/
    String payload_temperature = "{"
                                 "\"value\": " + String(temperature) + ","
                                 "\"mqttTopic\": \"sc5/temperature\","
                                 "\"unit\" : \"C\""
                                 "}";

    String payload_humidity = "{"
                              "\"value\": " + String(humidity) + ","
                              "\"mqttTopic\": \"sc5/humidity\","
                              "\"unit\" : \"%\""
                              "}";
                              
    String payload_ppm_co2 = "{"
                              "\"value\": " + String(ppm_co2) + ","
                              "\"mqttTopic\": \"sc5/ppm_co2\","
                              "\"unit\" : \"PPM\""
                              "}";
    
    String payload_rssi = "{"
                              "\"value\": " + String(rssi) + ","
                              "\"mqttTopic\": \"sc5/rssi\","
                              "\"unit\" : \"dbm\""
                              "}";

    String payload_power = "{"
                              "\"value\": " + String(power) + ","
                              "\"mqttTopic\": \"sc5/watts\","
                              "\"unit\" : \"w\""
                              "}";

    String payload_power_factor = "{"
                              "\"value\": " + String(power_factor) + ","
                              "\"mqttTopic\": \"sc5/power_factor\","
                              "\"unit\" : \".\""
                              "}";

    String payload_energy = "{"
                              "\"value\": " + String(energy) + ","
                              "\"mqttTopic\": \"sc5/kwh\","
                              "\"unit\" : \"kwh\""
                              "}";

    String payload_reset_energy = "{"
                              "\"value\": " + String(reset_energy) + ","
                              "\"mqttTopic\": \"sc5/reset_energy\","
                              "\"unit\" : \".\""
                              "}";

    String payload_dimming =  "{"
                              "\"value\": " + String(0) + ","
                              "\"mqttTopic\": \"sc5/dimming\","
                              "\"unit\" : \"%\""
                              "}";

    /*Serial.print("payload_dim1: ");     Serial.println(payload_dim1);
      Serial.print("payload_dim2: ");     Serial.println(payload_dim2);
      Serial.print("payload_dim3: ");     Serial.println(payload_dim3);
      Serial.print("payload_dim4: ");     Serial.println(payload_dim4);
      Serial.print("payload_dim5: ");     Serial.println(payload_dim5);
      Serial.print("payload_dim6: ");     Serial.println(payload_dim6);
      Serial.print("payload_dim7: ");     Serial.println(payload_dim7);
      Serial.print("payload_dim8: ");     Serial.println(payload_dim8);
      Serial.print("payload_dimming: ");  Serial.println(payload_dimming);*/

    // Envia o payload
    client.publish( mqtt_dim_mode,        payload_dim_mode.c_str(),       true );
    client.publish( mqtt_dim1,            payload_dim1.c_str(),           true );
    client.publish( mqtt_dim2,            payload_dim2.c_str(),           true );
    client.publish( mqtt_dim3,            payload_dim3.c_str(),           true );
    client.publish( mqtt_dim4,            payload_dim4.c_str(),           true );
    //client.publish( mqtt_dim5,            payload_dim5.c_str(),           true );
    //client.publish( mqtt_dim6,            payload_dim6.c_str(),           true );
    //client.publish( mqtt_dim7,            payload_dim7.c_str(),           true );
    //client.publish( mqtt_dim8,            payload_dim8.c_str(),           true );
    client.publish( mqtt_ppfd_total_ch1,  payload_ppfd_total_ch1.c_str(), true );
    client.publish( mqtt_ppfd_total_ch2,  payload_ppfd_total_ch2.c_str(), true );
    client.publish( mqtt_ppfd_total_ch3,  payload_ppfd_total_ch3.c_str(), true );
    client.publish( mqtt_ppfd_total_ch4,  payload_ppfd_total_ch4.c_str(), true );
    client.publish( mqtt_temperature,     payload_temperature.c_str(),    true );
    client.publish( mqtt_humidity,        payload_humidity.c_str(),       true );
    client.publish( mqtt_ppm_co2,         payload_ppm_co2.c_str(),        true );
    client.publish( mqtt_rssi,            payload_rssi.c_str(),           true );
    client.publish( mqtt_power,           payload_power.c_str(),          true );
    client.publish( mqtt_power_factor,    payload_power_factor.c_str(),   true );
    client.publish( mqtt_energy,          payload_energy.c_str(),         true );
    client.publish( mqtt_reset_energy,    payload_reset_energy.c_str(),   true );
    client.publish( mqtt_dimming,         payload_dimming.c_str(),        true );

  }

}
void loop() {

  if ( millis() > ( millisPrev + loopPeriod ) ) {

    dt = (int)( millis() - millisPrev );
    millisPrev = millis();

    ArduinoOTA.handle();
    
    Serial.println(F("#############################################"));

    //Serial.print("dt: ");Serial.println(dt);

    //Serial.println("MarlusCloudUpdate()...");
    MarlusCloudUpdate();

    //Serial.println("refreshNow()...");
    refreshNow();

    //Serial.println("dht22Read()...");
    dht22Read();

    //Serial.println("bh1750Read()...");
    bh1750Read();

    //Serial.println("mhz19bRead()...");
    mhz19bRead();

    //Serial.println("pzem004tv3()...");
    pzem004tv3();

    //Serial.println("checkEnergyReset()...");
    checkEnergyReset();

    //Serial.println("illuminationHandler()...");
    illuminationHandler();

    //Serial.println("showTime()...");
    showTime();

    //Serial.println("checkMidnightReset()...");
    checkMidnightReset();

    //Serial.println("clockSync()...");
    clockSync();

    //Serial.println("getRSSI()...");
    getRSSI();

    //Serial.println("watchDogFeed()...");
    watchDogFeed();

    //Serial.println("handleSerialInput()...");
    handleSerialInput();

  }

}
void getRSSI() {

  rssi = WiFi.RSSI();
  Serial.print("RSSI: "); Serial.println(rssi);
  
}
void loadEEPROMconfig() {

  Serial.println("loadEEPROMconfig()...");

  dim_mode = (int)EEPROM.read( DIM_MODE_ADDRESS );
  dac1_in  = (int)EEPROM.read( DAC1_IN_ADDRESS );
  dac2_in  = (int)EEPROM.read( DAC2_IN_ADDRESS );
  dac3_in  = (int)EEPROM.read( DAC3_IN_ADDRESS );
  dac4_in  = (int)EEPROM.read( DAC4_IN_ADDRESS );

  if( dim_mode > 2 || dim_mode < 0 ){

    dim_mode = 0;

    if( (int)EEPROM.read( DIM_MODE_ADDRESS ) != dim_mode ){
      EEPROM.write( DIM_MODE_ADDRESS , dim_mode );
      EEPROM.commit();
    }
    
  }
  if( dac1_in < 0 || dac1_in > 100 ){

    dac1_in = 0;

    if( (int)EEPROM.read( DAC1_IN_ADDRESS ) != dac1_in ){
      EEPROM.write( DAC1_IN_ADDRESS , dac1_in );
      EEPROM.commit();
    }

  }
  if( dac2_in < 0 || dac2_in > 100 ){

    dac2_in = 0;

    if( (int)EEPROM.read( DAC2_IN_ADDRESS ) != dac2_in ){
      EEPROM.write( DAC2_IN_ADDRESS , dac2_in );
      EEPROM.commit();
    }

  }
  if( dac3_in < 0 || dac3_in > 100 ){

    dac3_in = 0;

    if( (int)EEPROM.read( DAC3_IN_ADDRESS ) != dac3_in ){
      EEPROM.write( DAC3_IN_ADDRESS , dac3_in );
      EEPROM.commit();
    }

  }
  if( dac4_in < 0 || dac4_in > 100 ){

    dac4_in = 0;

    if( (int)EEPROM.read( DAC4_IN_ADDRESS ) != dac4_in ){
      EEPROM.write( DAC4_IN_ADDRESS , dac4_in );
      EEPROM.commit();
    }

  }
  
  Serial.print("dim_mode: "); Serial.println(dim_mode);
  Serial.print("dac1_in: "); Serial.println(dac1_in);
  Serial.print("dac2_in: "); Serial.println(dac2_in);
  Serial.print("dac3_in: "); Serial.println(dac3_in);
  Serial.print("dac4_in: "); Serial.println(dac4_in);
  
}
void setDimmingTable( const char* value, dimming_t *dimming, const char* path ) {

  uint8_t hour, minute, second;
  int dim;
  float hour_f, minute_f, second_f;
  int counter = 0;

  char str[500];
  strcpy( str, value );

  char *pch;
  pch = strtok( str, "[[,]] " );
  //printf("\n\nsetDimmingTable:\n");
  while ( true ) {

    if ( pch != NULL ) {

      //printf("pch 1: %s\n", pch);

      hour_f    = atof( pch );
      hour      = (uint8_t)floorf( hour_f );
      minute_f  = ( ( hour_f - (float)hour ) * 60.0 );
      minute    = (uint8_t)floorf( minute_f );
      second_f  = ( ( minute_f - (float)minute ) * 60.0 );
      second    = (uint8_t)roundf( second_f );

      dimming->hours[counter]   = hour;
      dimming->minutes[counter] = minute;
      dimming->seconds[counter] = second;

      if ( second >= 60 ) {
        dimming->minutes[counter] += 1;
        dimming->seconds[counter] = second - 60;
      }
      if ( minute >= 60 ) {
        dimming->hours[counter] += 1;
        dimming->minutes[counter] = minute - 60;
      }
      if ( hour >= 24 ) {
        dimming->hours[counter] = hour - 24;
      }

      //printf( "%d\t%d\t%d\t" , hour , minute , second );

    } else break;

    pch = strtok( NULL, "[[,]] " );

    if ( pch != NULL ) {

      //printf("pch 2: %s\n", pch);

      dim = atoi( pch );

      dimming->value[counter] = dim;

      //printf( "%d\n", dim);

    } else break;

    dimming->dimmingPoints = ( counter += 1 );

    pch = strtok( NULL, "[[,]] " );

  }

  //printf("dimmingPoints: %d\n", dimming->dimmingPoints);

  //writeFile( SD, "/ch1.txt", dimming ); getSecondsSinceStart( dimming );
  writeFile( SD, path, dimming ); getSecondsSinceStart( dimming );

}
void writeFile( fs::FS &fs, const char * path, dimming_t *dimming ) {

  File file = fs.open( path, FILE_WRITE );
  if ( !file ) {
    Serial.println("Failed to open file for writing");
    return;
  }

  printf("\n\nwriteFile:\n");
  for ( uint8_t counter = 0 ; counter < dimming->dimmingPoints ; counter ++ ) {

    printf("%d\t%d\t%d\t%d\n", dimming->hours[counter], dimming->minutes[counter], dimming->seconds[counter], dimming->value[counter] );
    file.printf("%d\t%d\t%d\t%d\n", dimming->hours[counter], dimming->minutes[counter], dimming->seconds[counter], dimming->value[counter] );

  }

  printf("dimmingPoints: %d\n", dimming->dimmingPoints);

  file.close();

}
unsigned long getTime() {
  time_t now;
  struct tm timeinfo;
  if (!getLocalTime(&timeinfo)) {
    Serial.println("Failed to obtain time!");
    return (0);
  }
  time(&now);
  return now;
}
void configRTCwatchdog() {
  rtc_wdt_protect_off();      //Disable RTC WDT write protection
  //Set stage 0 to trigger a system reset after 1000ms
  rtc_wdt_set_stage( RTC_WDT_STAGE0, RTC_WDT_STAGE_ACTION_RESET_RTC );
  rtc_wdt_set_time( RTC_WDT_STAGE0, RTC_WDT_TIME );
  rtc_wdt_enable();           //Start the RTC WDT timer
  rtc_wdt_protect_on();       //Enable RTC WDT write protection
}
void verbose_print_reset_reason( int reason, File fp ) {
  
  switch( reason ) {
    
    case 1  : Serial.print(F("Vbat power on reset"));                               fp.print(F("Vbat power on reset"));                              break;
    case 3  : Serial.print(F("Software reset digital core"));                       fp.print(F("Software reset digital core"));                      break;
    case 4  : Serial.print(F("Legacy watch dog reset digital core"));               fp.print(F("Legacy watch dog reset digital core"));              break;
    case 5  : Serial.print(F("Deep Sleep reset digital core"));                     fp.print(F("Deep Sleep reset digital core"));                    break;
    case 6  : Serial.print(F("Reset by SLC module, reset digital core"));           fp.print(F("Reset by SLC module, reset digital core"));          break;
    case 7  : Serial.print(F("Timer Group0 Watch dog reset digital core"));         fp.print(F("Timer Group0 Watch dog reset digital core"));        break;
    case 8  : Serial.print(F("Timer Group1 Watch dog reset digital core"));         fp.print(F("Timer Group1 Watch dog reset digital core"));        break;
    case 9  : Serial.print(F("RTC Watch dog Reset digital core"));                  fp.print(F("RTC Watch dog Reset digital core"));                 break;
    case 10 : Serial.print(F("Instrusion tested to reset CPU"));                    fp.print(F("Instrusion tested to reset CPU"));                   break;
    case 11 : Serial.print(F("Time Group reset CPU"));                              fp.print(F("Time Group reset CPU"));                             break;
    case 12 : Serial.print(F("Software reset CPU"));                                fp.print(F("Software reset CPU"));                               break;
    case 13 : Serial.print(F("RTC Watch dog Reset CPU"));                           fp.print(F("RTC Watch dog Reset CPU"));                          break;
    case 14 : Serial.print(F("for APP CPU, reseted by PRO CPU"));                   fp.print(F("for APP CPU, reseted by PRO CPU"));                  break;
    case 15 : Serial.print(F("Reset when the vdd voltage is not stable"));          fp.print(F("Reset when the vdd voltage is not stable"));         break;
    case 16 : Serial.print(F("RTC Watch dog reset digital core and rtc module"));   fp.print(F("RTC Watch dog reset digital core and rtc module"));  break;
    default : Serial.print(F("NO_MEAN"));                                           fp.print(F("NO_MEAN"));                                          break;
    
  }
  
}
void bootLog() {

  File boot_log_fp = SD.open( "/BOOT_LOG.txt", FILE_APPEND );

  refreshNow();

  if ( boot_log_fp ) {

    Serial.println();
    Serial.println("Registrando boot no arquivo de log...");

    boot_log_fp.print(now.day(), DEC);
    boot_log_fp.print('/');
    boot_log_fp.print(now.month(), DEC);
    boot_log_fp.print('/');
    boot_log_fp.print(now.year(), DEC);
    boot_log_fp.print(" (");
    boot_log_fp.print(daysOfTheWeek[now.dayOfTheWeek()]);
    boot_log_fp.print(") ");
    boot_log_fp.print(now.hour(), DEC);
    boot_log_fp.print(':');
    boot_log_fp.print(now.minute(), DEC);
    boot_log_fp.print(':');
    boot_log_fp.print(now.second(), DEC);
    boot_log_fp.print(" - ");
    boot_log_fp.print("Reset Reason Core 0: "); Serial.print("Reset Reason Core 0: ");
    verbose_print_reset_reason( rtc_get_reset_reason(0) , boot_log_fp ); Serial.println();
    boot_log_fp.print(" - Reset Reason Core 1: "); Serial.print("Reset Reason Core 1: ");
    verbose_print_reset_reason( rtc_get_reset_reason(1) , boot_log_fp ); Serial.println();
    boot_log_fp.println();
    
    Serial.println("Boot resgistrado com sucesso.");

  } else {

    // if the file didn't open, print an error:
    Serial.println("Erro ao abrir o arquivo BOOT_LOG.txt");

  }
  
  boot_log_fp.close();

}
void mhz14bLog( float ppm_co2_new , float ppm_co2_old ) {

  File boot_log_fp = SD.open( "/MH_Z14B_LOG.txt", FILE_APPEND );

  refreshNow();

  if ( boot_log_fp ) {

    Serial.println();
    Serial.println("Registrando MH-Z14B no arquivo de log...");

    boot_log_fp.print(now.day(), DEC);
    boot_log_fp.print('/');
    boot_log_fp.print(now.month(), DEC);
    boot_log_fp.print('/');
    boot_log_fp.print(now.year(), DEC);
    boot_log_fp.print(" (");
    boot_log_fp.print(daysOfTheWeek[now.dayOfTheWeek()]);
    boot_log_fp.print(") ");
    boot_log_fp.print(now.hour(), DEC);
    boot_log_fp.print(':');
    boot_log_fp.print(now.minute(), DEC);
    boot_log_fp.print(':');
    boot_log_fp.print(now.second(), DEC);
    boot_log_fp.print(" - ");
    boot_log_fp.print("ppm_co2 (OLD): "); boot_log_fp.print(ppm_co2_old);
    boot_log_fp.print(" ");
    boot_log_fp.print("ppm_co2 (NEW): "); boot_log_fp.print(ppm_co2_new);
    boot_log_fp.println();
    
    Serial.println("Boot resgistrado com sucesso.");

  } else {

    // if the file didn't open, print an error:
    Serial.println("Erro ao abrir o arquivo MH_Z14B_LOG.txt");

  }
  
  boot_log_fp.close();

}
void refreshNow() {

  now = rtc.now();

}
void clockSync() {
  
  if ( clockInSync == 0 ) {
  
    unsigned long epochTime = getTime();
  
    if ( epochTime > 0 ) {

      epochTime = epochTime - ( 3 * 60 * 60 );
      
      Serial.print("Epoch Time: "); Serial.println(epochTime);
  
      Serial.println(F("Sicronizando RTC interno com o servidor..."));
  
      rtc.adjust( DateTime( epochTime ) );
  
      Serial.println(F("RTC sicronizado com sucesso!"));
  
      clockInSync = 1;
  
    }

  }

}
void watchDogFeed() {

  rtc_wdt_feed(); //Alimenta o RTC WDT

}
void checkMidnightReset() {

  if ( now.hour() == 0 && prevHour == 23 ) {

    Serial.println(F("Reiniciando ESP32..."));

    ESP.restart();

  }

  prevHour = now.hour();

}
void handleSerialInput() {
  
  if ( Serial.available() ) {

    String MonitorInput;
  
    MonitorInput = Serial.readString();
    MonitorInput.trim();
  
    if ( MonitorInput.substring(0) == "rtc" ) setRTCtime();
    
  }

}
void setRTCtime() {

  uint16_t year;
  uint8_t month, day, hour, minute, second;

  Serial.print("Novo valor para ano (AAAA): ");
  while ( !Serial.available() );
  year = Serial.parseInt();
  Serial.println();
  if ( Serial.available() )Serial.read();
  //year = 2024;

  Serial.print("Novo valor para mês (MM): ");
  while ( !Serial.available() );
  month = Serial.parseInt();
  Serial.println();
  if ( Serial.available() )Serial.read();
  //month = 1;

  Serial.print("Novo valor para dia (DD): ");
  while ( !Serial.available() );
  day = Serial.parseInt();
  Serial.println();
  if ( Serial.available() )Serial.read();
  //day = 30;

  Serial.print("Novo valor para horas (hh): ");
  while ( !Serial.available() );
  hour = Serial.parseInt();
  Serial.println();
  if ( Serial.available() )Serial.read();

  Serial.print("Novo valor para minutos (mm): ");
  while ( !Serial.available() );
  minute = Serial.parseInt();
  Serial.println();
  if ( Serial.available() )Serial.read();

  Serial.print("Novo valor para segundos (ss): ");
  while ( !Serial.available() );
  second = Serial.parseInt();
  Serial.println();
  if ( Serial.available() )Serial.read();

  rtc.adjust( DateTime( year, month, day, hour, minute, second ) );

  Serial.println("Relogio ajustado com sucesso! ");

}
void dht22Read() {

  temperature = dht.readTemperature() * DHT_TEMPERATURE_GAIN + DHT_TEMPERATURE_OFFSET;
  humidity = dht.readHumidity() * DHT_HUMIDITY_GAIN + DHT_HUMIDITY_OFFSET;

  Serial.print(F("Temperature - ")); Serial.print(temperature); Serial.println(F(" C"));
  Serial.print(F("Humidity - ")); Serial.print(humidity); Serial.println(F(" %"));

}
float luxToPPFD( float lux ) {

  //return( lux * 0.023 );
  return ( lux * LUX_TO_PPFD );

}
void bh1750Read() {

#ifdef FEED_BACK_LIGHT_CONTROL

  illuminance = lightMeterBH1750.readLightLevel() ;
  ppfd_sun = round( luxToPPFD( illuminance ) );
  Serial.print(F("Illuminance - ")); Serial.print(illuminance); Serial.println(F(" lux"));
  Serial.print(F("PPFD - ")); Serial.print(ppfd_sun); Serial.println(F(" PPFD"));

  illuminance = illuminance * BH1750_ILLUMINANCE_GAIN * LAMP_TRANSMITTANCE;
  ppfd_sun = round( luxToPPFD( illuminance ) );
  illuminance = round( illuminance );
  Serial.print(F("Illuminance (CALIB) - ")); Serial.print(illuminance); Serial.println(F(" lux"));
  Serial.print(F("PPFD (CALIB) - ")); Serial.print(ppfd_sun); Serial.println(F(" PPFD"));

#else

  illuminance = 0.0;
  ppfd_sun = 0.0;

#endif

}
void mhz19bRead() {
  
  MHZ19B.measure();

  ppm_co2 = (float)MHZ19B.getCO2();

  Serial.print("ppm_co2: "); Serial.println(ppm_co2);

  while( ppm_co2 > 2000.0 ){

    Serial.println("Reiniciando MHZ14B...");
    
    Serial2.end();

    delay(1000);

    MHZ19B.begin( &Serial2 );
    Serial2.begin( 9600 );

    Serial.println("MHZ14B Reiniciado!");

    delay(1000);
    
    MHZ19B.measure();

    float ppm_co2_old = ppm_co2;

    ppm_co2 = (float)MHZ19B.getCO2();

    //if( ppm_co2 <= 2000.0 ){
    
    mhz14bLog( ppm_co2 , ppm_co2_old );

    Serial.print("ppm_co2 (OLD): "); Serial.print(ppm_co2_old); Serial.print(" ");
    Serial.print("ppm_co2 (NEW): "); Serial.print(ppm_co2);
    Serial.println();
    //}
    
  } 

  //Serial.print("ppm_co2: "); Serial.println(ppm_co2);
  
  ppm_co2 = ppm_co2 * MHZ19B_PPM_GAIN + MHZ19B_PPM_OFFSET;

  Serial.print("ppm_co2 (CALIB): "); Serial.println(ppm_co2);

}
void checkEnergyReset(){
  
  if( reset_energy == 1 ){
      
    Serial.println("Integral da Energia zerada.");
    
    pzem.resetEnergy();

    reset_energy = 0;
    
  }
  
}
void pzem004tv3(){
  
  // Read the data from the sensor
  voltage = pzem.voltage();
  current = pzem.current();
  power = pzem.power();
  energy = pzem.energy();
  frequency = pzem.frequency();
  power_factor = pzem.pf();

  // Check if the data is valid
  if( isnan(voltage ) )             Serial.println("Error reading voltage");
  else if ( isnan( current ) )      Serial.println("Error reading current");
  else if ( isnan( power ) )        Serial.println("Error reading power");
  else if ( isnan( energy ) )       Serial.println("Error reading energy");
  else if ( isnan( frequency ) )    Serial.println("Error reading frequency");
  else if ( isnan( power_factor ) ) Serial.println("Error reading power factor");
  else {

    // Print the values to the Serial console
    Serial.print("Voltage: ");      Serial.print(voltage);      Serial.println("V");
    Serial.print("Current: ");      Serial.print(current);      Serial.println("A");
    Serial.print("Power: ");        Serial.print(power);        Serial.println("W");
    Serial.print("Energy: ");       Serial.print(energy,3);     Serial.println("kWh");
    Serial.print("Frequency: ");    Serial.print(frequency, 1); Serial.println("Hz");
    Serial.print("Power Factor: "); Serial.println(power_factor);
      
  }
  
}
float dimToPPFD( int dim, int8_t channel ) {

  switch ( channel ) {

    case 1:
      return ( constrain_f( map_f( (float)dim, 0.0, 100.0, PPFD_MIN_CH1, PPFD_MAX_CH1 ), PPFD_MIN_CH1, PPFD_MAX_CH1 ) );
    break;

    case 2:
      return ( constrain_f( map_f( (float)dim, 0.0, 100.0, PPFD_MIN_CH2, PPFD_MAX_CH2 ), PPFD_MIN_CH2, PPFD_MAX_CH2 ) );
    break;

    case 3:
      return ( constrain_f( map_f( (float)dim, 0.0, 100.0, PPFD_MIN_CH3, PPFD_MAX_CH3 ), PPFD_MIN_CH3, PPFD_MAX_CH3 ) );
    break;

    case 4:
      return ( constrain_f( map_f( (float)dim, 0.0, 100.0, PPFD_MIN_CH4, PPFD_MAX_CH4 ), PPFD_MIN_CH4, PPFD_MAX_CH4 ) );
    break;
/*    
    case 5:
      return ( constrain_f( map_f( (float)dim, 0.0, 100.0, PPFD_MIN_CH5, PPFD_MAX_CH5 ), PPFD_MIN_CH5, PPFD_MAX_CH5 ) );
    break;

    case 6:
      return ( constrain_f( map_f( (float)dim, 0.0, 100.0, PPFD_MIN_CH6, PPFD_MAX_CH6 ), PPFD_MIN_CH6, PPFD_MAX_CH6 ) );
    break;

    case 7:
      return ( constrain_f( map_f( (float)dim, 0.0, 100.0, PPFD_MIN_CH7, PPFD_MAX_CH7 ), PPFD_MIN_CH7, PPFD_MAX_CH7 ) );
    break;

    case 8:
      return ( constrain_f( map_f( (float)dim, 0.0, 100.0, PPFD_MIN_CH8, PPFD_MAX_CH8 ), PPFD_MIN_CH8, PPFD_MAX_CH8 ) );
    break;
*/
    default:
      Serial.println("Erro na funcao dimToPPFD! Canal invalido!");
      return ( -1 );
    break;

  }

}
int8_t PPFDtoDim( float _ppfd, int8_t channel ) {

  switch ( channel ) {

    case 1:
      return ( (int8_t)constrain_f( round( map_f( _ppfd, PPFD_MIN_CH1, PPFD_MAX_CH1, 0.0, 100.0 ) ), 0.0, 100.0  ) );
      break;

    case 2:
      return ( (int8_t)constrain_f( round( map_f( _ppfd, PPFD_MIN_CH2, PPFD_MAX_CH2, 0.0, 100.0 ) ), 0.0, 100.0  ) );
      break;

    case 3:
      return ( (int8_t)constrain_f( round( map_f( _ppfd, PPFD_MIN_CH3, PPFD_MAX_CH3, 0.0, 100.0 ) ), 0.0, 100.0  ) );
      break;

    case 4:
      return ( (int8_t)constrain_f( round( map_f( _ppfd, PPFD_MIN_CH4, PPFD_MAX_CH4, 0.0, 100.0 ) ), 0.0, 100.0  ) );
      break;
/*      
    case 5:
      return ( (int8_t)constrain_f( round( map_f( _ppfd, PPFD_MIN_CH5, PPFD_MAX_CH5, 0.0, 100.0 ) ), 0.0, 100.0  ) );
      break;

    case 6:
      return ( (int8_t)constrain_f( round( map_f( _ppfd, PPFD_MIN_CH6, PPFD_MAX_CH6, 0.0, 100.0 ) ), 0.0, 100.0  ) );
      break;

    case 7:
      return ( (int8_t)constrain_f( round( map_f( _ppfd, PPFD_MIN_CH7, PPFD_MAX_CH7, 0.0, 100.0 ) ), 0.0, 100.0  ) );
      break;

    case 8:
      return ( (int8_t)constrain_f( round( map_f( _ppfd, PPFD_MIN_CH8, PPFD_MAX_CH8, 0.0, 100.0 ) ), 0.0, 100.0  ) );
      break;
*/
    default:
      Serial.println("Erro na funcao PPFDtoDim! Canal invalido!");
      return ( -1 );
      break;

  }

}
long HMStoSeconds( uint8_t _hours, uint8_t _minutes, uint8_t _seconds ) {

  return ( _hours * 3600 + _minutes * 60 + _seconds );

}
void illuminationHandler() {
  
  Serial.print("dim_mode: "); Serial.println(dim_mode);
  
  dim1 = mapDimmingTable( &dimCH1 );
  dim2 = mapDimmingTable( &dimCH2 );
  dim3 = mapDimmingTable( &dimCH3 );
  dim4 = mapDimmingTable( &dimCH4 );
  //dim5 = mapDimmingTable( &dimCH5 );
  //dim6 = mapDimmingTable( &dimCH6 );
  //dim7 = mapDimmingTable( &dimCH7 );
  //dim8 = mapDimmingTable( &dimCH8 );
  
  //Serial.println(F("DIM PPFD"));
  //Serial.print(dim1); Serial.print(F(" "));
  //Serial.print(dim2); Serial.print(F(" "));
  //Serial.print(dim3); Serial.print(F(" "));
  //Serial.print(dim4); Serial.print(F(" "));
  //Serial.print(dim5); Serial.print(F(" "));
  //Serial.print(dim6); Serial.print(F(" "));
  //Serial.print(dim7); Serial.print(F(" "));
  //Serial.print(dim8); Serial.println();
  
  //if ( dim1 == -1 && dim2 == -1 && dim3 == -1 && dim4 == -1 && dim5 == -1 && dim6 == -1 && dim7 == -1 && dim8 == -1 ) {
  if ( dim1 == -1 && dim2 == -1 && dim3 == -1 && dim4 == -1 ) {
    photoPeriodFlag = 0;
  } else {
    photoPeriodFlag = 1;
  }

  if ( dim_mode == 2 ) {

    if ( photoPeriodFlag == 0 ) {
      digitalWrite( RELAY_PIN_1, LOW );
      //digitalWrite( RELAY_PIN_1, HIGH );
    } else {
      digitalWrite( RELAY_PIN_1, HIGH );
      //digitalWrite( RELAY_PIN_1, LOW );
    }

    if ( dim1 < 0 ) dim1 = 0;
    if ( dim2 < 0 ) dim2 = 0;
    if ( dim3 < 0 ) dim3 = 0;
    if ( dim4 < 0 ) dim4 = 0;
    //if ( dim5 < 0 ) dim5 = 0;
    //if ( dim6 < 0 ) dim6 = 0;
    //if ( dim7 < 0 ) dim7 = 0;
    //if ( dim8 < 0 ) dim8 = 0;

    ppfd_total_target_ch1 = (float)dim1;
    ppfd_total_target_ch2 = (float)dim2;
    ppfd_total_target_ch3 = (float)dim3;
    ppfd_total_target_ch4 = (float)dim4;
    //ppfd_total_target_ch5 = (float)dim5;
    //ppfd_total_target_ch6 = (float)dim6;
    //ppfd_total_target_ch7 = (float)dim7;
    //ppfd_total_target_ch8 = (float)dim8;

    //Serial.println(F("PPFD Total Alvo (Sol+Luminarias)"));
    //Serial.print(ppfd_total_target_ch1); Serial.print(" ");
    //Serial.print(ppfd_total_target_ch2); Serial.print(" ");
    //Serial.print(ppfd_total_target_ch3); Serial.print(" ");
    //Serial.print(ppfd_total_target_ch4); Serial.print(" ");
    //Serial.print(ppfd_total_target_ch5); Serial.print(" ");
    //Serial.print(ppfd_total_target_ch6); Serial.print(" ");
    //Serial.print(ppfd_total_target_ch7); Serial.print(" ");
    //Serial.print(ppfd_total_target_ch8); Serial.println();

    //Serial.println(F("PPFD Sol"));
    //Serial.print(ppfd_sun); Serial.println();

    // dim -> PPFD Luminaria Alvo
    dim1 = dim1 - (int)ppfd_sun;
    dim2 = dim2 - (int)ppfd_sun;
    dim3 = dim3 - (int)ppfd_sun;
    dim4 = dim4 - (int)ppfd_sun;
    //dim5 = dim5 - (int)ppfd_sun;
    //dim6 = dim6 - (int)ppfd_sun;
    //dim7 = dim7 - (int)ppfd_sun;
    //dim8 = dim8 - (int)ppfd_sun;

    if ( dim1 < 0 ) dim1 = 0;
    if ( dim2 < 0 ) dim2 = 0;
    if ( dim3 < 0 ) dim3 = 0;
    if ( dim4 < 0 ) dim4 = 0;
    //if ( dim5 < 0 ) dim5 = 0;
    //if ( dim6 < 0 ) dim6 = 0;
    //if ( dim7 < 0 ) dim7 = 0;
    //if ( dim8 < 0 ) dim8 = 0;

    ppfd_lamp_target_ch1 = (float)dim1;
    ppfd_lamp_target_ch2 = (float)dim2;
    ppfd_lamp_target_ch3 = (float)dim3;
    ppfd_lamp_target_ch4 = (float)dim4;
    //ppfd_lamp_target_ch5 = (float)dim5;
    //ppfd_lamp_target_ch6 = (float)dim6;
    //ppfd_lamp_target_ch7 = (float)dim7;
    //ppfd_lamp_target_ch8 = (float)dim8;

    //Serial.println(F("PPFD Luminárias Alvo"));
    //Serial.print(ppfd_lamp_target_ch1); Serial.print(F(" "));
    //Serial.print(ppfd_lamp_target_ch2); Serial.print(F(" "));
    //Serial.print(ppfd_lamp_target_ch3); Serial.print(F(" "));
    //Serial.print(ppfd_lamp_target_ch4); Serial.print(F(" "));
    //Serial.print(ppfd_lamp_target_ch5); Serial.print(F(" "));
    //Serial.print(ppfd_lamp_target_ch6); Serial.print(F(" "));
    //Serial.print(ppfd_lamp_target_ch7); Serial.print(F(" "));
    //Serial.print(ppfd_lamp_target_ch8); Serial.println();

    // dim -> Porcentagem Dimerizacao 0 a 100
    if ( photoPeriodFlag == 1 ) {
      dim1 = PPFDtoDim( (float)dim1, 1 );
      dim2 = PPFDtoDim( (float)dim2, 2 );
      dim3 = PPFDtoDim( (float)dim3, 3 );
      dim4 = PPFDtoDim( (float)dim4, 4 );
      //dim5 = PPFDtoDim( (float)dim5, 5 );
      //dim6 = PPFDtoDim( (float)dim6, 6 );
      //dim7 = PPFDtoDim( (float)dim7, 7 );
      //dim8 = PPFDtoDim( (float)dim8, 8 );
      ppfd_lamp_ch1 = dimToPPFD( dim1, 1 );
      ppfd_lamp_ch2 = dimToPPFD( dim2, 2 );
      ppfd_lamp_ch3 = dimToPPFD( dim3, 3 );
      ppfd_lamp_ch4 = dimToPPFD( dim4, 4 );
      //ppfd_lamp_ch5 = dimToPPFD( dim5, 5 );
      //ppfd_lamp_ch6 = dimToPPFD( dim6, 6 );
      //ppfd_lamp_ch7 = dimToPPFD( dim7, 7 );
      //ppfd_lamp_ch8 = dimToPPFD( dim8, 8 );
    } else {
      dim1 = 0;
      dim2 = 0;
      dim3 = 0;
      dim4 = 0;
      //dim5 = 0;
      //dim6 = 0;
      //dim7 = 0;
      //dim8 = 0;
      ppfd_lamp_ch1 = 0.0;
      ppfd_lamp_ch2 = 0.0;
      ppfd_lamp_ch3 = 0.0;
      ppfd_lamp_ch4 = 0.0;
      //ppfd_lamp_ch5 = 0.0;
      //ppfd_lamp_ch6 = 0.0;
      //ppfd_lamp_ch7 = 0.0;
      //ppfd_lamp_ch8 = 0.0;
    }

    dim1_out = dim1;
    dim2_out = dim2;
    dim3_out = dim3;
    dim4_out = dim4;
    //dim5_out = dim5;
    //dim6_out = dim6;
    //dim7_out = dim7;
    //dim8_out = dim8;

    //Serial.println(F("DIM 0-100"));
    //Serial.print(dim1); Serial.print(F(" "));
    //Serial.print(dim2); Serial.print(F(" "));
    //Serial.print(dim3); Serial.print(F(" "));
    //Serial.print(dim4); Serial.print(F(" "));
    //Serial.print(dim5); Serial.print(F(" "));
    //Serial.print(dim6); Serial.print(F(" "));
    //Serial.print(dim7); Serial.print(F(" "));
    //Serial.print(dim8); Serial.println();

    //Serial.println(F("PPFD Luminárias"));
    //Serial.print(ppfd_lamp_ch1); Serial.print(F(" "));
    //Serial.print(ppfd_lamp_ch2); Serial.print(F(" "));
    //Serial.print(ppfd_lamp_ch3); Serial.print(F(" "));
    //Serial.print(ppfd_lamp_ch4); Serial.print(F(" "));
    //Serial.print(ppfd_lamp_ch5); Serial.print(F(" "));
    //Serial.print(ppfd_lamp_ch6); Serial.print(F(" "));
    //Serial.print(ppfd_lamp_ch7); Serial.print(F(" "));
    //Serial.print(ppfd_lamp_ch8); Serial.println();

    ppfd_total_ch1 = ppfd_lamp_ch1 + ppfd_sun;
    ppfd_total_ch2 = ppfd_lamp_ch2 + ppfd_sun;
    ppfd_total_ch3 = ppfd_lamp_ch3 + ppfd_sun;
    ppfd_total_ch4 = ppfd_lamp_ch4 + ppfd_sun;
    //ppfd_total_ch5 = ppfd_lamp_ch5 + ppfd_sun;
    //ppfd_total_ch6 = ppfd_lamp_ch6 + ppfd_sun;
    //ppfd_total_ch7 = ppfd_lamp_ch7 + ppfd_sun;
    //ppfd_total_ch8 = ppfd_lamp_ch8 + ppfd_sun;

    //Serial.println(F("PPFD Total"));
    //Serial.print(ppfd_total_ch1); Serial.print(F(" "));
    //Serial.print(ppfd_total_ch2); Serial.print(F(" "));
    //Serial.print(ppfd_total_ch3); Serial.print(F(" "));
    //Serial.print(ppfd_total_ch4); Serial.print(F(" "));
    //Serial.print(ppfd_total_ch5); Serial.print(F(" "));
    //Serial.print(ppfd_total_ch6); Serial.print(F(" "));
    //Serial.print(ppfd_total_ch7); Serial.print(F(" "));
    //Serial.print(ppfd_total_ch8); Serial.println();

    if ( photoPeriodFlag == 1 ) {
      dim1 = map_i8( dim1, 0, 100, DIMMING_MIN_DAC, DIMMING_MAX_DAC );
      dim2 = map_i8( dim2, 0, 100, DIMMING_MIN_DAC, DIMMING_MAX_DAC );
      dim3 = map_i8( dim3, 0, 100, DIMMING_MIN_DAC, DIMMING_MAX_DAC );
      dim4 = map_i8( dim4, 0, 100, DIMMING_MIN_DAC, DIMMING_MAX_DAC );
      //dim5 = map_i8( dim5, 0, 100, DIMMING_MIN_PWM, DIMMING_MAX_PWM );
      //dim6 = map_i8( dim6, 0, 100, DIMMING_MIN_PWM, DIMMING_MAX_PWM );
      //dim7 = map_i8( dim7, 0, 100, DIMMING_MIN_PWM, DIMMING_MAX_PWM );
      //dim8 = map_i8( dim8, 0, 100, DIMMING_MIN_PWM, DIMMING_MAX_PWM );
    } else {
      dim1 = 0;
      dim2 = 0;
      dim3 = 0;
      dim4 = 0;
      //dim5 = 0;
      //dim6 = 0;
      //dim7 = 0;
      //dim8 = 0;
    }

    //Serial.println(F("DIM 5-95"));
    //Serial.print(dim1); Serial.print(F(" "));
    //Serial.print(dim2); Serial.print(F(" "));
    //Serial.print(dim3); Serial.print(F(" "));
    //Serial.print(dim4); Serial.println();
    //Serial.println(F("DIM 10-90"));
    //Serial.print(dim5); Serial.print(F(" "));
    //Serial.print(dim6); Serial.print(F(" "));
    //Serial.print(dim7); Serial.print(F(" "));
    //Serial.print(dim8); Serial.println();

    //Serial.println("-----------------------------");
    
    dac1_out.setVoltage( (uint16_t)( (uint16_t)dim1 * 4095 / 100 ), false );
    dac2_out.setVoltage( (uint16_t)( (uint16_t)dim2 * 4095 / 100 ), false );
    dac3_out.setVoltage( (uint16_t)( (uint16_t)dim3 * 4095 / 100 ), false );
    dac4_out.setVoltage( (uint16_t)( (uint16_t)dim4 * 4095 / 100 ), false );
    //pwm.write( PWM_PIN_1, (int32_t)( (int32_t)dim5 * 4095 / 100 ), DefaultPWMfrequency, DefaultPWMresolution, DefaultPWMphase );
    //pwm.write( PWM_PIN_2, (int32_t)( (int32_t)dim6 * 4095 / 100 ), DefaultPWMfrequency, DefaultPWMresolution, DefaultPWMphase );
    //pwm.write( PWM_PIN_3, (int32_t)( (int32_t)dim7 * 4095 / 100 ), DefaultPWMfrequency, DefaultPWMresolution, DefaultPWMphase );
    //pwm.write( PWM_PIN_4, (int32_t)( (int32_t)dim8 * 4095 / 100 ), DefaultPWMfrequency, DefaultPWMresolution, DefaultPWMphase );

  } else {

    if( dim_mode == 0 ){
      
      dim1_out = 0.0;
      dim2_out = 0.0;
      dim3_out = 0.0;
      dim4_out = 0.0;
      //dim5_out = 0.0;
      //dim6_out = 0.0;
      //dim7_out = 0.0;
      //dim8_out = 0.0;
      
      dac1_out.setVoltage( 0, false );
      //Serial.print("dim1_out: ");Serial.println(dim1_out);
      dac2_out.setVoltage( 0, false );
      //Serial.print("dim2_out: ");Serial.println(dim2_out);
      dac3_out.setVoltage( 0, false );
      //Serial.print("dim3_out: ");Serial.println(dim3_out);
      dac4_out.setVoltage( 0, false );
      //Serial.print("dim4_out: ");Serial.println(dim4_out);
      //pwm.write( PWM_PIN_1, 0, DefaultPWMfrequency, DefaultPWMresolution, DefaultPWMphase );
      //Serial.print("dim5_out: ");Serial.println(dim5_out);
      //pwm.write( PWM_PIN_2, 0, DefaultPWMfrequency, DefaultPWMresolution, DefaultPWMphase );
      //Serial.print("dim6_out: ");Serial.println(dim6_out);
      //pwm.write( PWM_PIN_3, 0, DefaultPWMfrequency, DefaultPWMresolution, DefaultPWMphase );
      //Serial.print("dim7_out: ");Serial.println(dim7_out);
      //pwm.write( PWM_PIN_4, 0, DefaultPWMfrequency, DefaultPWMresolution, DefaultPWMphase );
      //Serial.print("dim8_out: ");Serial.println(dim8_out);
      
      digitalWrite( RELAY_PIN_1, LOW );
      //digitalWrite( RELAY_PIN_1, HIGH );

      ppfd_total_target_ch1 = 0.0;
      ppfd_total_target_ch2 = 0.0;
      ppfd_total_target_ch3 = 0.0;
      ppfd_total_target_ch4 = 0.0;
      //ppfd_total_target_ch5 = 0.0;
      //ppfd_total_target_ch6 = 0.0;
      //ppfd_total_target_ch7 = 0.0;
      //ppfd_total_target_ch8 = 0.0;
      ppfd_lamp_target_ch1 = 0.0;
      ppfd_lamp_target_ch2 = 0.0;
      ppfd_lamp_target_ch3 = 0.0;
      ppfd_lamp_target_ch4 = 0.0;
      //ppfd_lamp_target_ch5 = 0.0;
      //ppfd_lamp_target_ch6 = 0.0;
      //ppfd_lamp_target_ch7 = 0.0;
      //ppfd_lamp_target_ch8 = 0.0;
      ppfd_lamp_ch1 = 0.0;
      ppfd_lamp_ch2 = 0.0;
      ppfd_lamp_ch3 = 0.0;
      ppfd_lamp_ch4 = 0.0;
      //ppfd_lamp_ch5 = 0.0;
      //ppfd_lamp_ch6 = 0.0;
      //ppfd_lamp_ch7 = 0.0;
      //ppfd_lamp_ch8 = 0.0;
      ppfd_total_ch1 = ppfd_lamp_ch1 + ppfd_sun;
      ppfd_total_ch2 = ppfd_lamp_ch2 + ppfd_sun;
      ppfd_total_ch3 = ppfd_lamp_ch3 + ppfd_sun;
      ppfd_total_ch4 = ppfd_lamp_ch4 + ppfd_sun;
      //ppfd_total_ch5 = ppfd_lamp_ch5 + ppfd_sun;
      //ppfd_total_ch6 = ppfd_lamp_ch6 + ppfd_sun;
      //ppfd_total_ch7 = ppfd_lamp_ch7 + ppfd_sun;
      //ppfd_total_ch8 = ppfd_lamp_ch8 + ppfd_sun;
      
    } else { // if( dim_mode == 1 ){
    
      dim = (int16_t)map_i8( (int8_t)dac1_in, 0, 100, DIMMING_MIN_DAC, DIMMING_MAX_DAC );
      dim = dim * 4095 / 100;
      dim1_out = dac1_in;
      dac1_out.setVoltage( dim, false );
      //Serial.print("dim1_out: ");Serial.println(dim1_out);
      
      dim = (int16_t)map_i8( (int8_t)dac2_in, 0, 100, DIMMING_MIN_DAC, DIMMING_MAX_DAC );
      dim = dim * 4095 / 100;
      dim2_out = dac2_in;
      dac2_out.setVoltage( dim, false );
      //Serial.print("dim2_out: ");Serial.println(dim2_out);
      
      dim = (int16_t)map_i8( (int8_t)dac3_in, 0, 100, DIMMING_MIN_DAC, DIMMING_MAX_DAC );
      dim = dim * 4095 / 100;
      dim3_out = dac3_in;
      dac3_out.setVoltage( dim, false );
      //Serial.print("dim3_out: ");Serial.println(dim3_out);
      
      dim = (int16_t)map_i8( (int8_t)dac4_in, 0, 100, DIMMING_MIN_DAC, DIMMING_MAX_DAC );
      dim = dim * 4095 / 100;
      dim4_out = dac4_in;
      dac4_out.setVoltage( dim, false );
      //Serial.print("dim4_out: ");Serial.println(dim4_out);
      
      //dim = (int16_t)map_i8( (int8_t)dac5_in, 0, 100, DIMMING_MIN_PWM, DIMMING_MAX_PWM );
      //dim = dim * 4095 / 100;
      //dim5_out = dac5_in;
      //pwm.write( PWM_PIN_1, (int32_t)dim, DefaultPWMfrequency, DefaultPWMresolution, DefaultPWMphase  );
      //Serial.print("dim5_out: ");Serial.println(dim5_out);

      //dim = (int16_t)map_i8( (int8_t)dac6_in, 0, 100, DIMMING_MIN_DAC, DIMMING_MAX_DAC );
      //dim = dim * 4095 / 100;
      //dim6_out = dac6_in;
      //pwm.write( PWM_PIN_2, (int32_t)dim, DefaultPWMfrequency, DefaultPWMresolution, DefaultPWMphase  );
      //Serial.print("dim6_out: ");Serial.println(dim6_out);

      //dim = (int16_t)map_i8( (int8_t)dac7_in, 0, 100, DIMMING_MIN_DAC, DIMMING_MAX_DAC );
      //dim = dim * 4095 / 100;
      //dim7_out = dac7_in;
      //pwm.write( PWM_PIN_3, (int32_t)dim, DefaultPWMfrequency, DefaultPWMresolution, DefaultPWMphase  );
      //Serial.print("dim7_out: ");Serial.println(dim7_out);

      //dim = (int16_t)map_i8( (int8_t)dac8_in, 0, 100, DIMMING_MIN_DAC, DIMMING_MAX_DAC );
      //dim = dim * 4095 / 100;
      //dim8_out = dac8_in;
      //pwm.write( PWM_PIN_4, (int32_t)dim, DefaultPWMfrequency, DefaultPWMresolution, DefaultPWMphase  );
      //Serial.print("dim8_out: ");Serial.println(dim8_out);
      
      //digitalWrite( RELAY_PIN_1, LOW );
      digitalWrite( RELAY_PIN_1, HIGH );

      ppfd_total_target_ch1 = 0.0;
      ppfd_total_target_ch2 = 0.0;
      ppfd_total_target_ch3 = 0.0;
      ppfd_total_target_ch4 = 0.0;
      //ppfd_total_target_ch5 = 0.0;
      //ppfd_total_target_ch6 = 0.0;
      //ppfd_total_target_ch7 = 0.0;
      //ppfd_total_target_ch8 = 0.0;
      ppfd_lamp_target_ch1 = 0.0;
      ppfd_lamp_target_ch2 = 0.0;
      ppfd_lamp_target_ch3 = 0.0;
      ppfd_lamp_target_ch4 = 0.0;
      //ppfd_lamp_target_ch5 = 0.0;
      //ppfd_lamp_target_ch6 = 0.0;
      //ppfd_lamp_target_ch7 = 0.0;
      //ppfd_lamp_target_ch8 = 0.0;
      ppfd_lamp_ch1 = dimToPPFD( (int)dac1_in, 1 );
      ppfd_lamp_ch2 = dimToPPFD( (int)dac2_in, 2 );
      ppfd_lamp_ch3 = dimToPPFD( (int)dac3_in, 3 );
      ppfd_lamp_ch4 = dimToPPFD( (int)dac4_in, 4 );
      //ppfd_lamp_ch5 = dimToPPFD( (int)dac5_in, 5 );
      //ppfd_lamp_ch6 = dimToPPFD( (int)dac6_in, 6 );
      //ppfd_lamp_ch7 = dimToPPFD( (int)dac7_in, 7 );
      //ppfd_lamp_ch8 = dimToPPFD( (int)dac8_in, 8 );
      ppfd_total_ch1 = ppfd_lamp_ch1 + ppfd_sun;
      ppfd_total_ch2 = ppfd_lamp_ch2 + ppfd_sun;
      ppfd_total_ch3 = ppfd_lamp_ch3 + ppfd_sun;
      ppfd_total_ch4 = ppfd_lamp_ch4 + ppfd_sun;
      //ppfd_total_ch5 = ppfd_lamp_ch5 + ppfd_sun;
      //ppfd_total_ch6 = ppfd_lamp_ch6 + ppfd_sun;
      //ppfd_total_ch7 = ppfd_lamp_ch7 + ppfd_sun;
      //ppfd_total_ch8 = ppfd_lamp_ch8 + ppfd_sun;
      
    }

  }

  if( clockInSync == 1 && photoPeriodFlag == 1 ){
    
    dli_ch1 += ( ppfd_total_ch1 * (float)dt / 1000000.0 / 1000.0 );
    dli_ch2 += ( ppfd_total_ch2 * (float)dt / 1000000.0 / 1000.0 );
    dli_ch3 += ( ppfd_total_ch3 * (float)dt / 1000000.0 / 1000.0 );
    dli_ch4 += ( ppfd_total_ch4 * (float)dt / 1000000.0 / 1000.0 );
    //dli_ch5 += ( ppfd_total_ch5 * (float)dt / 1000000.0 / 1000.0 );
    //dli_ch6 += ( ppfd_total_ch6 * (float)dt / 1000000.0 / 1000.0 );
    //dli_ch7 += ( ppfd_total_ch7 * (float)dt / 1000000.0 / 1000.0 );
    //dli_ch8 += ( ppfd_total_ch8 * (float)dt / 1000000.0 / 1000.0 );
    dli_sun += ( ppfd_sun * (float)dt / 1000000.0 / 1000.0 );
    
  }
  
  //if( ArduinoCloud.connected() == 1 && clockInSync == 1 && photoPeriodFlag == 0 && ppfd_sun < 0.1 ){
  if( clockInSync == 1 && photoPeriodFlag == 0 && ppfd_sun < 0.1 ){ // substituir por conectado ao MQTT
    
    //Serial.println("Zerando DLI.");
    
    dli_ch1 = 0;
    dli_ch2 = 0;
    dli_ch3 = 0;
    dli_ch4 = 0;
    //dli_ch5 = 0;
    //dli_ch6 = 0;
    //dli_ch7 = 0;
    //dli_ch8 = 0;
    dli_sun = 0;
    
  }

}
int mapDimmingTable( dimming_t *dimming ) {

  int dimming_value;
  long _seconds;

  _seconds = HMStoSeconds( now.hour(), now.minute(), now.second() );
  _seconds = ( _seconds - HMStoSeconds( dimming->hours[0], dimming->minutes[0], dimming->seconds[0] ) );

  if ( _seconds < 0 ) return ( -1 );

  if ( _seconds > ( HMStoSeconds( dimming->hours[dimming->dimmingPoints - 1], dimming->minutes[dimming->dimmingPoints - 1], dimming->seconds[dimming->dimmingPoints - 1] ) - HMStoSeconds( dimming->hours[0], dimming->minutes[0], dimming->seconds[0] ) ) ) return ( -1 );

  for ( uint8_t counter = 0 ; counter < dimming->dimmingPoints ; counter++ ) {

    if ( dimming->secondsSinceStart[counter] > _seconds ) {

      dimming_value = map( _seconds,
                           dimming->secondsSinceStart[counter - 1],
                           dimming->secondsSinceStart[counter],
                           dimming->value[counter - 1],
                           dimming->value[counter] );

      break;

    }

  }

  return ( dimming_value );

}
void readFile( fs::FS &fs, const char * path, dimming_t *dimming ) {

  File file = fs.open( path, FILE_READ );
  if ( !file ) {
    Serial.println("Failed to open file for reading");
    return;
  }

  //printf("\n\nreadFile:\n");
  for ( uint8_t counter = 0 ; counter < DIMMING_POINTS_MAX ; counter ++ ) {

    dimming->hours[counter]   = file.parseInt();
    dimming->minutes[counter] = file.parseInt();
    dimming->seconds[counter] = file.parseInt();

    if ( !file.available() )break;

    dimming->value[counter] = file.parseInt();

    dimming->dimmingPoints = ( counter + 1 );

    //printf("%d\t%d\t%d\t%d\n", dimming->hours[counter], dimming->minutes[counter], dimming->seconds[counter], dimming->value[counter] );

  }

  //printf("dimmingPoints: %d\n", dimming->dimmingPoints);

  file.close();

}
void getSecondsSinceStart( dimming_t *dimming ) {

  for ( uint8_t counter = 0 ; counter < dimming->dimmingPoints ; counter++ ) {

    dimming->secondsSinceStart[counter] = HMStoSeconds( dimming->hours[counter],
                                          dimming->minutes[counter],
                                          dimming->seconds[counter] );

    dimming->secondsSinceStart[counter] = dimming->secondsSinceStart[counter] -
                                          HMStoSeconds( dimming->hours[0],
                                              dimming->minutes[0],
                                              dimming->seconds[0] );

    //Serial.print("secondsSinceStart: "); Serial.println( dimming->secondsSinceStart[counter] );
  }

}
void getDimmingTable() {

  readFile( SD, "/ch1.txt", &dimCH1 ); getSecondsSinceStart( &dimCH1 );
  readFile( SD, "/ch2.txt", &dimCH2 ); getSecondsSinceStart( &dimCH2 );
  readFile( SD, "/ch3.txt", &dimCH3 ); getSecondsSinceStart( &dimCH3 );
  readFile( SD, "/ch4.txt", &dimCH4 ); getSecondsSinceStart( &dimCH4 );
  //readFile( SD, "/ch5.txt", &dimCH5 ); getSecondsSinceStart( &dimCH5 );
  //readFile( SD, "/ch6.txt", &dimCH6 ); getSecondsSinceStart( &dimCH6 );
  //readFile( SD, "/ch7.txt", &dimCH7 ); getSecondsSinceStart( &dimCH7 );
  //readFile( SD, "/ch8.txt", &dimCH8 ); getSecondsSinceStart( &dimCH8 );

}
void showTime() {

  Serial.print(now.year(), DEC);
  Serial.print('/');
  Serial.print(now.month(), DEC);
  Serial.print('/');
  Serial.print(now.day(), DEC);
  Serial.print(" (");
  Serial.print(daysOfTheWeek[now.dayOfTheWeek()]);
  Serial.print(") ");
  Serial.print(now.hour(), DEC);
  Serial.print(':');
  Serial.print(now.minute(), DEC);
  Serial.print(':');
  Serial.print(now.second(), DEC);
  Serial.println();

}
int8_t map_i8(int8_t x, int8_t in_min, int8_t in_max, int8_t out_min, int8_t out_max) {
  return (x - in_min) * (out_max - out_min) / (in_max - in_min) + out_min;
}
int16_t map_i16(int16_t x, int16_t in_min, int16_t in_max, int16_t out_min, int16_t out_max) {
  return (x - in_min) * (out_max - out_min) / (in_max - in_min) + out_min;
}
int32_t map_i32(int32_t x, int32_t in_min, int32_t in_max, int32_t out_min, int32_t out_max) {
  return (x - in_min) * (out_max - out_min) / (in_max - in_min) + out_min;
}
float constrain_f( float x, float min, float max ) {
  if ( x < min )return ( min );
  else if ( x > max )return ( max );
  else return ( x );
}
float map_f(float x, float in_min, float in_max, float out_min, float out_max) {
  return (x - in_min) * (out_max - out_min) / (in_max - in_min) + out_min;
}