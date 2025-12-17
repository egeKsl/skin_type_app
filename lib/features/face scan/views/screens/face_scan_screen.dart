import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

class FaceScanScreen extends StatefulWidget {
  final CameraDescription camera;

  const FaceScanScreen({super.key, required this.camera});

  @override
  State<FaceScanScreen> createState() => _FaceScanScreenState();
}

class _FaceScanScreenState extends State<FaceScanScreen> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;

  @override
  void initState() {
    super.initState();
    // Kamerayı başlat (Yüksek çözünürlük yerine orta seçiyoruz, yüz analizi için yeterli ve hızlı)
    _controller = CameraController(
      widget.camera,
      ResolutionPreset.medium,
      enableAudio: false,
    );
    _initializeControllerFuture = _controller.initialize();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return Stack(
              children: [
                // 1. KAMERA GÖRÜNTÜSÜ
                SizedBox(
                  width: double.infinity,
                  height: double.infinity,
                  child: CameraPreview(_controller),
                ),

                // 2. YÜZ KLAVUZU (OVERLAY)
                CustomPaint(size: Size.infinite, painter: FaceGuidePainter()),

                // 3. GERİ BUTONU VE BAŞLIK
                Positioned(
                  top: 50,
                  left: 20,
                  child: IconButton(
                    icon: const Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 30,
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
                const Positioned(
                  top: 65,
                  left: 0,
                  right: 0,
                  child: Text(
                    "Yüzünü çerçeveye yerleştir",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      shadows: [Shadow(blurRadius: 10, color: Colors.black)],
                    ),
                  ),
                ),

                // 4. ÇEKİM BUTONU
                Positioned(
                  bottom: 40,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: GestureDetector(
                      onTap: () async {
                        try {
                          await _initializeControllerFuture;
                          final image = await _controller.takePicture();
                          // Fotoğraf çekildi, yolu geri döndür
                          if (!mounted) return;
                          Navigator.pop(context, image.path);
                        } catch (e) {
                          print(e);
                        }
                      },
                      child: Container(
                        height: 80,
                        width: 80,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 4),
                          color: Colors.white.withOpacity(0.3),
                        ),
                        child: Center(
                          child: Container(
                            height: 60,
                            width: 60,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}

// Yüz maskesini çizen özel ressam (Painter)
class FaceGuidePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black.withOpacity(0.6); // Karartma rengi

    // Tüm ekranı kaplayan bir dikdörtgen oluştur
    final backgroundPath = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height));

    // Ortada bir oval (yüz şekli) oluştur
    final maskPath = Path()
      ..addOval(
        Rect.fromCenter(
          center: Offset(
            size.width / 2,
            size.height / 2 - 50,
          ), // Biraz yukarıda olsun
          width: size.width * 0.75, // Genişlik
          height: size.height * 0.55, // Yükseklik
        ),
      );

    // Arkaplandan ovali çıkar (Delik açma işlemi)
    final path = Path.combine(
      PathOperation.difference,
      backgroundPath,
      maskPath,
    );

    // Çiz
    canvas.drawPath(path, paint);

    // Ovalin kenarına beyaz çizgi çek (Kılavuz çizgisi)
    final borderPaint = Paint()
      ..color = Colors.white.withOpacity(0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.width / 2, size.height / 2 - 50),
        width: size.width * 0.75,
        height: size.height * 0.55,
      ),
      borderPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
