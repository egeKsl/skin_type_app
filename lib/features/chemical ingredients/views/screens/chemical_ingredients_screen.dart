import 'package:flutter/material.dart';
import 'package:skin_type_app/constants/app_colors.dart';
import 'package:skin_type_app/common/widgets/top_menu_overlay.dart';
import 'package:skin_type_app/core/services/scan_service.dart'; // Firebase Servisi
import 'package:skin_type_app/models/scan_model.dart'; // Model dosyası
import 'package:skin_type_app/features/natural ingredients/views/widgets/ai_recommendation_card.dart';
import 'package:skin_type_app/features/natural ingredients/views/widgets/ingredient_card.dart';
import 'package:skin_type_app/features/natural ingredients/views/widgets/usage_tip_card.dart';

class ChemicalIngredientsScreen extends StatefulWidget {
  const ChemicalIngredientsScreen({super.key});

  @override
  State<ChemicalIngredientsScreen> createState() =>
      _ChemicalIngredientsScreenState();
}

class _ChemicalIngredientsScreenState extends State<ChemicalIngredientsScreen> {
  final ScanService _scanService = ScanService();
  List<dynamic> _kimyasalIcerikler = [];
  String _matchPercentage = "95%";
  bool _isLoading = true;

  final Color primaryScientificColor = const Color.fromARGB(255, 14, 19, 49);

  @override
  void initState() {
    super.initState();
    _loadFirebaseData();
  }

  // Firebase'den en son tarama verisini çeken fonksiyon
  Future<void> _loadFirebaseData() async {
    try {
      // getRecentScans(1) Stream'i bize List<ScanResult> döndürür
      _scanService
          .getRecentScans(1)
          .listen(
            (scans) {
              if (scans.isNotEmpty && mounted) {
                // Artık elimizde ham bir Map değil, bir ScanResult nesnesi var
                final ScanResult lastScan = scans.first;

                setState(() {
                  // Model içindeki alanlara direkt erişiyoruz
                  // ScanResult zaten raw_ai_output'u parse edip bu listeleri doldurmuş durumda
                  _kimyasalIcerikler = lastScan.kimyasalIcerikler;

                  // Yüzde bilgisini de modelden alıyoruz
                  _matchPercentage = lastScan.benzerlikYuzdesi.isNotEmpty
                      ? lastScan.benzerlikYuzdesi
                      : "95%";

                  _isLoading = false;
                });

                debugPrint(
                  "✅ Firebase verisi yeni model üzerinden başarıyla yüklendi: ${lastScan.ciltTipi}",
                );
              } else if (mounted) {
                setState(() => _isLoading = false);
              }
            },
            onError: (error) {
              debugPrint("❌ Firebase dinleme hatası: $error");
              if (mounted) setState(() => _isLoading = false);
            },
          );
    } catch (e) {
      debugPrint("❌ Genel hata: $e");
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        child: Column(
          children: [
            /// HEADER
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [primaryScientificColor, const Color(0xFF9FA8DA)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.only(
                  top: 50,
                  left: 16,
                  right: 16,
                  bottom: 20,
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: const Icon(
                            Icons.arrow_back,
                            color: Colors.white,
                          ),
                        ),
                        const Text(
                          "Active Ingredients",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        GestureDetector(
                          onTap: () => showTopMenuOverlay(context),
                          child: const Icon(Icons.menu, color: Colors.white),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.all(15),
                      decoration: const BoxDecoration(
                        color: Colors.white24,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.science,
                        color: Colors.white,
                        size: 40,
                      ),
                    ),
                    const SizedBox(height: 15),
                    const Text(
                      "Clinical Formulations",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 5),
                    const Text(
                      "Scientifically proven actives for your skin",
                      style: TextStyle(color: Colors.white70),
                    ),
                    const SizedBox(height: 25),
                    const AiRecommendationCard(),
                  ],
                ),
              ),
            ),

            /// CONTENT
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildSectionTitle(
                        "Proven Actives",
                        primaryScientificColor,
                      ),
                      const Text(
                        "Swipe to explore",
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),

                  SizedBox(
                    height: 550,
                    child: _isLoading
                        ? Center(
                            child: CircularProgressIndicator(
                              color: primaryScientificColor,
                            ),
                          )
                        : _kimyasalIcerikler.isEmpty
                        ? const Center(child: Text("No data found."))
                        : ListView.builder(
                            scrollDirection: Axis.horizontal,
                            clipBehavior: Clip.none,
                            itemCount: _kimyasalIcerikler.length,
                            itemBuilder: (context, index) {
                              // Veritabanı şemasına göre nesneyi alıyoruz
                              final item = _kimyasalIcerikler[index];

                              return IngredientCard(
                                title: item['isim'] ?? "Unknown",
                                // List<dynamic>'i List<String>'e çeviriyoruz
                                benefits: List<String>.from(
                                  item['temel_faydalar'] ?? [],
                                ),
                                usage:
                                    item['nasil_kullanilir'] ??
                                    "Follow package instructions.",
                                aiAnalysis:
                                    item['ai_analizi'] ??
                                    "Recommended based on scan.",
                                matchPercentage: _matchPercentage,
                              );
                            },
                          ),
                  ),

                  const SizedBox(height: 30),

                  _buildSectionTitle("Safety Guide", primaryScientificColor),
                  const SizedBox(height: 15),

                  const UsageTipCard(
                    icon: Icons.wb_sunny,
                    iconBgColor: Color(0xFFFFCCBC),
                    title: "Sun Protection",
                    description:
                        "Active ingredients increase sensitivity. Always use SPF.",
                  ),
                  const UsageTipCard(
                    icon: Icons.do_not_touch,
                    iconBgColor: Color(0xFFFFCDD2),
                    title: "Don't Mix",
                    description:
                        "Avoid combining strong actives without guidance.",
                  ),
                  const UsageTipCard(
                    icon: Icons.timelapse,
                    iconBgColor: Color(0xFFE1BEE7),
                    title: "Start Slowly",
                    description:
                        "Introduce actives gradually to build tolerance.",
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, Color color) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 20,
          color: color,
          margin: const EdgeInsets.only(right: 10),
        ),
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.darkText,
          ),
        ),
      ],
    );
  }
}
