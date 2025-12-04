import 'package:flutter/material.dart';
import 'package:skin_type_app/common/widgets/top_menu_overlay.dart';
// Widget Importları
import '../widgets/day_selector_item.dart';
import '../widgets/routine_step_tile.dart';
import '../widgets/tips_card.dart';

class WeeklyRoutineScreen extends StatelessWidget {
  const WeeklyRoutineScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 1. HEADER ALANI (Mor Gradient Arka Plan)
            Container(
              padding: const EdgeInsets.only(top: 50, bottom: 20, left: 16, right: 16),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF9575CD), Color(0xFFB39DDB)], // Mor tonları
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Icon(Icons.arrow_back, color: Colors.white),
                  const Text(
                    "Weekly Routine",
                    style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  GestureDetector(
                    onTap: () {
                      showTopMenuOverlay(context);
                    },
                    child: const Icon(Icons.menu, color: Colors.white),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Your personalized skincare plan", style: TextStyle(color: Colors.grey)),
                  const SizedBox(height: 20),

                  // 2. GÜN SEÇİCİ (Yatay Liste)
                  SizedBox(
                    height: 80,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: const [
                        DaySelectorItem(day: "Mon", isSelected: false, hasDot: true),
                        DaySelectorItem(day: "Tue", isSelected: false, hasDot: true),
                        DaySelectorItem(day: "Wed", isSelected: true, hasDot: true),
                        DaySelectorItem(day: "Thu", isSelected: false),
                        DaySelectorItem(day: "Fri", isSelected: false),
                        DaySelectorItem(day: "Sat", isSelected: false),
                        DaySelectorItem(day: "Sun", isSelected: false),
                      ],
                    ),
                  ),
                  const SizedBox(height: 25),

                  // 3. AM ROUTINE KARTI
                  _buildRoutineSection(
                    title: "AM Routine",
                    headerIcon: Icons.wb_sunny_outlined,
                    headerIconColor: Colors.orange,
                    children: [
                      const RoutineStepTile(
                        icon: Icons.water_drop, iconColor: Colors.blue, 
                        title: "Cleanser", subtitle: "Gentle foam wash", isCompleted: true
                      ),
                      const RoutineStepTile(
                        icon: Icons.science, iconColor: Colors.amber, 
                        title: "Toner", subtitle: "Hydrating essence", isCompleted: true
                      ),
                      const RoutineStepTile(
                        icon: Icons.colorize, iconColor: Colors.deepPurpleAccent, 
                        title: "Serum", subtitle: "Vitamin C brightening", isCompleted: false
                      ),
                      const RoutineStepTile(
                        icon: Icons.local_florist, iconColor: Colors.green, 
                        title: "Moisturizer", subtitle: "Light gel cream", isCompleted: false
                      ),
                      const RoutineStepTile(
                        icon: Icons.shield, iconColor: Colors.orangeAccent, 
                        title: "SPF", subtitle: "Sunscreen SPF 50+", isCompleted: false
                      ),
                    ],
                  ),
                  const SizedBox(height: 25),

                  // 4. PM ROUTINE KARTI
                  _buildRoutineSection(
                    title: "PM Routine",
                    headerIcon: Icons.dark_mode_outlined,
                    headerIconColor: Colors.indigo,
                    children: [
                      const RoutineStepTile(
                        icon: Icons.auto_awesome, iconColor: Colors.pinkAccent, 
                        title: "Makeup Remover", subtitle: "Micellar water", isCompleted: true
                      ),
                       const RoutineStepTile(
                        icon: Icons.water_drop, iconColor: Colors.blue, 
                        title: "Cleanser", subtitle: "Deep cleansing oil", isCompleted: true
                      ),
                      const RoutineStepTile(
                        icon: Icons.science, iconColor: Colors.deepPurple, 
                        title: "Treatment Serum", subtitle: "Retinol renewal", isCompleted: false
                      ),
                      const RoutineStepTile(
                        icon: Icons.local_florist, iconColor: Colors.green, 
                        title: "Moisturizer", subtitle: "Night repair cream", isCompleted: false
                      ),
                    ],
                  ),
                  const SizedBox(height: 25),

                  // 5. PERSONALIZED TIPS
                  const TipsCard(),
                  const SizedBox(height: 30),

                  // 6. ALT BUTON (View Analyses)
                  Container(
                    width: double.infinity,
                    height: 55,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [Color(0xFFF06292), Color(0xFFBA68C8)]),
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(color: const Color(0xFFF06292).withOpacity(0.4), blurRadius: 10, offset: const Offset(0, 4))
                      ]
                    ),
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.check_circle, color: Colors.white),
                          SizedBox(width: 10),
                          Text("View Analyses", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Rutin Kartlarını oluşturan yardımcı metod (AM ve PM için ortak yapı)
  Widget _buildRoutineSection({required String title, required IconData headerIcon, required Color headerIconColor, required List<Widget> children}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(color: Colors.grey.withOpacity(0.05), blurRadius: 10, spreadRadius: 2),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              Icon(headerIcon, color: headerIconColor),
            ],
          ),
          const SizedBox(height: 20),
          ...children, // Listeyi buraya açıyoruz
        ],
      ),
    );
  }
}