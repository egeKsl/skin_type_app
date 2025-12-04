import 'package:flutter/material.dart';

class RoutineStepTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final bool isCompleted;

  const RoutineStepTile({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    this.isCompleted = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Row(
        children: [
          // İkon Kutusu
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconColor,
              borderRadius: BorderRadius.circular(15),
            ),
            child: Icon(icon, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 15),
          
          // Yazılar
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Text(
                  subtitle,
                  style: TextStyle(color: Colors.grey[500], fontSize: 13),
                ),
              ],
            ),
          ),

          // Checkbox / Durum İkonu
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: isCompleted ? Colors.green.shade400 : Colors.grey.shade200,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.check,
              size: 16,
              color: isCompleted ? Colors.white : Colors.grey.shade400,
            ),
          )
        ],
      ),
    );
  }
}