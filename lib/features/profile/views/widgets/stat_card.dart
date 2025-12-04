import 'package:flutter/material.dart';

class StatCard extends StatelessWidget {
  final String value;
  final String label;

  const StatCard({super.key, required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 15),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F7FA), // Çok açık gri
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        children: [
          Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF6B7C97))),
          const SizedBox(height: 5),
          Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
        ],
      ),
    );
  }
}