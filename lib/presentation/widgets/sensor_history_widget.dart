import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:intl/intl.dart';
import '../blocs/sensor/sensor_bloc.dart';
import '../blocs/sensor/sensor_event.dart';
import '../blocs/sensor/sensor_state.dart';
import '../../data/repositories/sensor_repository.dart';
import '../../data/models/sensor_data_model.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import '../../core/providers/auth_provider.dart';

class SensorHistoryWidget extends StatefulWidget {
  const SensorHistoryWidget({super.key});

  @override
  State<SensorHistoryWidget> createState() => _SensorHistoryWidgetState();
}

class _SensorHistoryWidgetState extends State<SensorHistoryWidget>
    with SingleTickerProviderStateMixin {
  DateTime? _startDate;
  DateTime? _endDate;
  int? _limit = 100;
  String _filterMode = 'harian'; // 'harian' atau 'mingguan'
  late TabController _tabController;
  List<SensorDataModel> _data = [];
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _startDate = DateTime.now();
    _endDate = DateTime.now();
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final String startDateStr = DateFormat('yyyy-MM-dd').format(_startDate!);
      final String endDateStr = _filterMode == 'harian'
          ? startDateStr
          : DateFormat('yyyy-MM-dd').format(_endDate!);
      final params = {
        'start_date': startDateStr,
        'end_date': endDateStr,
        'limit': _limit ?? 100,
      };
      final token = Provider.of<AuthProvider>(context, listen: false).token;
      final response = await Dio().get(
        'http://10.0.2.2:3000/api/sensors',
        queryParameters: params,
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );
      final List<dynamic> data = response.data['data'];
      _data = data.map((json) => SensorDataModel.fromJson(json)).toList();
    } catch (e) {
      _error = e.toString();
    }
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _filterMode = 'harian';
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: _filterMode == 'harian' ? Colors.green : Colors.grey[200],
                foregroundColor: _filterMode == 'harian' ? Colors.white : Colors.black,
              ),
              child: const Text('Harian'),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _filterMode = 'mingguan';
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: _filterMode == 'mingguan' ? Colors.green : Colors.grey[200],
                foregroundColor: _filterMode == 'mingguan' ? Colors.white : Colors.black,
              ),
              child: const Text('Mingguan'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: TextButton.icon(
                icon: const Icon(Icons.calendar_today, size: 16),
                onPressed: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _startDate ?? DateTime.now(),
                    firstDate: DateTime(2020),
                    lastDate: DateTime.now(),
                  );
                  if (picked != null) setState(() => _startDate = picked);
                },
                label: Text(_startDate == null
                    ? 'Tanggal'
                    : DateFormat('dd/MM/yyyy').format(_startDate!)),
              ),
            ),
            if (_filterMode == 'mingguan')
              Expanded(
                child: TextButton.icon(
                  icon: const Icon(Icons.calendar_today, size: 16),
                  onPressed: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: _endDate ?? DateTime.now(),
                      firstDate: DateTime(2020),
                      lastDate: DateTime.now(),
                    );
                    if (picked != null) setState(() => _endDate = picked);
                  },
                  label: Text(_endDate == null
                      ? 'Akhir'
                      : DateFormat('dd/MM/yyyy').format(_endDate!)),
                ),
              ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: ElevatedButton.icon(
            icon: const Icon(Icons.search),
            label: const Text('Terapkan Filter'),
            onPressed: _fetchData,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 40),
            ),
          ),
        ),
        const SizedBox(height: 8),
        TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.show_chart), text: 'Grafik'),
            Tab(icon: Icon(Icons.list), text: 'Daftar'),
          ],
          labelColor: Colors.green,
          unselectedLabelColor: Colors.grey,
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              // Chart View (bisa gunakan _data)
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _error != null
                      ? Center(child: Text('Error: $_error'))
                      : _data.isEmpty
                          ? const Center(child: Text('Tidak ada data.'))
                          : Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                children: [
                                  SizedBox(
                                    height: 220,
                                    child: LineChart(
                                      LineChartData(
                                        gridData: FlGridData(show: true),
                                        titlesData: FlTitlesData(
                                          bottomTitles: AxisTitles(
                                            sideTitles: SideTitles(
                                              showTitles: true,
                                              getTitlesWidget: (value, meta) {
                                                final idx = value.toInt();
                                                if (idx >= 0 && idx < _data.length) {
                                                  final dt = _data[idx].recordedAt;
                                                  return Text(
                                                    DateFormat('HH:mm').format(dt),
                                                    style: const TextStyle(fontSize: 10),
                                                  );
                                                }
                                                return const SizedBox();
                                              },
                                              interval: (_data.length / 4).ceilToDouble(),
                                            ),
                                          ),
                                          leftTitles: AxisTitles(
                                            sideTitles: SideTitles(showTitles: true),
                                          ),
                                          rightTitles: AxisTitles(
                                            sideTitles: SideTitles(showTitles: false),
                                          ),
                                          topTitles: AxisTitles(
                                            sideTitles: SideTitles(showTitles: false),
                                          ),
                                        ),
                                        borderData: FlBorderData(show: true),
                                        lineBarsData: [
                                          LineChartBarData(
                                            spots: [
                                              for (int i = 0; i < _data.length; i++)
                                                FlSpot(i.toDouble(), _data[i].temperature),
                                            ],
                                            isCurved: true,
                                            color: Colors.red,
                                            barWidth: 3,
                                            isStrokeCapRound: true,
                                            dotData: FlDotData(show: false),
                                            belowBarData: BarAreaData(show: false),
                                          ),
                                          LineChartBarData(
                                            spots: [
                                              for (int i = 0; i < _data.length; i++)
                                                FlSpot(i.toDouble(), _data[i].humidity),
                                            ],
                                            isCurved: true,
                                            color: Colors.blue,
                                            barWidth: 3,
                                            isStrokeCapRound: true,
                                            dotData: FlDotData(show: false),
                                            belowBarData: BarAreaData(show: false),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Row(
                                        children: [
                                          Container(width: 12, height: 12, color: Colors.red),
                                          const SizedBox(width: 4),
                                          const Text('Suhu (°C)'),
                                        ],
                                      ),
                                      const SizedBox(width: 16),
                                      Row(
                                        children: [
                                          Container(width: 12, height: 12, color: Colors.blue),
                                          const SizedBox(width: 4),
                                          const Text('Kelembapan (%)'),
                                        ],
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
              // List View
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _error != null
                      ? Center(child: Text('Error: $_error'))
                      : _data.isEmpty
                          ? const Center(child: Text('Tidak ada data.'))
                          : ListView.builder(
                              itemCount: _data.length,
                              itemBuilder: (context, i) {
                                final d = _data[i];
                                return ListTile(
                                  title: Text('Suhu: ${d.temperature}, Humidity: ${d.humidity}'),
                                  subtitle: Text('Waktu: ${d.recordedAt}'),
                                );
                              },
                            ),
            ],
          ),
        ),
      ],
    );
  }
}
