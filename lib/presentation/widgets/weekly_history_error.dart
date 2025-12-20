import 'package:flutter/material.dart';

class WeeklyHistoryError extends StatelessWidget {
  final VoidCallback onRetry;
  final String? errorMessage;

  const WeeklyHistoryError({
    super.key,
    required this.onRetry,
    this.errorMessage,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 300, // Samakan tingginya dengan chart container normal
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1F2E), // Warna Card Dashboard
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Visual Icon Stack
          Stack(
            alignment: Alignment.bottomRight,
            children: [
              Icon(
                Icons.bar_chart_rounded,
                size: 64,
                color: Colors.white.withOpacity(0.1),
              ),
              Container(
                decoration: const BoxDecoration(
                  color: Color(0xFF1A1F2E),
                  shape: BoxShape.circle,
                ),
                padding: const EdgeInsets.all(4),
                child: const Icon(
                  Icons.warning_amber_rounded,
                  size: 24,
                  color: Colors.orangeAccent,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Main Message
          const Text(
            "Gagal Memuat Data Grafik",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          
          // Sub Message (Error detail - opsional, dikecilkan)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              "Terjadi gangguan koneksi saat mengambil data history mingguan.",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withOpacity(0.5),
                fontSize: 12,
              ),
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Retry Button
          SizedBox(
            height: 40,
            child: ElevatedButton.icon(
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2ECC71).withOpacity(0.15),
                foregroundColor: const Color(0xFF2ECC71),
                elevation: 0,
                side: BorderSide(color: const Color(0xFF2ECC71).withOpacity(0.5)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 24),
              ),
              icon: const Icon(Icons.refresh, size: 18),
              label: const Text("Coba Lagi", style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          )
        ],
      ),
    );
  }
}