import 'package:flutter/material.dart';

class TipsCard extends StatelessWidget {
  const TipsCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Personalized Tips",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 15),
          _buildTipItem(Icons.lightbulb, Colors.pink.shade100, "Avoid exfoliating more than 2 times a week to prevent skin irritation"),
          const SizedBox(height: 15),
          _buildTipItem(Icons.water_drop, Colors.blue.shade100, "Increase hydration on colder days to maintain skin moisture barrier"),
          const SizedBox(height: 15),
          _buildTipItem(Icons.nightlight_round, Colors.purple.shade100, "Apply retinol only at night and always follow with moisturizer"),
        ],
      ),
    );
  }

  Widget _buildTipItem(IconData icon, Color color, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          radius: 12,
          backgroundColor: color,
          child: Icon(icon, size: 14, color: Colors.white),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: TextStyle(color: Colors.grey[600], fontSize: 13, height: 1.4),
          ),
        ),
      ],
    );
  }
}