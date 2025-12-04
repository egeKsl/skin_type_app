import 'package:flutter/material.dart';

class IngredientItemCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final Color iconColor; // İkonun arka plan rengi
  final List<String> tags;
  final List<Color> tagColors; // Etiketlerin arka plan renkleri
  final String riskLevel;
  final Color riskColor;

  const IngredientItemCard({
    super.key,
    required this.title,
    required this.description,
    required this.icon,
    required this.iconColor,
    required this.tags,
    required this.tagColors,
    required this.riskLevel,
    required this.riskColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.05),
            blurRadius: 10,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Sol İkon Kutusu
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: iconColor,
              borderRadius: BorderRadius.circular(15),
            ),
            child: Icon(icon, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 15),

          // Orta İçerik
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Başlık ve Kalp İkonu
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    CircleAvatar(
                      radius: 12,
                      backgroundColor: Colors.red.shade50,
                      child: const Icon(Icons.favorite, size: 14, color: Colors.redAccent),
                    ),
                  ],
                ),
                const SizedBox(height: 5),
                
                // Açıklama
                Text(
                  description,
                  style: TextStyle(color: Colors.grey[600], fontSize: 12, height: 1.3),
                ),
                const SizedBox(height: 10),

                // Etiketler (Tags)
                Wrap(
                  spacing: 8,
                  runSpacing: 5,
                  children: List.generate(tags.length, (index) {
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: index < tagColors.length ? tagColors[index] : Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        tags[index],
                        style: TextStyle(
                          fontSize: 10, 
                          fontWeight: FontWeight.bold,
                          color: (index < tagColors.length && tagColors[index] == Colors.blue) ? Colors.white : Colors.black54
                        ),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 10),

                // Risk Seviyesi
                Row(
                  children: [
                    Icon(Icons.circle, size: 8, color: riskColor),
                    const SizedBox(width: 5),
                    Text(
                      riskLevel,
                      style: TextStyle(
                        color: riskColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}