import 'package:flutter/material.dart';
import 'package:skin_type_app/constants/profile_colors.dart';

// 1. PROFIL RESMİ WIDGET'I
class ProfileImageWidget extends StatelessWidget {
  const ProfileImageWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Stack(
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: const CircleAvatar(
              radius: 50,
              backgroundImage: NetworkImage("https://i.pravatar.cc/300?img=5"),
            ),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: ProfileColors.primaryGreen,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 3),
              ),
              child: const Icon(
                Icons.camera_alt,
                color: Colors.white,
                size: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// 2. SADECE OKUNABİLİR ALAN (İsim, Doğum Tarihi vb.)
class ReadOnlyField extends StatelessWidget {
  final String label;
  final String value;
  final IconData? icon;

  const ReadOnlyField({
    super.key,
    required this.label,
    required this.value,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      decoration: BoxDecoration(
        color: ProfileColors.cardWhite,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: ProfileColors.textLight,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 5),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                value,
                style: const TextStyle(
                  color: ProfileColors.textDark,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              if (icon != null)
                Icon(icon, color: ProfileColors.primaryGreen, size: 20),
            ],
          ),
        ],
      ),
    );
  }
}

// 3. SEÇİLEBİLİR BUTON (Cinsiyet Seçimi İçin)
class SelectableButton extends StatelessWidget {
  final String text;
  final bool isSelected;
  final VoidCallback onTap;

  const SelectableButton({
    super.key,
    required this.text,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: ProfileColors.cardWhite,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? ProfileColors.primaryGreen
                : ProfileColors.borderGrey,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Center(
          child: Text(
            text,
            style: TextStyle(
              color: isSelected ? ProfileColors.primaryGreen : Colors.grey,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }
}

// 4. CİLT TİPİ KARTI (İkonlu Seçim)
class SkinTypeCard extends StatelessWidget {
  final String text;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const SkinTypeCard({
    super.key,
    required this.text,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
        decoration: BoxDecoration(
          color: ProfileColors.cardWhite,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? ProfileColors.primaryGreen
                : ProfileColors.borderGrey,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected ? ProfileColors.primaryGreen : Colors.grey,
              size: 20,
            ),
            const SizedBox(width: 10),
            Text(
              text,
              style: TextStyle(
                color: isSelected
                    ? ProfileColors.primaryGreen
                    : Colors.grey[700],
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// 5. ÖZEL CHECKBOX ELEMANI
class CustomCheckboxItem extends StatelessWidget {
  final String label;
  final bool isChecked;
  final VoidCallback onTap;

  const CustomCheckboxItem({
    super.key,
    required this.label,
    required this.isChecked,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 15.0),
        child: Row(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: isChecked
                    ? ProfileColors.primaryGreen
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: isChecked
                      ? ProfileColors.primaryGreen
                      : Colors.grey.shade400,
                ),
              ),
              child: isChecked
                  ? const Icon(Icons.check, size: 16, color: Colors.white)
                  : null,
            ),
            const SizedBox(width: 12),
            Text(
              label,
              style: const TextStyle(
                color: ProfileColors.textDark,
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// 6. BİLGİ KUTUSU (En alttaki gri kutu)
class InfoBoxWidget extends StatelessWidget {
  const InfoBoxWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color(0xFFE8ECE9),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline, color: ProfileColors.primaryGreen),
          const SizedBox(width: 15),
          Expanded(
            child: Text(
              "Your personal information helps us create a customized skincare routine tailored to your unique needs. All data is encrypted and never shared.",
              style: TextStyle(
                color: Colors.grey[700],
                fontSize: 12,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
