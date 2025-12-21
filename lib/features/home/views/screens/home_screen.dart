import 'dart:convert';
import 'dart:io';
import 'package:image/image.dart' as img;
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart'; // Dinamik güncellemeler için eklendi
import 'package:cloud_firestore/cloud_firestore.dart'; // Dinamik güncellemeler için eklendi
import 'package:skin_type_app/constants/app_colors.dart';
import 'package:skin_type_app/common/widgets/top_menu_overlay.dart';
import 'package:skin_type_app/core/database/data_service.dart';
import 'package:skin_type_app/features/Weekly Routine/views/screens/weekly_routine_screen.dart';
import 'package:skin_type_app/features/face scan/views/screens/face_scan_screen.dart';
import 'package:skin_type_app/core/services/scan_service.dart';
import 'package:skin_type_app/models/scan_model.dart';
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
  final ScanService _scanService = ScanService();
  File? _selectedImage;
  String _resultText = '';
  bool _isLoading = false;
  List<String> _belirtiler = [];
  List<String> _ihtiyaclar = [];
  List<Map<String, dynamic>> _allIngredients = [];
  String _cilt_tipi = '';
  String _cilt_tipi_benzerlik_yuzdesi = '';

  // Profil fotoğrafı için değişken
  String? _profileImagePath;

  @override
  void initState() {
    super.initState();
    _loadFirebaseData();
    _listenUserProfileChanges(); // Tek seferlik yükleme yerine dinleyiciyi başlat
  }

  // Firestore'dan profil dökümanını canlı olarak dinler
  // Bu sayede profil fotosu değiştiği anda ana ekrana yansır
  void _listenUserProfileChanges() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .snapshots()
        .listen(
          (doc) {
            if (doc.exists && mounted) {
              final data = doc.data() as Map<String, dynamic>;
              setState(() {
                _profileImagePath = data['profile_image_path'];
              });
              print("✅ Profile image updated reactively: $_profileImagePath");
            }
          },
          onError: (e) {
            print("❌ Error listening to profile changes: $e");
          },
        );
  }

  void _loadFirebaseData() {
    _scanService
        .getRecentScans(1)
        .listen(
          (scans) {
            if (scans.isNotEmpty && mounted) {
              final ScanResult lastScan = scans.first;
              setState(() {
                _belirtiler = lastScan.belirtiler;
                _ihtiyaclar = lastScan.ihtiyaclar;
                _cilt_tipi = lastScan.ciltTipi;
                _cilt_tipi_benzerlik_yuzdesi = lastScan.benzerlikYuzdesi;

                _allIngredients = [];
                for (var item in lastScan.kimyasalIcerikler) {
                  _allIngredients.add({
                    ...item as Map<String, dynamic>,
                    'type': 'Active Ingredient',
                  });
                }
                for (var item in lastScan.dogalIcerikler) {
                  _allIngredients.add({
                    ...item as Map<String, dynamic>,
                    'type': 'Natural Ingredient',
                  });
                }

                _isLoading = false;
              });
              print("✅ Firebase scan data synchronized");
            }
          },
          onError: (error) {
            print("❌ Error fetching scan data: $error");
          },
        );
  }

  Future<void> _pickImageAndSend() async {
    if (_isLoading) return;

    String? imagePath;
    try {
      final cameras = await availableCameras();
      final frontCamera = cameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.front,
        orElse: () => cameras.first,
      );

      if (!mounted) return;
      imagePath = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => FaceScanScreen(camera: frontCamera),
        ),
      );
    } catch (e) {
      print("Camera error: $e");
      return;
    }

    if (imagePath == null) return;

    setState(() {
      _isLoading = true;
    });

    FaceDetector? faceDetector;
    try {
      final options = FaceDetectorOptions(
        performanceMode: FaceDetectorMode.accurate,
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
          originalImage = img.bakeOrientation(originalImage);

          int x = boundingBox.left.toInt();
          int y = boundingBox.top.toInt();
          int w = boundingBox.width.toInt();
          int h = boundingBox.height.toInt();

          if (x < 0) x = 0;
          if (y < 0) y = 0;
          if (x + w > originalImage.width) w = originalImage.width - x;
          if (y + h > originalImage.height) h = originalImage.height - y;

          final img.Image croppedImage = img.copyCrop(
            originalImage,
            x: x,
            y: y,
            width: w,
            height: h,
          );

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
      print("Face processing error: $e");
    } finally {
      faceDetector?.close();
    }

    setState(() {
      _selectedImage = File(imagePath!);
    });

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
        await _scanService.saveScan(
          apiResponse: apiResponseData,
          imagePath: _selectedImage!.path,
        );

        await storage.deleteRoutineStatus();
        await storage.saveFaceImagePath(_selectedImage!.path);
      } else {
        print("API ERROR: ${response.statusCode} | $responseBody");
      }
    } catch (error) {
      print("Occurred error: $error");
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
            _buildCollapsedHeader(),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  InfoSectionCard(
                    title: "Current Issues",
                    count: _belirtiler.length.toString(),
                    color: const Color(0xFFFFEBEE),
                    iconColor: Colors.red,
                    items: _belirtiler.isEmpty
                        ? ["data is being waiting..."]
                        : _belirtiler,
                    titleIcon: Icons.warning_amber_rounded,
                  ),
                  const SizedBox(height: 15),
                  InfoSectionCard(
                    title: "Needs",
                    count: _ihtiyaclar.length.toString(),
                    color: const Color(0xFFFFF3E0),
                    iconColor: Colors.orange,
                    items: _ihtiyaclar.isEmpty
                        ? ["data is being waiting..."]
                        : _ihtiyaclar,
                    titleIcon: Icons.check_circle_outline,
                  ),
                  const SizedBox(height: 15),
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
                              style: const TextStyle(
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
                                style: const TextStyle(
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Text(
                        "Recommended For You",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),
                  SizedBox(
                    height: 260,
                    child: _allIngredients.isEmpty
                        ? const Center(child: Text("data is being waiting..."))
                        : ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: _allIngredients.length,
                            itemBuilder: (context, index) {
                              final item = _allIngredients[index];
                              final String isim =
                                  item['isim'] ?? "Unknown ingredient";
                              final String analiz =
                                  item['ai_analizi'] ??
                                  "Suggested based on your skin type.";
                              final String type = item['type'] ?? "Ingredient";

                              return ProductCard(
                                title: isim,
                                subtitle: type,
                                tagColor: type == 'Active Ingredient'
                                    ? Colors.blueAccent
                                    : Colors.green,
                                tagText: "suggested for you",
                                desc: analiz,
                              );
                            },
                          ),
                  ),
                  const SizedBox(height: 30),
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
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const WeeklyRoutineScreen(),
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

  Widget _buildCollapsedHeader() {
    return Container(
      padding: const EdgeInsets.only(top: 40, bottom: 20),
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
                GestureDetector(
                  onTap: () => showTopMenuOverlay(context),
                  child: const Icon(Icons.menu, color: Colors.black),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          GestureDetector(
            onTap: _pickImageAndSend,
            child: Container(
              height: 250,
              width: double.infinity,
              color: Colors.grey[100],
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ClipOval(
                    child: Container(
                      width: 150,
                      height: 150,
                      color: Colors.grey[300],
                      child:
                          (_profileImagePath != null &&
                              File(_profileImagePath!).existsSync())
                          ? Image.file(
                              File(_profileImagePath!),
                              fit: BoxFit.cover,
                            )
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
                            _isLoading ? 'Analyzing...' : 'Click to analysis',
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
