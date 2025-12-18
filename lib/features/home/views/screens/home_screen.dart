import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:image/image.dart' as img;
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:skin_type_app/constants/app_colors.dart';
import 'package:skin_type_app/common/widgets/top_menu_overlay.dart';
import 'package:skin_type_app/core/database/data_service.dart';
import 'package:skin_type_app/features/Weekly Routine/views/screens/weekly_routine_screen.dart';
import 'package:skin_type_app/features/face scan/views/screens/face_scan_screen.dart';
import 'package:skin_type_app/features/natural%20ingredients/views/screens/natural_ingredients_screen.dart';
import 'package:skin_type_app/core/services/scan_service.dart';
import 'package:camera/camera.dart';
import '../widgets/product_card.dart';
import '../widgets/info_section_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  final String _apiUrl =
      'https://backend-server-skin-app--vertex-api-c4832.us-central1.hosted.app/analyze-skin';
  File? _selectedImage;
  String _resultText = '';
  bool _isLoading = false;
  List<String> _belirtiler = [];
  List<String> _ihtiyaclar = [];
  List<String> _kimyasalIcerikler = [];
  String _cilt_tipi = '';
  String _cilt_tipi_benzerlik_yuzdesi = '';

  @override
  void initState() {
    super.initState();
    _loadDatabase();
  }

  Future<void> _loadDatabase() async {
    final storage = SkinAnalysisStorage();
    final loadedData = await storage.loadAnalysisData();
    String? savedImagePath = await storage.loadFaceImagePath();

    // 📌 KAYITLI RESİM YOLUNU YÜKLE
    if (savedImagePath != null) {
      File imageFile = File(savedImagePath);
      bool fileExists = await imageFile.exists();

      if (fileExists && mounted) {
        setState(() {
          _selectedImage = imageFile;
        });
        print("✅ Kayıtlı resim yüklendi: $savedImagePath");
      } else {
        print("⚠️ Resim dosyası bulunamadı, kayıt temizleniyor");
        await storage.saveFaceImagePath(null);
      }
    }

    if (loadedData != null) {
      if (mounted) {
        setState(() {
          _belirtiler = List<String>.from(loadedData['belirtiler'] ?? []);
          _ihtiyaclar = List<String>.from(loadedData['ihtiyaclar'] ?? []);
          _cilt_tipi = loadedData['cilt_tipi'] ?? "Bilinmiyor";
          _cilt_tipi_benzerlik_yuzdesi =
              loadedData['cilt_tipi_benzerlik_yuzdesi'] ?? "Bilinmiyor";
          _kimyasalIcerikler = List<String>.from(
            loadedData['kimyasal_aktif_icerikler'] ?? [],
          );
        });
      }
    }
  }

  Future<void> _pickImageAndSend() async {
    if (_isLoading) {
      return;
    }

    // 1. ÖNCE KAMERALARI BUL
    String? imagePath;
    try {
      final cameras = await availableCameras();
      final frontCamera = cameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.front,
        orElse: () => cameras.first,
      );

      // 2. FOTOĞRAF ÇEKİMİ
      if (!mounted) return;
      imagePath = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => FaceScanScreen(camera: frontCamera),
        ),
      );
    } catch (e) {
      print("Kamera hatası: $e");
      return;
    }

    if (imagePath == null) return;

    setState(() {
      _isLoading = true;
    });

    // --- YÜZ TESPİTİ VE TAM ÇERÇEVE KESME ---
    FaceDetector? faceDetector;
    try {
      final options = FaceDetectorOptions(
        performanceMode: FaceDetectorMode.accurate, // En hassas mod
        enableLandmarks: false,
        enableClassification: false,
      );
      faceDetector = FaceDetector(options: options);

      final inputImage = InputImage.fromFilePath(imagePath!);
      final List<Face> faces = await faceDetector.processImage(inputImage);

      if (faces.isNotEmpty) {
        final Face mainFace = faces.first;
        final Rect boundingBox = mainFace.boundingBox;

        final File originalFile = File(imagePath!);
        final bytes = await originalFile.readAsBytes();
        img.Image? originalImage = img.decodeImage(bytes);

        if (originalImage != null) {
          // Exif düzeltmesi
          originalImage = img.bakeOrientation(originalImage);

          // --- DEĞİŞİKLİK BURADA ---
          // Padding (boşluk) hesaplamalarını tamamen sildik.
          // Doğrudan tespit edilen yüzün koordinatlarını alıyoruz.

          int x = boundingBox.left.toInt();
          int y = boundingBox.top.toInt();
          int w = boundingBox.width.toInt();
          int h = boundingBox.height.toInt();

          // GÜVENLİK KONTROLÜ:
          // Bazen tespit edilen koordinatlar resmin sınırının 1-2 piksel dışına çıkabilir.
          // Uygulamanın çökmemesi için sınırları resim boyutuna sabitliyoruz.
          if (x < 0) x = 0;
          if (y < 0) y = 0;
          if (x + w > originalImage.width) w = originalImage.width - x;
          if (y + h > originalImage.height) h = originalImage.height - y;

          // Resmi tam yüz sınırlarından kes
          final img.Image croppedImage = img.copyCrop(
            originalImage,
            x: x,
            y: y,
            width: w,
            height: h,
          );

          // Kaydet
          final String croppedPath = imagePath!.replaceFirst(
            '.jpg',
            '_face_only.jpg',
          );
          final File croppedFile = File(croppedPath)
            ..writeAsBytesSync(img.encodeJpg(croppedImage));

          imagePath = croppedFile.path;
        }
      }
    } catch (e) {
      print("Yüz işleme hatası: $e");
    } finally {
      faceDetector?.close();
    }
    // -------------------------------------------------------

    setState(() {
      _selectedImage = File(imagePath!);
      _resultText = '';
    });

    // API İSTEĞİ (Burası aynı kalıyor)
    try {
      final request = http.MultipartRequest('POST', Uri.parse(_apiUrl));
      request.files.add(
        await http.MultipartFile.fromPath('image', _selectedImage!.path),
      );

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

        final scanService = ScanService();
        await scanService.saveScan(
          apiResponse: apiResponseData,
          imagePath: _selectedImage!.path,
        );

        await storage.deleteRoutineStatus();
        await storage.saveFaceImagePath(_selectedImage!.path);
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
                    titleIcon: Icons.warning_amber_rounded,
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
                    titleIcon: Icons.check_circle_outline,
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
                            Text(
                              "Skin Type",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _cilt_tipi,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                _cilt_tipi_benzerlik_yuzdesi,
                                style: TextStyle(
                                  color: Colors.green,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 25),

                  // 4. RECOMMENDED FOR YOU
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Recommended For You",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const NaturalIngredientsScreen(), // Hedef Ekran
                            ),
                          );
                        },
                        child: Text(
                          "See All",
                          style: TextStyle(
                            color: AppColors.primaryPurple,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),

                  // Yatay Liste
                  SizedBox(
                    height: 350,
                    child: _kimyasalIcerikler.isEmpty
                        ? const Center(
                            child: Text("Veri bekleniyor..."),
                          ) // Liste boşsa bu çalışır
                        : ListView.builder(
                            // Liste doluysa burası çalışır
                            scrollDirection: Axis.horizontal,
                            itemCount: _kimyasalIcerikler.length,
                            itemBuilder: (context, index) {
                              // Listedeki sıradaki içeriği al
                              final icerikAdi = _kimyasalIcerikler[index];

                              return ProductCard(
                                title:
                                    icerikAdi, // API'den gelen isim (Örn: Salicylic Acid)
                                subtitle: "Active Ingredient",
                                tagColor: Colors.blueAccent,
                                tagText: "RECOMMENDED",
                                desc:
                                    "Based on your skin analysis, this ingredient is recommended.",
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
                      gradient: const LinearGradient(
                        colors: [
                          AppColors.accentPurple,
                          AppColors.primaryPurple,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      children: [
                        const Icon(
                          Icons.calendar_month,
                          color: Colors.white,
                          size: 40,
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          "Start Your Journey",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: () {
                            // SAYFA GEÇİŞ KODU BURADA
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const WeeklyRoutineScreen(), // Hedef Ekran
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: AppColors.accentPurple,
                          ),
                          child: const Text("See your individual routine!"),
                        ),
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
                          ? Image.file(_selectedImage!, fit: BoxFit.cover)
                          : const Icon(
                              Icons.face,
                              size: 80,
                              color: Colors.grey,
                            ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 15,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: AppColors.primaryPurple,
                        width: 2,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (_isLoading)
                          const SizedBox(
                            width: 14,
                            height: 14,
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                AppColors.primaryPurple,
                              ),
                              strokeWidth: 2,
                            ),
                          ),
                        if (_isLoading) const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            _isLoading
                                ? 'Analiz ediliyor...'
                                : (_resultText.isNotEmpty
                                      ? _resultText
                                      : 'Fotoğraf seçmek için dokun'),
                            style: const TextStyle(
                              color: AppColors.primaryPurple,
                              fontWeight: FontWeight.bold,
                            ),
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
          const Text(
            'Analysis Results',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
