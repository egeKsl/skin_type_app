import 'package:flutter/material.dart';
import 'package:skin_type_app/constants/app_colors.dart';
import 'package:skin_type_app/common/widgets/top_menu_overlay.dart';
import 'package:skin_type_app/core/database/data_service.dart';
import 'package:skin_type_app/features/natural ingredients/views/widgets/ai_recommendation_card.dart';
import 'package:skin_type_app/features/natural ingredients/views/widgets/ingredient_card.dart';
import 'package:skin_type_app/features/natural ingredients/views/widgets/usage_tip_card.dart';
//import '../widgets/usage_tip_card.dart';

class ChemicalIngredientsScreen extends StatefulWidget {
  const ChemicalIngredientsScreen({super.key});

  @override
  State<ChemicalIngredientsScreen> createState() =>
      _ChemicalIngredientsScreenState();
}

class _ChemicalIngredientsScreenState extends State<ChemicalIngredientsScreen> {
  List<String> _kimyasalIcerikler = [];
  bool _isLoading = true;

  // Tema rengi (compile-time const OLMASI ŞART DEĞİL)
  final Color primaryScientificColor = const Color(0xFF5C6BC0);

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final storage = SkinAnalysisStorage();
    final loadedData = await storage.loadAnalysisData();

    if (loadedData != null && mounted) {
      setState(() {
        _kimyasalIcerikler = List<String>.from(
          loadedData['kimyasal_aktif_icerikler'] ?? [],
        );
        _isLoading = false;
      });
    } else if (mounted) {
      setState(() => _isLoading = false);
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
                // ❗ const KALDIRILDI
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
                    height: 550, // 🔴 Natural ile AYNI
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
                              return IngredientCard(
                                title: _kimyasalIcerikler[index],
                                description:
                                    "Powerful active ingredient targeting specific skin concerns.",
                                matchPercentage: "9${8 - (index % 5)}% Match",
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
