import 'package:flutter/material.dart';
import 'package:skin_type_app/common/widgets/top_menu_overlay.dart';
import 'package:skin_type_app/core/database/data_service.dart';
import '../widgets/day_selector_item.dart';
import '../widgets/routine_step_tile.dart';
import '../widgets/tips_card.dart';

class WeeklyRoutineScreen extends StatefulWidget {
  const WeeklyRoutineScreen({super.key});

  @override
  State<WeeklyRoutineScreen> createState() => _WeeklyRoutineScreenState();
}

class _WeeklyRoutineScreenState extends State<WeeklyRoutineScreen> {
  // Verileri tutacak değişkenler
  Map<String, dynamic> _sabahRutini = {};
  Map<String, dynamic> _aksamRutini = {};
  bool _isLoading = true;

  final Map<String, bool> _completedSteps = {};

  @override
  void initState() {
    super.initState();
    _loadRoutineData();
  }

  // Veritabanından veriyi çeken fonksiyon
  Future<void> _loadRoutineData() async {
    final storage = SkinAnalysisStorage();
    final loadedData = await storage.loadAnalysisData();

    final savedTicks = await storage.loadRoutineStatus();

    if (loadedData != null && loadedData['rutin'] != null) {
      if (mounted) {
        setState(() {
          _sabahRutini = loadedData['rutin']['sabah_rutini'] ?? {};
          _aksamRutini = loadedData['rutin']['aksam_rutini'] ?? {};
          _completedSteps.addAll(savedTicks);
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
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 1. HEADER ALANI
            // 1. HEADER ALANI (Mor Gradient Arka Plan)
            Container(
              padding: const EdgeInsets.only(
                top: 50,
                bottom: 20,
                left: 16,
                right: 16,
              ),
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
                  // BURASI GÜNCELLENDİ: Sabit Icon yerine IconButton kullanıldı
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () {
                      Navigator.pop(context); // Bir önceki ekrana geri döner
                    },
                  ),

                  const Text(
                    "Weekly Routine",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
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
                  const Text(
                    "Your personalized skincare plan",
                    style: TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 20),

                  // 2. GÜN SEÇİCİ
                  SizedBox(
                    height: 80,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: const [
                        DaySelectorItem(
                          day: "Mon",
                          isSelected: false,
                          hasDot: true,
                        ),
                        DaySelectorItem(
                          day: "Tue",
                          isSelected: false,
                          hasDot: true,
                        ),
                        DaySelectorItem(
                          day: "Wed",
                          isSelected: true,
                          hasDot: true,
                        ),
                        DaySelectorItem(day: "Thu", isSelected: false),
                        DaySelectorItem(day: "Fri", isSelected: false),
                        DaySelectorItem(day: "Sat", isSelected: false),
                        DaySelectorItem(day: "Sun", isSelected: false),
                      ],
                    ),
                  ),
                  const SizedBox(height: 25),

                  // 3. AM ROUTINE KARTI (DİNAMİK)
                  _buildRoutineSection(
                    title: "AM Routine",
                    headerIcon: Icons.wb_sunny_outlined,
                    headerIconColor: Colors.orange,
                    // Eğer yükleniyorsa loading göster, yoksa listeyi oluştur
                    children: _isLoading
                        ? [const Center(child: CircularProgressIndicator())]
                        : _buildDynamicRoutineList(_sabahRutini),
                  ),
                  const SizedBox(height: 25),

                  // 4. PM ROUTINE KARTI (DİNAMİK)
                  _buildRoutineSection(
                    title: "PM Routine",
                    headerIcon: Icons.dark_mode_outlined,
                    headerIconColor: Colors.indigo,
                    children: _isLoading
                        ? [const Center(child: CircularProgressIndicator())]
                        : _buildDynamicRoutineList(_aksamRutini),
                  ),
                  const SizedBox(height: 25),

                  // 5. PERSONALIZED TIPS
                  const TipsCard(),
                  const SizedBox(height: 30),

                  // 6. ALT BUTON
                  Container(
                    width: double.infinity,
                    height: 55,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFF06292), Color(0xFFBA68C8)],
                      ),
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFF06292).withOpacity(0.4),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.check_circle, color: Colors.white),
                          SizedBox(width: 10),
                          Text(
                            "View Analyses",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
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

  // --- YARDIMCI METOTLAR ---

  // JSON Anahtarlarını (örn: nazik_jel_temizleyici) Güzel Başlıklara ve İkonlara Çeviren Fonksiyon
  // JSON Anahtarlarını (örn: nazik_jel_temizleyici) Güzel Başlıklara ve İkonlara Çeviren Fonksiyon
  List<Widget> _buildDynamicRoutineList(Map<String, dynamic> routineData) {
    if (routineData.isEmpty) {
      return [
        const Text(
          "No routine data available yet.",
          style: TextStyle(color: Colors.grey),
        ),
      ];
    }

    return routineData.entries.map((entry) {
      String key = entry.key; // Örn: "nazik_jel_temizleyici"
      String value = entry.value.toString(); // Örn: "Salicylic Acid..."

      // --- İkon ve Renk Seçimi (Eski kodunuzla aynı) ---
      IconData icon;
      Color color;
      String title;

      if (key.contains("temizle")) {
        icon = Icons.water_drop;
        color = Colors.blue;
        title = "Cleanser";
      } else if (key.contains("tonik")) {
        icon = Icons.science;
        color = Colors.amber;
        title = "Toner";
      } else if (key.contains("serum")) {
        icon = Icons.colorize;
        color = Colors.deepPurpleAccent;
        title = "Serum";
      } else if (key.contains("nem")) {
        icon = Icons.local_florist;
        color = Colors.green;
        title = "Moisturizer";
      } else if (key.contains("gunes")) {
        icon = Icons.shield;
        color = Colors.orangeAccent;
        title = "SPF";
      } else if (key.contains("eksfoliasyon")) {
        icon = Icons.autorenew;
        color = Colors.pinkAccent;
        title = "Exfoliator";
      } else if (key.contains("nokta")) {
        icon = Icons.add_circle_outline;
        color = Colors.redAccent;
        title = "Spot Treatment";
      } else {
        icon = Icons.star;
        color = Colors.grey;
        title = _capitalize(key.replaceAll("_", " "));
      }
      // ----------------------------------------------------

      // YENİ EKLENEN KISIM: Tıklama Mantığı

      // Bu adımın tamamlanıp tamamlanmadığını kontrol et
      bool isChecked = _completedSteps[key] ?? false;

      return GestureDetector(
        onTap: () async {
          setState(() {
            // Durumu tersine çevir (True <-> False)
            _completedSteps[key] = !isChecked;
          });
          final storage = SkinAnalysisStorage();
          await storage.saveRoutineStatus(_completedSteps);
        },
        child: RoutineStepTile(
          icon: icon,
          iconColor: color,
          title: title,
          subtitle: value,
          // Buraya dinamik durumu veriyoruz
          isCompleted: isChecked,
        ),
      );
    }).toList();
  }

  // String ilk harf büyütme yardımcısı
  String _capitalize(String s) => s[0].toUpperCase() + s.substring(1);

  Widget _buildRoutineSection({
    required String title,
    required IconData headerIcon,
    required Color headerIconColor,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.05),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Icon(headerIcon, color: headerIconColor),
            ],
          ),
          const SizedBox(height: 20),
          ...children,
        ],
      ),
    );
  }
}
