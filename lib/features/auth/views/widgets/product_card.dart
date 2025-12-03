import 'package:flutter/material.dart';
import '../../../../constants/app_colors.dart'; // Renkleri buradan çekeceğiz

class ProductCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String tagText;
  final Color tagColor;
  final String desc;

  const ProductCard({
    super.key, 
    required this.title, 
    required this.subtitle, 
    required this.tagText, 
    required this.tagColor, 
    required this.desc
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 260,
      margin: const EdgeInsets.only(right: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              Container(
                height: 140,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: const BorderRadius.only(topLeft: Radius.circular(15), topRight: Radius.circular(15)),
                ),
                child: const Center(child: Icon(Icons.shopping_bag, size: 50, color: Colors.grey)),
              ),
              Positioned(
                top: 10, left: 10,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: tagColor, borderRadius: BorderRadius.circular(20)),
                  child: Row(children: [
                    const Icon(Icons.star, color: Colors.white, size: 10),
                    const SizedBox(width: 4),
                    Text(tagText, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold))
                  ]),
                ),
              )
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                Text(subtitle, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                const SizedBox(height: 10),
                Text(desc, maxLines: 3, overflow: TextOverflow.ellipsis, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                const SizedBox(height: 15),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: (){}, 
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.accentPurple),
                    child: const Text("Add to Routine", style: TextStyle(color: Colors.white)),
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}