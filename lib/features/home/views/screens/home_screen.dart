import 'package:flutter/material.dart';
// Aşağıdaki importlar kendi oluşturduğumuz dosyaları sayfaya dahil eder
import 'package:skin_type_app/constants/app_colors.dart';
import '../widgets/product_card.dart';
import '../widgets/info_section_card.dart';
import '../widgets/menu_item_row.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  bool _isTopMenuExpanded = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 1. ÜST MENÜ ALANI (içeri girip çıkabilen alan)
            ClipRect(
              child: AnimatedSize(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                child: _isTopMenuExpanded
                    ? Container(
                        padding: const EdgeInsets.only(
                          top: 50,
                          bottom: 20,
                          left: 20,
                          right: 20,
                        ),
                        decoration: const BoxDecoration(
                          color: AppColors.darkMenu,
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(30),
                            bottomRight: Radius.circular(30),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
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
                                  onPressed: () {
                                    setState(() {
                                      _isTopMenuExpanded = false;
                                    });
                                  },
                                  icon: const Icon(
                                    Icons.keyboard_arrow_up,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            const MenuItemRow(icon: Icons.home, text: "Home"),
                            const SizedBox(height: 10),
                            const MenuItemRow(icon: Icons.person_outline, text: "Profile"),
                            const SizedBox(height: 10),
                            const MenuItemRow(icon: Icons.calendar_today, text: "Routine"),
                            const SizedBox(height: 10),
                            const MenuItemRow(icon: Icons.eco_outlined, text: "Natural Products"),
                            const SizedBox(height: 10),
                            const MenuItemRow(icon: Icons.favorite_border, text: "Favorite Ingredients"),
                            const SizedBox(height: 10),
                            const MenuItemRow(icon: Icons.help_outline, text: "Help"),
                          ],
                        ),
                      )
                    : Align(
                        alignment: Alignment.topCenter,
                        child: Padding(
                          padding: const EdgeInsets.only(top: 40, left: 16, right: 16, bottom: 8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  color: AppColors.darkMenu,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: IconButton(
                                  onPressed: () {
                                    setState(() {
                                      _isTopMenuExpanded = true;
                                    });
                                  },
                                  icon: const Icon(
                                    Icons.keyboard_arrow_down,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // 2. CURRENT ISSUES & RISKS (Widget Kullanımı)
                  const InfoSectionCard(
                    title: "Current Issues",
                    count: "3",
                    color: Color(0xFFFFEBEE), // Açık kırmızı
                    iconColor: Colors.red,
                    items: ["Acne breakouts on T-zone", "Enlarged pores on cheeks", "Uneven skin texture"],
                  ),
                  const SizedBox(height: 15),
                  
                  const InfoSectionCard(
                    title: "Potential Risks",
                    count: "2",
                    color: Color(0xFFFFF3E0), // Açık turuncu
                    iconColor: Colors.orange,
                    items: ["Early signs of sun damage", "Dehydration lines forming"],
                  ),
                  const SizedBox(height: 15),

                  // 3. SKIN TYPE (Basit olduğu için burada bıraktım)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: const [
                            Icon(Icons.water_drop, color: Colors.blue),
                            SizedBox(width: 8),
                            Text("Skin Type", style: TextStyle(fontWeight: FontWeight.bold)),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text("Combination / Oily", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
                              child: const Text("85% Match", style: TextStyle(color: Colors.green, fontSize: 12)),
                            )
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 25),

                  // 4. RECOMMENDED FOR YOU
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Text("Recommended For You", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      Text("See All", style: TextStyle(color: AppColors.primaryPurple, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 15),
                  
                  // Yatay Liste
                  SizedBox(
                    height: 350,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: const [
                        ProductCard(
                          title: "Salicylic Acid Serum 2%",
                          subtitle: "Acne Treatment",
                          tagColor: Colors.redAccent,
                          tagText: "URGENT",
                          desc: "Penetrates deep into pores to dissolve excess oil.",
                        ),
                        ProductCard(
                          title: "Niacinamide 10%",
                          subtitle: "Pore Minimizer",
                          tagColor: Colors.orangeAccent,
                          tagText: "HIGH",
                          desc: "Regulates oil production and reduces pores.",
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 30),

                  // 5. START YOUR JOURNEY
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(25),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [AppColors.accentPurple, AppColors.primaryPurple]),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      children: [
                        const Icon(Icons.calendar_month, color: Colors.white, size: 40),
                        const SizedBox(height: 10),
                        const Text("Start Your Journey", style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: AppColors.accentPurple,
                          ),
                          child: const Text("Create My Routine"),
                        )
                      ],
                    ),
                  ),
                  const SizedBox(height: 50),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}