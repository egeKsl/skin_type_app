import 'package:flutter/material.dart';
// Aşağıdaki importlar kendi oluşturduğumuz dosyaları sayfaya dahil eder
import 'package:skin_type_app/constants/app_colors.dart';
import 'package:skin_type_app/features/profile/views/screens/profile_screen.dart';
import 'package:skin_type_app/features/Weekly Routine/views/screens/weekly_routine_screen.dart';
import 'package:skin_type_app/features/natural ingredients/views/screens/natural_ingredients_screen.dart';
import 'package:skin_type_app/features/favorite ingredients/views/screens/favorite_ingredients_screen.dart';
import '../widgets/product_card.dart';
import '../widgets/info_section_card.dart';
import '../widgets/menu_item_row.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  // Başlangıçta menünün kapalı (veya Yüz Tanıma ekranının görünür) olduğunu varsayalım.
  // Not: İlk fotoğrafta menü açıktı, ancak Yüz Tanıma ekranında kapalıydı.
  // Bu kodu Yüz Tanıma ekranı (kapalı menü) varsayımıyla başlatıyorum.
  bool _isTopMenuExpanded = false; 

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
                    ? _buildExpandedMenu() // Menü Açık (Görsel 1: Menu.jpg)
                    : _buildCollapsedHeader(), // Menü Kapalı (Görsel 2: Yüz Tanıma.jpg)
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                // ... (Ekranın kalan içeriği burada devam ediyor) ...
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

  // --- YENİ EKLENEN/GÜNCELLENEN METOTLAR ---

  // Menü KAPALIYKEN görünen Yüz Tanıma Başlık ve Görsel Alanı
  Widget _buildCollapsedHeader() {
    return Container(
      padding: const EdgeInsets.only(top: 40, bottom: 20),
      // Yüz tanıma görselinin altına gölge vermek için kutuyu genişletiyoruz
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Icon(Icons.arrow_back, color: Colors.black),
                const Text(
                  'Skin Analysis',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                // Menüyü açmak için sağ üstteki buton
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _isTopMenuExpanded = true;
                    });
                  },
                  child: const Icon(Icons.menu, color: Colors.black),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          
          // YÜZ GÖRSELİ Placeholder
          Container(
            height: 250,
            width: double.infinity,
            color: Colors.grey[100], // Resim Placeholder'ı
            child: Center(
              child: Stack(
                alignment: Alignment.bottomCenter,
                children: [
                  //  // Yüz görseli için
                  ClipOval(
                    child: Container(
                      width: 150,
                      height: 150,
                      color: Colors.grey[300],
                      child: const Icon(Icons.face, size: 80, color: Colors.grey),
                    ),
                  ),
                  
                  // Analiz Çubuğu ve Yazı
                  Positioned(
                    bottom: 20,
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.9),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: AppColors.primaryPurple, width: 2),
                          ),
                          child: Row(
                            children: const [
                              SizedBox(
                                width: 10,
                                height: 10,
                                child: CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryPurple),
                                  strokeWidth: 2,
                                ),
                              ),
                              SizedBox(width: 8),
                              Text('Analyzing your skin!', style: TextStyle(color: AppColors.primaryPurple, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          const Text('Analysis Results', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  // Menü AÇIKKEN görünen liste
  Widget _buildExpandedMenu() {
    return Container(
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
          MenuItemRow(
            icon: Icons.person_outline,
            text: "Profile",
            onTap: () {
              setState(() {
                _isTopMenuExpanded = false;
              });
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
              setState(() {
                _isTopMenuExpanded = false;
              });
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
              setState(() {
                _isTopMenuExpanded = false;
              });
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const NaturalIngredientsScreen(),
                ),
              );
            },
          ),
          const SizedBox(height: 10),
          MenuItemRow(
            icon: Icons.favorite_border,
            text: "Favorite Ingredients",
            onTap: () {
              setState(() {
                _isTopMenuExpanded = false;
              });
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const FavoriteIngredientsScreen(),
                ),
              );
            },
          ),
          const SizedBox(height: 10),
          const MenuItemRow(icon: Icons.help_outline, text: "Help"),
        ],
      ),
    );
  }
}