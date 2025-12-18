import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:skin_type_app/constants/app_colors.dart';
import 'package:skin_type_app/common/widgets/top_menu_overlay.dart';
import 'package:skin_type_app/core/services/scan_service.dart'; // Firebase Servisi
import 'package:skin_type_app/models/scan_model.dart'; // Model dosyası
import 'package:skin_type_app/features/natural ingredients/views/widgets/ai_recommendation_card.dart';
import 'package:skin_type_app/features/natural ingredients/views/widgets/ingredient_card.dart';
import 'package:skin_type_app/features/natural ingredients/views/widgets/usage_tip_card.dart';

class NaturalIngredientsScreen extends StatefulWidget {
  const NaturalIngredientsScreen({super.key});

  @override
  State<NaturalIngredientsScreen> createState() =>
      _NaturalIngredientsScreenState();
}

class _NaturalIngredientsScreenState extends State<NaturalIngredientsScreen> {
  final ScanService _scanService = ScanService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  List<dynamic> _dogalIcerikler = [];
  Set<String> _favoritedNames = {}; // Favorilenmiş doğal içeriklerin isimleri
  String? _currentScanId;
  String _matchPercentage = "95%";
  bool _isLoading = true;

  // Doğal içerikler için yeşil tonlarında bir tema rengi
  final Color primaryNaturalColor = const Color(0xFF4CAF50);

  @override
  void initState() {
    super.initState();
    _loadFirebaseData();
  }

  // Firebase'den en son tarama verisini çeken fonksiyon
  Future<void> _loadFirebaseData() async {
    try {
      _scanService
          .getRecentScans(1)
          .listen(
            (scans) {
              if (scans.isNotEmpty && mounted) {
                final ScanResult lastScan = scans.first;

                setState(() {
                  _dogalIcerikler = lastScan.dogalIcerikler;
                  _currentScanId = lastScan.id; // Modelden scan ID alınıyor
                  _matchPercentage = lastScan.benzerlikYuzdesi.isNotEmpty
                      ? lastScan.benzerlikYuzdesi
                      : "95%";
                  _isLoading = false;
                });

                // Doğal favorileri yükle
                _loadFavorites();

                debugPrint(
                  "✅ Doğal içerikler yüklendi, Scan ID: $_currentScanId",
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

  // Belirli scan altındaki doğal favorileri getiren fonksiyon
  void _loadFavorites() {
    final user = _auth.currentUser;
    if (user == null || _currentScanId == null) return;

    _firestore
        .collection('users')
        .doc(user.uid)
        .collection('scans')
        .doc(_currentScanId)
        .collection('dogal_favoriler')
        .snapshots()
        .listen((snapshot) {
          if (mounted) {
            setState(() {
              _favoritedNames = snapshot.docs.map((doc) => doc.id).toSet();
            });
          }
        });
  }

  // Favori butonuna tıklandığında çalışacak fonksiyon (Doğal İçerik için)
  Future<void> _toggleFavorite(dynamic item) async {
    final user = _auth.currentUser;
    final String ingredientName = item['isim'] ?? "Unknown";

    if (user == null || _currentScanId == null) return;

    final docRef = _firestore
        .collection('users')
        .doc(user.uid)
        .collection('scans')
        .doc(_currentScanId)
        .collection('dogal_favoriler')
        .doc(ingredientName);

    try {
      if (_favoritedNames.contains(ingredientName)) {
        await docRef.delete();
        debugPrint("🗑️ Doğal favorilerden silindi: $ingredientName");
      } else {
        await docRef.set({
          'isim': ingredientName,
          'temel_faydalar': item['temel_faydalar'],
          'nasil_kullanilir': item['nasil_kullanilir'],
          'ai_analizi': item['ai_analizi'],
          'saved_at': FieldValue.serverTimestamp(),
        });
        debugPrint("⭐ Doğal favorilere eklendi: $ingredientName");
      }
    } catch (e) {
      debugPrint("❌ Favori işlemi hatası: $e");
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
                  colors: [primaryNaturalColor, const Color(0xFFA5D6A7)],
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
                          "Natural Ingredients",
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
                        Icons.eco,
                        color: Colors.white,
                        size: 40,
                      ),
                    ),
                    const SizedBox(height: 15),
                    const Text(
                      "Herbal Solutions",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 5),
                    const Text(
                      "Pure ingredients sourced from nature",
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
                        "Nature's Actives",
                        primaryNaturalColor,
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
                              color: primaryNaturalColor,
                            ),
                          )
                        : _dogalIcerikler.isEmpty
                        ? const Center(
                            child: Text("No natural ingredients found."),
                          )
                        : ListView.builder(
                            scrollDirection: Axis.horizontal,
                            clipBehavior: Clip.none,
                            itemCount: _dogalIcerikler.length,
                            itemBuilder: (context, index) {
                              final item = _dogalIcerikler[index];
                              final String name = item['isim'] ?? "Unknown";

                              return IngredientCard(
                                title: name,
                                benefits: List<String>.from(
                                  item['temel_faydalar'] ?? [],
                                ),
                                usage:
                                    item['nasil_kullanilir'] ??
                                    "Apply as part of your skincare routine.",
                                aiAnalysis:
                                    item['ai_analizi'] ??
                                    "Selected specifically for your skin concerns.",
                                matchPercentage: _matchPercentage,
                                isFavorite: _favoritedNames.contains(name),
                                onFavoriteToggle: () => _toggleFavorite(item),
                              );
                            },
                          ),
                  ),

                  const SizedBox(height: 30),

                  _buildSectionTitle("Natural Care Guide", primaryNaturalColor),
                  const SizedBox(height: 15),

                  const UsageTipCard(
                    icon: Icons.eco_outlined,
                    iconBgColor: Color(0xFFE8F5E9),
                    title: "Freshness",
                    description:
                        "Natural extracts work best when fresh and properly stored.",
                  ),
                  const UsageTipCard(
                    icon: Icons.health_and_safety_outlined,
                    iconBgColor: Color(0xFFF1F8E9),
                    title: "Patch Test",
                    description:
                        "Always test natural oils on a small area first.",
                  ),
                  const UsageTipCard(
                    icon: Icons.opacity,
                    iconBgColor: Color(0xFFE0F2F1),
                    title: "Concentration",
                    description:
                        "Nature is powerful. A little amount goes a long way.",
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
