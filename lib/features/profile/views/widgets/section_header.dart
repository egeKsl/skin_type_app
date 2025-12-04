import 'package:flutter/material.dart';

class SectionHeader extends StatelessWidget {
  final String title;
  final EdgeInsetsGeometry padding;

  const SectionHeader({super.key, required this.title, this.padding = const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10)});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Row(
        children: [
          Container(width: 4, height: 20, color: const Color(0xFF6B7C97), margin: const EdgeInsets.only(right: 10)),
          Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}