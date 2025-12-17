import 'dart:io';
import 'package:flutter/material.dart';
import 'package:skin_type_app/core/services/scan_service.dart';
import 'package:skin_type_app/features/scan details/views/screens/scan_detail_screen.dart';
import 'package:skin_type_app/models/scan_model.dart';

class ScanHistoryScreen extends StatelessWidget {
  const ScanHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ScanService _scanService = ScanService();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: Column(
        children: [
          // 1. Header
          Container(
            padding: const EdgeInsets.only(
              top: 50,
              bottom: 20,
              left: 16,
              right: 16,
            ),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF6B7C97), Color(0xFF8697B0)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
                const SizedBox(width: 10),
                const Text(
                  "Scan History",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          // 2. Dinamik Liste (StreamBuilder)
          Expanded(
            child: StreamBuilder<List<ScanResult>>(
              stream: _scanService.getScans(),
              builder: (context, snapshot) {
                // Hata Durumu
                if (snapshot.hasError) {
                  return Center(
                    child: Text("Bir hata oluştu: ${snapshot.error}"),
                  );
                }

                // Yükleniyor Durumu
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(color: Color(0xFF6B7C97)),
                  );
                }

                final historyData = snapshot.data ?? [];

                // Veri Yoksa
                if (historyData.isEmpty) {
                  return const Center(
                    child: Text(
                      "Henüz hiç tarama yapılmamış.",
                      style: TextStyle(color: Colors.grey, fontSize: 16),
                    ),
                  );
                }

                // Liste Varsa
                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: historyData.length,
                  itemBuilder: (context, index) {
                    final scan = historyData[index];
                    return _buildHistoryCard(context, scan);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryCard(BuildContext context, ScanResult scan) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ScanDetailScreen(scanResult: scan),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // --- GÜNCELLENEN KISIM BAŞLANGIÇ ---
            // Resim Alanı
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: 60,
                height: 60,
                color: const Color(0xFFF0F4F8), // Resim yoksa arka plan rengi
                child: (scan.imagePath != null && scan.imagePath!.isNotEmpty)
                    ? Image.file(
                        File(scan.imagePath!), // Telefon hafızasından okur
                        fit: BoxFit.cover,
                        // Eğer dosya silinmişse veya hata verirse ikon göster:
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(
                            Icons.broken_image_outlined,
                            color: Colors.grey,
                          );
                        },
                      )
                    : const Icon(
                        Icons.camera_alt_outlined,
                        color: Color(0xFF6B7C97),
                        size: 28,
                      ),
              ),
            ),

            // --- GÜNCELLENEN KISIM BİTİŞ ---
            const SizedBox(width: 16),

            // Bilgiler
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    scan.ciltTipi,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2D3142),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    scan.date,
                    style: const TextStyle(color: Colors.grey, fontSize: 13),
                  ),
                  const SizedBox(height: 8),

                  // Yüzde Chip
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE3F2FD),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      "Match: ${scan.benzerlikYuzdesi}",
                      style: const TextStyle(
                        color: Color(0xFF1565C0),
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}
