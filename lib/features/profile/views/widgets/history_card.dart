import 'package:flutter/material.dart';

class HistoryCard extends StatelessWidget {
  final String title;
  final String date;
  final String score;
  final String status;
  final Color statusColor;

  const HistoryCard({
    super.key, 
    required this.title, 
    required this.date, 
    required this.score, 
    required this.status, 
    required this.statusColor
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.05), blurRadius: 5, spreadRadius: 1)],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: const Color(0xFFF5F7FA), borderRadius: BorderRadius.circular(10)),
            child: const Icon(Icons.camera_alt, color: Colors.grey),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                Text(date, style: const TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
              const SizedBox(height: 8),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(color: const Color(0xFFD1E9F6), borderRadius: BorderRadius.circular(8)),
                    child: Text("Score: $score", style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF6B7C97))),
                  ),
                  const SizedBox(width: 5),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(8)),
                    child: Text(status, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey)),
                  ),
                ],
              )
            ],
          )
        ],
      ),
    );
  }
}