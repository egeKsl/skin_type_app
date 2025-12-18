import 'package:flutter/material.dart';
import 'package:skin_type_app/common/widgets/top_menu_overlay.dart';
import 'package:skin_type_app/core/services/scan_service.dart';
import 'package:skin_type_app/models/scan_model.dart';
import '../widgets/ingredient_item_card.dart';

class FavoriteIngredientsScreen extends StatefulWidget {
  const FavoriteIngredientsScreen({super.key});

  @override
  State<FavoriteIngredientsScreen> createState() =>
      _FavoriteIngredientsScreenState();
}

class _FavoriteIngredientsScreenState extends State<FavoriteIngredientsScreen> {
  final ScanService _scanService = ScanService();
  final TextEditingController _searchController = TextEditingController();

  bool _isChemicalSelected = true;
  String _searchQuery = "";
  String? _latestScanId;

  @override
  void initState() {
    super.initState();
    _loadLatestScan();
  }

  // Favorilerin bağlı olduğu en son tarama ID'sini yakalıyoruz
  void _loadLatestScan() {
    _scanService.getRecentScans(1).listen((scans) {
      if (scans.isNotEmpty && mounted) {
        setState(() {
          _latestScanId = scans.first.id;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: _latestScanId == null
                ? const Center(child: CircularProgressIndicator())
                : _buildContent(),
          ),
        ],
      ),
    );
  }

  // Mor Gradyan Başlık Alanı
  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF7B61FF), Color(0xFF9C27B0)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: const Icon(Icons.arrow_back, color: Colors.white),
              ),
              const Text(
                "Favori İçerikler",
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
        ),
      ),
    );
  }

  Widget _buildContent() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // Arama Çubuğu
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(10),
            ),
            child: TextField(
              controller: _searchController,
              onChanged: (val) =>
                  setState(() => _searchQuery = val.toLowerCase()),
              decoration: const InputDecoration(
                icon: Icon(Icons.search, color: Colors.grey),
                hintText: "İçeriklerde ara...",
                border: InputBorder.none,
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Kimyasal / Doğal Seçici (Tab)
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(15),
            ),
            child: Row(
              children: [
                _buildTabButton("Kimyasal\nİçerikler", true),
                _buildTabButton("Doğal\nİçerikler", false),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Firestore Veri Listesi
          Expanded(
            child: StreamBuilder<List<Map<String, dynamic>>>(
              stream: _scanService.getFavorites(
                _latestScanId!,
                _isChemicalSelected ? 'kimyasal_favoriler' : 'dogal_favoriler',
              ),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final docs = snapshot.data ?? [];

                // Arama Filtrelemesi
                final filteredDocs = docs.where((doc) {
                  final name = (doc['isim'] ?? "").toString().toLowerCase();
                  return name.contains(_searchQuery);
                }).toList();

                if (filteredDocs.isEmpty) {
                  return Center(
                    child: Text(
                      _searchQuery.isEmpty
                          ? "Henüz favori yok."
                          : "Sonuç bulunamadı.",
                      style: const TextStyle(color: Colors.grey),
                    ),
                  );
                }

                return ListView.builder(
                  padding: EdgeInsets.zero,
                  itemCount: filteredDocs.length,
                  itemBuilder: (context, index) {
                    final item = filteredDocs[index];
                    final String name = item['isim'] ?? "Bilinmiyor";

                    return IngredientItemCard(
                      title: name,
                      description: item['ai_analizi'] ?? "Analiz mevcut değil.",
                      icon: _isChemicalSelected ? Icons.science : Icons.eco,
                      iconColor: _isChemicalSelected
                          ? const Color(0xFF9575CD)
                          : const Color(0xFF4CAF50),
                      tags: List<String>.from(item['temel_faydalar'] ?? []),
                      onRemove: () async {
                        // Canvas üzerindeki removeFavorite metodunu çağırıyoruz
                        await _scanService.removeFavorite(
                          scanId: _latestScanId!,
                          collectionName: _isChemicalSelected
                              ? 'kimyasal_favoriler'
                              : 'dogal_favoriler',
                          ingredientName: name,
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabButton(String title, bool isChemicalBtn) {
    bool isActive = _isChemicalSelected == isChemicalBtn;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _isChemicalSelected = isChemicalBtn),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isActive ? const Color(0xFF7B61FF) : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            boxShadow: isActive
                ? [
                    BoxShadow(
                      color: const Color(0xFF7B61FF).withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ]
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
}
