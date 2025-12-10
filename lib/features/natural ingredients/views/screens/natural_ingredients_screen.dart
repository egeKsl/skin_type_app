import 'package:flutter/material.dart';
import 'package:skin_type_app/constants/app_colors.dart';
import 'package:skin_type_app/common/widgets/top_menu_overlay.dart';
import 'package:skin_type_app/core/database/data_service.dart'; // Storage servisini import et
import '../widgets/ai_recommendation_card.dart';
import '../widgets/ingredient_card.dart';
import '../widgets/usage_tip_card.dart';

class NaturalIngredientsScreen extends StatefulWidget {
  const NaturalIngredientsScreen({super.key});

  @override
  State<NaturalIngredientsScreen> createState() => _NaturalIngredientsScreenState();
}

class _NaturalIngredientsScreenState extends State<NaturalIngredientsScreen> {
  // Veritabanından gelecek listeyi tutacak değişken
  List<String> _dogalIcerikler = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  // Veritabanından veriyi çeken fonksiyon
  Future<void> _loadData() async {
    final storage = SkinAnalysisStorage();
    final loadedData = await storage.loadAnalysisData();
    
    if (loadedData != null) {
      print(loadedData['dogal_icerikler']);
      if (mounted) {
        setState(() {
          _dogalIcerikler = List<String>.from(loadedData['dogal_icerikler'] ?? []);
          _isLoading = false;
        });
      }
    } else {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 1. ÜST HEADER ve GREEN BACKGROUND
            Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.naturalGreen, Color(0xFFA5D6A7)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.only(top: 50, left: 16, right: 16, bottom: 20),
                child: Column(
                  children: [
                    // Navbar
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: const Icon(Icons.arrow_back, color: Colors.white),
                        ),
                        const Text(
                          "Natural Ingredients",
                          style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        GestureDetector(
                          onTap: () {
                            showTopMenuOverlay(context);
                          },
                          child: const Icon(Icons.menu, color: Colors.white),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    
                    // Yeşil Daire İkon
                    Container(
                      padding: const EdgeInsets.all(15),
                      decoration: const BoxDecoration(
                        color: Colors.white24, // Yarı saydam beyaz
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.eco, color: Colors.white, size: 40),
                    ),
                    const SizedBox(height: 15),
                    
                    // Başlıklar
                    const Text(
                      "Plant-Based Support",
                      style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 5),
                    const Text(
                      "Natural ingredients curated for your skin type",
                      style: TextStyle(color: Colors.white70),
                    ),
                    const SizedBox(height: 25),

                    // AI Recommendation Kartı
                    const AiRecommendationCard(),
                  ],
                ),
              ),
            ),

            // 2. İÇERİK KISMI
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // Recommended For You Başlığı
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildSectionTitle("Recommended for You"),
                      const Text("Swipe to explore", style: TextStyle(fontSize: 12, color: Colors.grey)),
                    ],
                  ),
                  const SizedBox(height: 15),

                  // YATAY LİSTE (Ingredient Cards - DİNAMİK)
                  SizedBox(
                    height: 650, 
                    child: _isLoading 
                        ? const Center(child: CircularProgressIndicator(color: AppColors.naturalGreen))
                        : _dogalIcerikler.isEmpty
                            ? const Center(child: Text("No data found."))
                            : ListView.builder(
                                scrollDirection: Axis.horizontal,
                                clipBehavior: Clip.none,
                                itemCount: _dogalIcerikler.length,
                                itemBuilder: (context, index) {
                                  final icerikAdi = _dogalIcerikler[index];
                                  
                                  return IngredientCard(
                                    title: icerikAdi,
                                    // API sadece isim verdiği için şimdilik standart açıklama giriyoruz
                                    description: "Natural extract recommended based on your skin analysis.",
                                    // Görsel amaçlı rastgele bir eşleşme oranı veriyoruz
                                    matchPercentage: "9${5 - (index % 5)}% Match", 
                                  );
                                },
                              ),
                  ),

                  const SizedBox(height: 30),

                  // USAGE TIPS Başlığı
                  Row(
                    children: [
                       Container(width: 4, height: 20, color: Colors.blueAccent, margin: const EdgeInsets.only(right: 10)),
                       const Text("Usage Tips", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 15),

                  // İpuçları Listesi
                  const UsageTipCard(
                    icon: Icons.lightbulb,
                    iconBgColor: Color(0xFFFFF9C4), 
                    title: "Patch Test First",
                    description: "Always test new natural ingredients on a small skin area before full application.",
                  ),
                  const UsageTipCard(
                    icon: Icons.access_time_filled,
                    iconBgColor: Color(0xFFBBDEFB), 
                    title: "Gradual Introduction",
                    description: "Start with 2-3 times per week, then increase frequency as your skin adapts.",
                  ),
                  const UsageTipCard(
                    icon: Icons.verified,
                    iconBgColor: Color(0xFFC8E6C9), 
                    title: "Quality Matters",
                    description: "Choose organic, cold-pressed oils and extracts for maximum potency and benefits.",
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

  // Başlık stil yardımcısı
  Widget _buildSectionTitle(String title) {
    return Row(
      children: [
        Container(width: 4, height: 20, color: AppColors.naturalGreen, margin: const EdgeInsets.only(right: 10)),
        Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.darkText)),
      ],
    );
  } 
}