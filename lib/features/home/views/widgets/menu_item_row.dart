import 'package:flutter/material.dart';

class MenuItemRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const MenuItemRow({super.key, required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        children: [
          CircleAvatar(backgroundColor: Colors.grey[200], child: Icon(icon, color: Colors.black54, size: 20)),
          const SizedBox(width: 15),
          Text(text, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}