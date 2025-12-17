import 'package:flutter/material.dart';
import 'package:skin_type_app/models/scan_model.dart';

class ScanDetailScreen extends StatelessWidget {
  final ScanResult scanResult;

  const ScanDetailScreen({super.key, required this.scanResult});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFF6B7C97),
        elevation: 0,
        leading: const BackButton(color: Colors.white),
        title: const Text(
          "Analysis Results",
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. ÖZET KARTI (Cilt Tipi ve Yüzde)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF6B7C97), Color(0xFF8697B0)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF6B7C97).withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                children: [
                  const Icon(Icons.face, color: Colors.white, size: 40),
                  const SizedBox(height: 10),
                  Text(
                    scanResult.ciltTipi,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 5),
                  Text(
                    "Güven Oranı: ${scanResult.benzerlikYuzdesi}",
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // 2. BELİRTİLER VE İHTİYAÇLAR (Yan Yana)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _buildInfoCard(
                    title: "Belirtiler",
                    items: scanResult.belirtiler,
                    icon: Icons.search,
                    color: Colors.orange.shade100,
                    textColor: Colors.orange.shade900,
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: _buildInfoCard(
                    title: "İhtiyaçlar",
                    items: scanResult.ihtiyaclar,
                    icon: Icons.water_drop,
                    color: Colors.blue.shade100,
                    textColor: Colors.blue.shade900,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // 3. İÇERİK ANALİZİ (Doğal vs Kimyasal)
            _buildSectionHeader("İçerik Analizi"),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.05),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: Column(
                children: [
                  _buildIngredientRow(
                    "Doğal İçerikler",
                    scanResult.dogalIcerikler,
                    Icons.eco,
                    Colors.green,
                  ),
                  const Divider(height: 30),
                  _buildIngredientRow(
                    "Aktif İçerikler",
                    scanResult.kimyasalIcerikler,
                    Icons.science,
                    Colors.purple,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // 4. MAKYAJ TAVSİYELERİ
            _buildSectionHeader("Makyaj Rehberi"),
            const SizedBox(height: 10),
            _buildMakeupCard(
              "Kullanılması Gerekenler",
              scanResult.makyajOnerileri,
              Icons.check_circle_outline,
              Colors.green,
            ),
            const SizedBox(height: 10),
            _buildMakeupCard(
              "Uzak Durulması Gerekenler",
              scanResult.makyajUzakDurulacaklar,
              Icons.cancel_outlined,
              Colors.red,
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  // --- YARDIMCI WIDGET'LAR ---

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Color(0xFF2D3142),
      ),
    );
  }

  Widget _buildInfoCard({
    required String title,
    required List<String> items,
    required IconData icon,
    required Color color,
    required Color textColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.grey.withOpacity(0.05), blurRadius: 5),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 12,
                backgroundColor: color,
                child: Icon(icon, size: 14, color: textColor),
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(fontWeight: FontWeight.bold, color: textColor),
              ),
            ],
          ),
          const SizedBox(height: 10),
          if (items.isEmpty)
            const Text("-", style: TextStyle(fontSize: 12))
          else
            ...items.map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  "• $item",
                  style: const TextStyle(fontSize: 12, color: Colors.black87),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildIngredientRow(
    String title,
    List<String> items,
    IconData icon,
    Color color,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: items
              .map(
                (item) => Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: color.withOpacity(0.3)),
                  ),
                  child: Text(
                    item,
                    style: TextStyle(
                      color: color,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              )
              .toList(),
        ),
      ],
    );
  }

  Widget _buildMakeupCard(
    String title,
    List<String> items,
    IconData icon,
    Color color,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color),
              const SizedBox(width: 10),
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: color,
                  fontSize: 15,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ...items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "• ",
                    style: TextStyle(color: color, fontWeight: FontWeight.bold),
                  ),
                  Expanded(
                    child: Text(
                      item,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
