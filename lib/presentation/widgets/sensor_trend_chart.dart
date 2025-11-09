import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../domain/models/sensor_trend.dart';
import 'package:intl/intl.dart';

class SensorTrendChart extends StatelessWidget {
  final List<SensorTrend> temperatureData;
  final List<SensorTrend> humidityData;
  final bool isWeekly;

  const SensorTrendChart({super.key, required this.temperatureData, required this.humidityData, this.isWeekly = true});

  @override
  Widget build(BuildContext context) {
    if (temperatureData.isEmpty && humidityData.isEmpty) {
      return const Center(child: Text('Tidak ada data grafik'));
    }

    final spotsTemp = temperatureData.asMap().entries.map((e) =>
      FlSpot(e.key.toDouble(), e.value.avg)).toList();
    final spotsHum = humidityData.asMap().entries.map((e) =>
      FlSpot(e.key.toDouble(), e.value.avg)).toList();

    final dataLength = temperatureData.length > humidityData.length ? temperatureData.length : humidityData.length;
    final dateFormat = isWeekly ? DateFormat('d/M') : DateFormat('d/M');

    double? minTemp = temperatureData.isNotEmpty ? temperatureData.map((e) => e.avg).reduce((a, b) => a < b ? a : b) : null;
    double? maxTemp = temperatureData.isNotEmpty ? temperatureData.map((e) => e.avg).reduce((a, b) => a > b ? a : b) : null;
    double? avgTemp = temperatureData.isNotEmpty ? (temperatureData.map((e) => e.avg).reduce((a, b) => a + b) / temperatureData.length) : null;
    double? minHum = humidityData.isNotEmpty ? humidityData.map((e) => e.avg).reduce((a, b) => a < b ? a : b) : null;
    double? maxHum = humidityData.isNotEmpty ? humidityData.map((e) => e.avg).reduce((a, b) => a > b ? a : b) : null;
    double? avgHum = humidityData.isNotEmpty ? (humidityData.map((e) => e.avg).reduce((a, b) => a + b) / humidityData.length) : null;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _Legend(color: Colors.red, label: 'Suhu (°C)'),
                const SizedBox(width: 16),
                _Legend(color: Colors.blue, label: 'Kelembapan (%)'),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 250,
              child: LineChart(
                LineChartData(
                  backgroundColor: Colors.transparent,
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: true, reservedSize: 40),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          final idx = value.toInt();
                          if (idx < 0 || idx >= dataLength) return const SizedBox();
                          final dt = (temperatureData.length > idx ? temperatureData[idx].date : humidityData[idx].date);
                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(dateFormat.format(dt), style: const TextStyle(fontSize: 11)),
                          );
                        },
                        reservedSize: 32,
                        interval: (dataLength / 6).ceilToDouble(),
                      ),
                    ),
                  ),
                  lineBarsData: [
                    if (spotsTemp.isNotEmpty)
                      LineChartBarData(
                        spots: spotsTemp,
                        isCurved: true,
                        color: Colors.red,
                        barWidth: 2,
                        dotData: FlDotData(show: false),
                        belowBarData: BarAreaData(show: false),
                      ),
                    if (spotsHum.isNotEmpty)
                      LineChartBarData(
                        spots: spotsHum,
                        isCurved: true,
                        color: Colors.blue,
                        barWidth: 2,
                        dotData: FlDotData(show: false),
                        belowBarData: BarAreaData(show: false),
                      ),
                  ],
                  minY: 0,
                  gridData: FlGridData(show: true),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Column(
                  children: [
                    const Text('Suhu (°C)', style: TextStyle(fontWeight: FontWeight.bold)),
                    Text('Min: ${minTemp?.toStringAsFixed(1) ?? '-'}'),
                    Text('Max: ${maxTemp?.toStringAsFixed(1) ?? '-'}'),
                    Text('Avg: ${avgTemp?.toStringAsFixed(1) ?? '-'}'),
                  ],
                ),
                Column(
                  children: [
                    const Text('Kelembapan (%)', style: TextStyle(fontWeight: FontWeight.bold)),
                    Text('Min: ${minHum?.toStringAsFixed(1) ?? '-'}'),
                    Text('Max: ${maxHum?.toStringAsFixed(1) ?? '-'}'),
                    Text('Avg: ${avgHum?.toStringAsFixed(1) ?? '-'}'),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  final Color color;
  final String label;
  const _Legend({required this.color, required this.label});
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(width: 16, height: 6, color: color, margin: const EdgeInsets.only(right: 6)),
        Text(label, style: const TextStyle(fontSize: 13)),
      ],
    );
  }
} 