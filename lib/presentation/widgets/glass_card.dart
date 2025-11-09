import 'dart:ui';
import 'package:flutter/material.dart';

class GlassCard extends StatelessWidget {
  final Widget child;
  const GlassCard({required this.child, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.10),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.white.withOpacity(0.2),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}

class SensorCombinedCard extends StatelessWidget {
  final double? previousTemp;
  final double? currentTemp;
  final double? forecastTemp;
  final double? previousHum;
  final double? currentHum;
  final double? forecastHum;
  const SensorCombinedCard({
    this.previousTemp,
    this.currentTemp,
    this.forecastTemp,
    this.previousHum,
    this.currentHum,
    this.forecastHum,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.10),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Kolom Suhu
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Suhu',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    SensorVerticalValue(
                      previous: previousTemp,
                      current: currentTemp,
                      // forecast: forecastTemp,
                      unit: '°C',
                    ),
                  ],
                ),
              ),
              Container(
                width: 1,
                height: 100,
                color: Colors.white.withOpacity(0.2),
              ),
              // Kolom Kelembapan
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Kelembapan',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    SensorVerticalValue(
                      previous: previousHum,
                      current: currentHum,
                      forecast: forecastHum,
                      unit: '%',
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SensorVerticalValue extends StatelessWidget {
  final double? previous;
  final double? current;
  final double? forecast;
  final String unit;
  const SensorVerticalValue({
    this.previous,
    this.current,
    this.forecast,
    required this.unit,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String _getStatus(double? value) {
      if (value == null) return '-';
      if (unit == '°C') {
        if (value >= 28.0) return 'Terlalu Panas';
        if (value <= 26.0) return 'Normal';
        if (value <= 20.0) return 'Terlalu Dingin';
        return 'Normal';
      } else {
        // treat as humidity
        if (value >= 80.0) return 'Terlalu Lembap';
        if (value <= 50.0) return 'Terlalu Kering';
        return 'Normal';
      }
    }

    Color _statusColorFromLabel(String label) {
      switch (label) {
        case 'Terlalu Panas':
          return Colors.redAccent.shade100;
        case 'Terlalu Dingin':
          return Colors.blueAccent.shade100;
        case 'Normal':
          return const Color.fromARGB(255, 128, 255, 160);
        case 'Terlalu Lembap':
          return Colors.greenAccent.shade100;
        case 'Terlalu Kering':
          return Colors.orangeAccent.shade100;
        default:
          return Colors.transparent;
      }
    }

    Color _textColorForBg(Color bgColor) {
      return bgColor.computeLuminance() > 0.5 ? Colors.black : Colors.white;
    }

    final statusLabel = _getStatus(current);
    final bg = _statusColorFromLabel(statusLabel);

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Previous (atas)
        // Text(
        //   previous != null ? previous!.toStringAsFixed(1) : '-',
        //   style: TextStyle(
        //     fontSize: 20,
        //     color: Colors.grey.shade500,
        //     fontWeight: FontWeight.w500,
        //     fontFamily: 'Courier',
        //   ),
        // ),
        // Current (tengah, besar)
        // Row(
        //   mainAxisAlignment: MainAxisAlignment.center,
        //   crossAxisAlignment: CrossAxisAlignment.end,
        //   children: [
        //     Text(
        //       current != null ? current!.toStringAsFixed(1) : '-',
        //       style: const TextStyle(
        //         fontSize: 44,
        //         fontWeight: FontWeight.bold,
        //         color: Colors.white,
        //         fontFamily: 'Courier',
        //       ),
        //     ),
        //     Padding(
        //       padding: const EdgeInsets.only(left: 4, bottom: 4),
        //       child: Text(
        //         unit,
        //         style: const TextStyle(
        //           fontSize: 20,
        //           color: Colors.white70,
        //           fontWeight: FontWeight.bold,
        //         ),
        //       ),
        //     ),
        //   ],
        // ),
        // Forecast (bawah)

        Container(
          margin: const EdgeInsets.only(top: 4),
          child: current != null
              ? Column(
                  children: [
                    Text(
                      '${current != null ? current!.toStringAsFixed(1) : '-'} $unit',
                      style: const TextStyle(
                        fontSize: 30,
                        color: Color.fromARGB(255, 255, 255, 255),
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: bg,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        statusLabel,
                        style: TextStyle(
                          fontSize: 12,
                          color: _textColorForBg(bg),
                        ),
                      ),
                    ),
                  ],
                )
              : Text(
                  '-',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade400,
                    fontWeight: FontWeight.w400,
                  ),
                ),
        ),

        
        // Text(
        //   forecast != null ? forecast!.toStringAsFixed(1) : '-',
        //   style: TextStyle(
        //     fontSize: 20,
        //     color: Colors.grey.shade500,
        //     fontWeight: FontWeight.w500,
        //     fontFamily: 'Courier',
        //   ),
        // ),
      ],
    );
  }
}
