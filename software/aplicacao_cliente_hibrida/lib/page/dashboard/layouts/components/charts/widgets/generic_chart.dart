import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:ui' as ui;
import 'package:share_plus/share_plus.dart';

class GenericChart extends StatelessWidget {
  final GlobalKey _globalKey = GlobalKey();
  final List<FlSpot> spots;
  final List<String> xLabels;
  double minX, maxX, minY, maxY;
  String titulo;

  GenericChart({
    Key? key,
    required this.spots,
    required this.xLabels,
    required this.minX,
    required this.maxX,
    required this.minY,
    required this.maxY,
    required this.titulo,
  }) : super(key: key) {
    print(titulo);
  }

  @override
  Widget build(BuildContext context) {
    final interval = _calculateInterval(minY, maxY);
    final labelInterval = max((spots.length / 14).ceil(), 1).toDouble();
    final fontSize = (maxY.abs() > 1000 || minY.abs() > 1000) ? 8.0 : 10.0;

    return Column(
      children: [
        Text(
          titulo,
          style: TextStyle(color: Colors.white),
        ),
        RepaintBoundary(
          key: _globalKey,
          child: Container(
            height: 350,
            padding: const EdgeInsets.all(10),
            child: LineChart(
              LineChartData(
                lineTouchData: LineTouchData(
                  touchTooltipData: LineTouchTooltipData(
                    tooltipBgColor: Colors.blueAccent,
                    getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
                      return touchedBarSpots.map((barSpot) {
                        final dateString =
                            xLabels[barSpot.x.toInt() % xLabels.length];
                        return LineTooltipItem(
                          'Data: $dateString\nValor: ${barSpot.y.toStringAsFixed(2)}',
                          const TextStyle(color: Colors.white),
                        );
                      }).toList();
                    },
                  ),
                ),
                gridData: FlGridData(show: true),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        int index = value.toInt();
                        if (index % labelInterval == 0 &&
                            index < xLabels.length) {
                          return Padding(
                            padding: const EdgeInsets.fromLTRB(55, 0, 0, 0),
                            child: Transform.rotate(
                              angle: -90 * (pi / 180),
                              child: Text(
                                xLabels[index],
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 8,
                                ),
                                textAlign: TextAlign.right,
                              ),
                            ),
                          );
                        }
                        return const Text('');
                      },
                      reservedSize: 80,
                      interval: labelInterval,
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: interval,
                      reservedSize: 60, // Mantém um bom espaçamento
                      getTitlesWidget: (value, meta) {
                        return Text(
                          _formatYAxisLabel(value),
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: fontSize,
                          ),
                        );
                      },
                    ),
                  ),
                  rightTitles:
                      AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles:
                      AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: true),
                minX: minX,
                maxX: maxX,
                minY: minY,
                maxY: maxY,
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: false,
                    color: Colors.blueAccent,
                    barWidth: 2,
                    isStrokeCapRound: true,
                    dotData: FlDotData(show: false),
                    belowBarData: BarAreaData(show: false),
                  ),
                ],
              ),
            ),
          ),
        ),
        IconButton(
          icon: Icon(Icons.image),
          onPressed: () => _captureAndShareImage(context),
          tooltip: 'Exportar como imagem',
        ),
      ],
    );
  }

  Future<void> _captureAndShareImage(BuildContext context) async {
    RenderRepaintBoundary? boundary =
        _globalKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;

    if (boundary != null) {
      ui.Image image = await boundary.toImage(pixelRatio: 5.0);
      ByteData? byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData != null) {
        Uint8List pngBytes = byteData.buffer.asUint8List();

        if (Platform.isAndroid || Platform.isIOS) {
          final directory = (await getTemporaryDirectory()).path;
          final imagePath = '$directory/captured_image.png';
          final imageFile = File(imagePath);
          await imageFile.writeAsBytes(pngBytes);

          await Share.shareXFiles([XFile(imagePath)],
              text: 'Compartilhando imagem capturada.');
        } else if (Platform.isLinux || Platform.isWindows || Platform.isMacOS) {
          FileSaveLocation? saveLocation = await getSaveLocation(
            acceptedTypeGroups: [
              XTypeGroup(label: 'images', extensions: ['png'])
            ],
            suggestedName: 'captured_image.png',
            confirmButtonText: 'Salvar',
          );

          if (saveLocation != null) {
            final String? outputPath = saveLocation.path;
            if (outputPath != null) {
              final File imageFile = File(outputPath);
              await imageFile.writeAsBytes(pngBytes);
              ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Gráfico salvo: $outputPath")));
            } else {
              print("Falha ao obter o caminho do arquivo.");
            }
          } else {
            print("Usuário cancelou ou falhou ao salvar o arquivo.");
          }
        }
      } else {
        print("Falha ao obter dados de imagem.");
      }
    } else {
      print("Falha ao obter RenderRepaintBoundary.");
    }
  }

  double _calculateInterval(double minY, double maxY) {
    double range = maxY - minY;
    if (range <= 1) return 0.1;
    if (range <= 10) return 1;
    if (range <= 50) return 5;
    if (range <= 100) return 10;
    return (range / 5).roundToDouble(); // Ajuste dinâmico mais espaçado
  }

String _formatYAxisLabel(double value) {
  if (value.abs() > 1000) {
    return '${(value / 1000).toStringAsFixed(1)}k'; // Exemplo: 12000 → 12k
  }
  return value.toStringAsFixed(2).replaceAll(RegExp(r'\.?0*$'), ''); // Remove zeros desnecessários
}
}
