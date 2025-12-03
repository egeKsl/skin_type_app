import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
// Tekrar kullanılacak widget'ları import ediyoruz
import '../widgets/menu_item_row.dart'; 
import '../widgets/info_section_card.dart';

class WeeklyReviewScreen extends StatelessWidget {
  const WeeklyReviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 1. ÜST MENÜ ALANI (Görseldeki Açık Menü)
            _buildMenuDrawer(),

            // Sayfanın geri kalan içeriği
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  SizedBox(height: 20),

                  // 2. Improvement Trends (Grafik Alanı)
                  ImprovementTrendsSection(),
                  SizedBox(height: 30),

                  // 3. Trend Insights Başlığı
                  Text(
                    'Trend Insights',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 15),

                  // 4. Trend Kartları (Risk, Improving, Needs Attention)
                  TrendInsightsCards(),
                  SizedBox(height: 30),

                  // 5. Scan Timeline (Tarama Geçmişi)
                  ScanTimelineSection(),
                  SizedBox(height: 50),

                  // 6. En Alt Kısımdaki Mor Kart
                  ScanProductCard(),
                  SizedBox(height: 50),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Menü alanını oluşturan yardımcı metod
  Widget _buildMenuDrawer() {
    return Container(
      padding: const EdgeInsets.only(top: 50, bottom: 20, left: 20, right: 20),
      decoration: const BoxDecoration(
        color: AppColors.darkMenu, // Koyu gri renk
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Column(
        children: const [
          // Menüdeki X kapatma butonu
          Align(
            alignment: Alignment.topRight,
            child: Icon(Icons.close, color: Colors.white, size: 28),
          ),
          SizedBox(height: 10),

          // MenuItemRow widget'larını tekrar kullanıyoruz
          MenuItemRow(icon: Icons.home, text: "Home"),
          SizedBox(height: 10),
          MenuItemRow(icon: Icons.person_outline, text: "Profile"),
          SizedBox(height: 10),
          MenuItemRow(icon: Icons.calendar_today, text: "Routine"),
          SizedBox(height: 10),
          MenuItemRow(icon: Icons.eco_outlined, text: "Natural Products"),
          SizedBox(height: 10),
          MenuItemRow(icon: Icons.favorite_border, text: "Favorite Ingredients"),
          SizedBox(height: 10),
          MenuItemRow(icon: Icons.help_outline, text: "Help"),
        ],
      ),
    );
  }
}