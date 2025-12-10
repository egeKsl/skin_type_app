import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:skin_type_app/constants/app_colors.dart';
import 'package:skin_type_app/common/widgets/top_menu_overlay.dart';
import 'package:skin_type_app/core/database/data_service.dart';
import '../widgets/product_card.dart';
import '../widgets/info_section_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  final String _apiUrl = 'https://backend-server-skin-app--vertex-api-c4832.us-central1.hosted.app/analyze-skin';
  File? _selectedImage;
  String _resultText = '';
  bool _isLoading = false;
  List<String> _belirtiler = [];
  List<String> _ihtiyaclar = [];
  List<String> _kimyasalIcerikler = [];
  String _cilt_tipi = '';

  @override
  void initState() {
    super.initState();
    _loadDatabase();
  }

  Future<void> _loadDatabase() async {
    final storage = SkinAnalysisStorage();
    final loadedData = await storage.loadAnalysisData();

    if (loadedData != null) {
      setState(() {
        _belirtiler = List<String>.from(loadedData['belirtiler'] ?? []);
        _ihtiyaclar = List<String>.from(loadedData['ihtiyaclar'] ?? []);
        _cilt_tipi = loadedData['cilt_tipi'] ?? "Bilinmiyor";
        _kimyasalIcerikler = List<String>.from(loadedData['kimyasal_aktif_icerikler'] ?? []);
      });
    }
  }

  Future<void> _pickImageAndSend() async {
    if (_isLoading) {
      return;
    }

    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);

    if (image == null) {
      return;
    }

    setState(() {
      _selectedImage = File(image.path);
      _resultText = '';
      _isLoading = true;
    });

    try {
      final request = http.MultipartRequest('POST', Uri.parse(_apiUrl));
      request.files.add(await http.MultipartFile.fromPath('image', _selectedImage!.path));

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        final jsonBody = jsonDecode(responseBody);

        String cleanedJson = jsonBody['result']
            .replaceAll('```json', '')
            .replaceAll('```', '')
            .trim();
        final Map<String, dynamic> apiResponseData = json.decode(cleanedJson);
        final storage = SkinAnalysisStorage();
        await storage.saveAnalysisData(apiResponseData);

        // Veri kaydedildikten sonra ekrandaki belirtileri güncelle
        await _loadDatabase(); 

      } else {
        print("API HATA: ${response.statusCode} | $responseBody");
      }
    } catch (error) {
      print("Hata oluştu: $error");
    } finally {
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
            // 1. ÜST MENÜ ALANI
            _buildCollapsedHeader(),

            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // 2. CURRENT ISSUES & RISKS (Widget Kullanımı)
                  InfoSectionCard(
                    title: "Current Issues",
                    count: _belirtiler.length.toString(), // Dinamik sayı
                    color: const Color(0xFFFFEBEE), // Açık kırmızı
                    iconColor: Colors.red,
                    items: _belirtiler.isEmpty 
                        ? ["Veri bekleniyor..."] 
                        : _belirtiler, // Dinamik liste
                  ),
                  const SizedBox(height: 15),

                  InfoSectionCard(
                    title: "Needs",
                    count: "2",
                    color: Color(0xFFFFF3E0), // Açık turuncu
                    iconColor: Colors.orange,
                    items: _ihtiyaclar.isEmpty
                         ? ["Veri bekleniyor..."] 
                        : _ihtiyaclar,
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
                            Text(_cilt_tipi, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
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
                    child: _kimyasalIcerikler.isEmpty
                        ? const Center(child: Text("Veri bekleniyor...")) // Liste boşsa bu çalışır
                        : ListView.builder( // Liste doluysa burası çalışır
                            scrollDirection: Axis.horizontal,
                            itemCount: _kimyasalIcerikler.length,
                            itemBuilder: (context, index) {
                              // Listedeki sıradaki içeriği al
                              final icerikAdi = _kimyasalIcerikler[index];

                              return ProductCard(
                                title: icerikAdi, // API'den gelen isim (Örn: Salicylic Acid)
                                subtitle: "Active Ingredient",
                                tagColor: Colors.blueAccent,
                                tagText: "RECOMMENDED",
                                desc: "Based on your skin analysis, this ingredient is recommended.",
                              );
                            },
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
                    showTopMenuOverlay(context);
                  },
                  child: const Icon(Icons.menu, color: Colors.black),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // YÜZ GÖRSELİ Placeholder
          GestureDetector(
            onTap: _pickImageAndSend,
            child: Container(
              height: 250,
              width: double.infinity,
              color: Colors.grey[100], // Resim Placeholder'ı
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ClipOval(
                    child: Container(
                      width: 150,
                      height: 150,
                      color: Colors.grey[300],
                      child: _selectedImage != null
                          ? Image.file(
                              _selectedImage!,
                              fit: BoxFit.cover,
                            )
                          : const Icon(Icons.face, size: 80, color: Colors.grey),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.primaryPurple, width: 2),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (_isLoading)
                          const SizedBox(
                            width: 14,
                            height: 14,
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryPurple),
                              strokeWidth: 2,
                            ),
                          ),
                        if (_isLoading) const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            _isLoading
                                ? 'Analiz ediliyor...'
                                : (_resultText.isNotEmpty ? _resultText : 'Fotoğraf seçmek için dokun'),
                            style: const TextStyle(color: AppColors.primaryPurple, fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
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
}