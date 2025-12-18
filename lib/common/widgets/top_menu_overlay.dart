import 'package:flutter/material.dart';
import 'package:skin_type_app/constants/app_colors.dart';
import 'package:skin_type_app/features/home/views/widgets/menu_item_row.dart';
import 'package:skin_type_app/features/home/views/screens/home_screen.dart';
import 'package:skin_type_app/features/profile/views/screens/profile_screen.dart';
import 'package:skin_type_app/features/Weekly Routine/views/screens/weekly_routine_screen.dart';
import 'package:skin_type_app/features/natural ingredients/views/screens/natural_ingredients_screen.dart';
import 'package:skin_type_app/features/favorite ingredients/views/screens/favorite_ingredients_screen.dart';
import 'package:skin_type_app/features/chemical ingredients/views/screens/chemical_ingredients_screen.dart';
import 'package:skin_type_app/features/help/views/screens/help_screen.dart';

/// Shows the shared top menu as a dialog sliding from the top.
Future<void> showTopMenuOverlay(BuildContext context) {
  return showDialog<void>(
    context: context,
    barrierColor: Colors.black54,
    builder: (dialogContext) {
      return Align(
        alignment: Alignment.topCenter,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.only(top: 0),
            child: _TopMenuOverlayContent(
              onClose: () {
                Navigator.of(dialogContext).pop();
              },
            ),
          ),
        ),
      );
    },
  );
}

class _TopMenuOverlayContent extends StatelessWidget {
  final VoidCallback onClose;

  const _TopMenuOverlayContent({required this.onClose});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        padding: const EdgeInsets.only(
          top: 20,
          bottom: 20,
          left: 20,
          right: 20,
        ),
        decoration: const BoxDecoration(
          color: AppColors.darkMenu,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
            bottomLeft: Radius.circular(30),
            bottomRight: Radius.circular(30),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Menu',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  onPressed: onClose,
                  icon: const Icon(
                    Icons.keyboard_arrow_up,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            MenuItemRow(
              icon: Icons.home,
              text: "Home",
              onTap: () {
                onClose();
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const HomeScreen()),
                  (route) => false,
                );
              },
            ),
            const SizedBox(height: 10),
            MenuItemRow(
              icon: Icons.person_outline,
              text: "Profile",
              onTap: () {
                onClose();
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const ProfileScreen(),
                  ),
                );
              },
            ),
            const SizedBox(height: 10),
            MenuItemRow(
              icon: Icons.calendar_today,
              text: "Routine",
              onTap: () {
                onClose();
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const WeeklyRoutineScreen(),
                  ),
                );
              },
            ),
            const SizedBox(height: 10),
            MenuItemRow(
              icon: Icons.eco_outlined,
              text: "Natural Products",
              onTap: () {
                onClose();
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const NaturalIngredientsScreen(),
                  ),
                );
              },
            ),
            const SizedBox(height: 10),
            MenuItemRow(
              icon: Icons.science,
              text: "Chemical Products",
              onTap: () {
                onClose();
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const ChemicalIngredientsScreen(),
                  ),
                );
              },
            ),
            const SizedBox(height: 10),
            MenuItemRow(
              icon: Icons.favorite_border,
              text: "Favorite Ingredients",
              onTap: () {
                onClose();
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const FavoriteIngredientsScreen(),
                  ),
                );
              },
            ),
            const SizedBox(height: 10),
            MenuItemRow(
              icon: Icons.help_outline,
              text: "Help",
              onTap: () {
                onClose();
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const HelpScreen()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
