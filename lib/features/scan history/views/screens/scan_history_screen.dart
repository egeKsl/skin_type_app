import 'package:flutter/material.dart';
import 'package:skin_type_app/features/scan details/views/screens/scan_detail_screen.dart'; // Detay ekranını import et
import 'package:skin_type_app/models/scan_model.dart';

class ScanHistoryScreen extends StatelessWidget {
  const ScanHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Örnek (Mock) Veriler - Normalde veritabanından gelecek
    final List<ScanResult> historyData = [
      ScanResult(
        date: "Today, 14:30",
        ciltTipi: "KARMA CİLT",
        benzerlikYuzdesi: "%87",
        belirtiler: [
          "T bölgesinde yağlanma",
          "Yanaklarda kuruluk",
          "Hafif gözenek belirginliği",
        ],
        ihtiyaclar: ["Dengeleyici nemlendirici", "Salisilik asit temizleyici"],
        dogalIcerikler: ["Yeşil Çay", "Aloe Vera"],
        kimyasalIcerikler: ["Niacinamide", "Hyaluronic Acid"],
        makyajOnerileri: ["Su bazlı fondöten", "Mineral pudra"],
        makyajUzakDurulacaklar: ["Ağır yağ bazlı ürünler"],
      ),
      ScanResult(
        date: "Yesterday",
        ciltTipi: "YAĞLI / AKNEYE EĞİLİMLİ CİLT",
        benzerlikYuzdesi: "%92",
        belirtiler: ["Aktif akne", "Parlama"],
        ihtiyaclar: [],
        dogalIcerikler: [],
        kimyasalIcerikler: [],
        makyajOnerileri: [],
        makyajUzakDurulacaklar: [],
      ),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA), // Açık gri/mavi arka plan
      body: Column(
        children: [
          // 1. Header (Profil ekranına benzer Mavi-Gri Gradient)
          Container(
            padding: const EdgeInsets.only(
              top: 50,
              bottom: 20,
              left: 16,
              right: 16,
            ),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF6B7C97),
                  Color(0xFF8697B0),
                ], // Mavi-Gri tonları
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

          // 2. Liste
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: historyData.length,
              itemBuilder: (context, index) {
                final scan = historyData[index];
                return _buildHistoryCard(context, scan);
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
        // Detay Ekranına Git
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
            // Kamera İkonu (Kare Kutu İçinde)
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: const Color(0xFFF0F4F8), // Çok açık mavi gri
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.camera_alt_outlined,
                color: Color(0xFF6B7C97),
                size: 28,
              ),
            ),
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

                  // Score / Yüzde Chip
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE3F2FD), // Açık Mavi
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

            // Sağ Ok
            const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}
