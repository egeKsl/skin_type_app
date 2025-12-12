import 'package:flutter/material.dart';
import 'package:skin_type_app/constants/app_colors.dart';

class DaySelectorItem extends StatelessWidget {
  final String day;
  final bool isSelected;
  final bool hasDot;
  final Color dotColor;

  const DaySelectorItem({
    super.key,
    required this.day,
    required this.isSelected,
    this.hasDot = false,
    this.dotColor = Colors.green,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 60,
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        color: isSelected
            ? const Color(0xFFE1BEE7).withOpacity(0.3)
            : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: isSelected
            ? Border.all(color: AppColors.primaryPurple, width: 2)
            : Border.all(color: Colors.grey.shade100),
        boxShadow: [
          if (!isSelected)
            BoxShadow(
              color: Colors.grey.withOpacity(0.05),
              blurRadius: 5,
              spreadRadius: 1,
            ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            day,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isSelected ? AppColors.primaryPurple : Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          // DÜZELTME BURADA YAPILDI
          if (hasDot) // isSelected kontrolünü kaldırdım, nokta varsa rengini gösterelim
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                // ARTIK HESAPLANAN RENGİ KULLANIYORUZ:
                color: dotColor,
                shape: BoxShape.circle,
              ),
            ),
        ],
      ),
    );
  }
}
