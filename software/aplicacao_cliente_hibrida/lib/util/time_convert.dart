import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class TimeConverter {
  // Inicializa os dados de fuso horário uma única vez
  static void initializeTimeZone() {
    tz.initializeTimeZones(); // Inicializa os dados de fuso horário
    tz.setLocalLocation(tz.getLocation(
        'America/Sao_Paulo')); // Define o fuso horário local para Brasília
  }

  static DateTime convertUtcToBrasilia(DateTime utcTime) {
    // Certifique-se de que o utcTime é realmente UTC
    if (!utcTime.isUtc) {
      throw ArgumentError('O tempo fornecido deve estar em UTC');
    }

    // Define a localização de Brasília
    final locationBrasilia = tz.getLocation('America/Sao_Paulo');

    // Converte UTC para o horário de Brasília
    final brasiliaTime = tz.TZDateTime.from(utcTime, locationBrasilia);

    // Converte de volta para um objeto DateTime não localizado para facilitar a manipulação
    return DateTime(brasiliaTime.year, brasiliaTime.month, brasiliaTime.day,
        brasiliaTime.hour, brasiliaTime.minute, brasiliaTime.second);
  }
}
