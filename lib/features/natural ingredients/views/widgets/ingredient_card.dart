import 'package:flutter/material.dart';
import 'package:skin_type_app/constants/app_colors.dart';

class IngredientCard extends StatelessWidget {
  final String title;
  final List<String> benefits; // Dinamik maddeler
  final String usage; // Dinamik kullanım talimatı
  final String aiAnalysis; // Dinamik AI analizi
  final String matchPercentage;

  const IngredientCard({
    super.key,
    required this.title,
    required this.benefits,
    required this.usage,
    required this.aiAnalysis,
    required this.matchPercentage,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 320, // İçerik arttığı için genişlik biraz artırıldı
      margin: const EdgeInsets.only(right: 16, bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Başlık ve Etiket
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.matchGreen,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Text(
                        "Perfect Match",
                        style: TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 15),

                // 2. Key Benefits (Maddeler - Yapay Zekadan Gelen)
                const Text(
                  "Key Benefits",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 5),
                // Gelen listeyi döngü ile render ediyoruz
                ...benefits
                    .map((benefit) => _buildBulletPoint(benefit))
                    .toList(),

                const SizedBox(height: 15),

                // 3. How to Use (Yapay Zekadan Gelen)
                const Text(
                  "How to Use",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 5),
                Text(
                  usage,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 15),

                // 4. AI Analysis Kutusu (Yapay Zekadan Gelen)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.cyan.shade50,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "“ $aiAnalysis ”",
                        style: const TextStyle(
                          fontSize: 12,
                          fontStyle: FontStyle.italic,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 5),
                      const Text(
                        "- AI Analysis",
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.cyan,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 15),

                // 5. Match Bar
                Row(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: LinearProgressIndicator(
                          value:
                              0.95, // Statik veya analiz sonucuna göre set edilebilir
                          backgroundColor: Colors.grey[200],
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            Color(0xFF7B61FF),
                          ),
                          minHeight: 8,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      matchPercentage,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBulletPoint(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          const Icon(Icons.circle, size: 6, color: Colors.cyan),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(color: Colors.grey[700], fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}
