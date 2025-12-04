import 'package:flutter/material.dart';
import 'package:skin_type_app/common/widgets/top_menu_overlay.dart';
import '../widgets/ingredient_item_card.dart'; // Oluşturduğumuz kartı import et

class FavoriteIngredientsScreen extends StatefulWidget {
  const FavoriteIngredientsScreen({super.key});

  @override
  State<FavoriteIngredientsScreen> createState() => _FavoriteIngredientsScreenState();
}

class _FavoriteIngredientsScreenState extends State<FavoriteIngredientsScreen> {
  // Hangi sekmenin seçili olduğunu tutan değişken
  bool _isChemicalSelected = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // 1. HEADER (Mor Gradient)
          Container(
            padding: const EdgeInsets.only(top: 50, bottom: 20, left: 16, right: 16),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF7B61FF), Color(0xFF9C27B0)], // Mor tonları
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Icon(Icons.arrow_back, color: Colors.white),
                const Text(
                  "Favorite Ingredients",
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
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // 2. SEARCH BAR
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const TextField(
                      decoration: InputDecoration(
                        icon: Icon(Icons.search, color: Colors.grey),
                        hintText: "Search ingredients...",
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // 3. TOGGLE SWITCH (Chemical vs Natural)
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Row(
                      children: [
                        _buildTabButton("Chemical\nIngredients", true),
                        _buildTabButton("Natural\nIngredients", false),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // 4. LİSTE (Seçime göre değişir)
                  _isChemicalSelected ? _buildChemicalList() : _buildNaturalList(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Tab Butonu Oluşturan Yardımcı Fonksiyon
  Widget _buildTabButton(String title, bool isChemicalBtn) {
    // Eğer butona basılmışsa (aktifse)
    bool isActive = _isChemicalSelected == isChemicalBtn;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _isChemicalSelected = isChemicalBtn;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isActive ? const Color(0xFF7B61FF) : Colors.transparent, // Aktifse Mor, değilse şeffaf
            borderRadius: BorderRadius.circular(12),
            boxShadow: isActive
                ? [BoxShadow(color: const Color(0xFF7B61FF).withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 4))]
                : [],
          ),
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isActive ? Colors.white : Colors.grey.shade600,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }

  // CHEMICAL INGREDIENTS Listesi (Image 1 Verileri)
  Widget _buildChemicalList() {
    return Column(
      children: const [
        IngredientItemCard(
          title: "Niacinamide",
          description: "Vitamin B3 derivative that brightens skin and reduces pore appearance",
          icon: Icons.science,
          iconColor: Color(0xFF9575CD), // Açık Mor
          tags: ["Brightening", "Hydration"],
          tagColors: [Color(0xFFE3F2FD), Color(0xFFE8F5E9)], // Mavi, Yeşil tonları
          riskLevel: "Low Risk",
          riskColor: Colors.green,
        ),
        IngredientItemCard(
          title: "Retinol",
          description: "Powerful anti-aging compound that promotes cell turnover",
          icon: Icons.settings, // Dişli ikonu (veya benzer bir şekil)
          iconColor: Color(0xFFFFD54F), // Sarı
          tags: ["Anti-aging", "Texture"],
          tagColors: [Color(0xFFF3E5F5), Color(0xFFFFF3E0)], // Morumsu, Turuncumsu
          riskLevel: "Medium Risk",
          riskColor: Colors.orange,
        ),
        IngredientItemCard(
          title: "Hyaluronic Acid",
          description: "Moisture-binding molecule that holds up to 1000x its weight in water",
          icon: Icons.water_drop,
          iconColor: Color(0xFF42A5F5), // Mavi
          tags: ["Hydration", "Plumping", "Sensitive-safe"],
          tagColors: [Color(0xFFE3F2FD), Color(0xFFE0F2F1), Color(0xFFFCE4EC)],
          riskLevel: "Low Risk",
          riskColor: Colors.green,
        ),
        IngredientItemCard(
          title: "Salicylic Acid",
          description: "BHA exfoliant that penetrates pores to clear acne and blackheads",
          icon: Icons.colorize, // Tüp ikonu
          iconColor: Color(0xFF2ECC71), // Yeşil
          tags: ["Acne", "Exfoliating"],
          tagColors: [Color(0xFFFFEBEE), Color(0xFFF3E5F5)],
          riskLevel: "Low Risk",
          riskColor: Colors.green,
        ),
      ],
    );
  }

  // NATURAL INGREDIENTS Listesi (Image 2 Verileri)
  Widget _buildNaturalList() {
    return Column(
      children: const [
        IngredientItemCard(
          title: "Aloe Vera",
          description: "Soothing botanical extract that calms irritation",
          icon: Icons.eco, // Yaprak ikonu
          iconColor: Color(0xFF2ECC71), // Yeşil
          tags: ["Soothing", "Hydration"],
          tagColors: [Color(0xFFE3F2FD), Color(0xFFF3E5F5)],
          riskLevel: "Low Risk",
          riskColor: Colors.green,
        ),
        IngredientItemCard(
          title: "Green Tea Extract",
          description: "Antioxidant-rich plant compound",
          icon: Icons.local_cafe, // Çay/Kupa ikonu
          iconColor: Color(0xFF2ECC71),
          tags: ["Anti-inflammatory", "Antioxidant"],
          tagColors: [Color(0xFFE0F2F1), Color(0xFFFFF3E0)],
          riskLevel: "Low Risk",
          riskColor: Colors.green,
        ),
        IngredientItemCard(
          title: "Chamomile",
          description: "Gentle ingredient ideal for sensitive skin",
          icon: Icons.water_drop,
          iconColor: Color(0xFF42A5F5),
          tags: ["Soothing", "Sensitive-safe"],
          tagColors: [Color(0xFFE3F2FD), Color(0xFFFCE4EC)],
          riskLevel: "Low Risk",
          riskColor: Colors.green,
        ),
        IngredientItemCard(
          title: "Centella Asiatica",
          description: "Natural healer that strengthens the skin barrier",
          icon: Icons.colorize,
          iconColor: Color(0xFF2ECC71),
          tags: ["Anti-inflammatory", "Nourishing"],
          tagColors: [Color(0xFFE0F2F1), Color(0xFFE8EAF6)],
          riskLevel: "Low Risk",
          riskColor: Colors.green,
        ),
         IngredientItemCard(
          title: "Rosehip Oil",
          description: "Nutrient-rich oil that brightens and nourishes",
          icon: Icons.water_drop,
          iconColor: Color(0xFFFFD54F), // Sarı
          tags: ["Nourishing", "Brightening"],
          tagColors: [Color(0xFFE8EAF6), Color(0xFFFFF8E1)],
          riskLevel: "Medium Risk",
          riskColor: Color(0xFFA1887F), // Kahverengi ton
        ),
      ],
    );
  }
}