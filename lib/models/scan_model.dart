import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class ScanResult {
  final String id;
  final String date;
  final String ciltTipi;
  final String benzerlikYuzdesi;
  final List<String> belirtiler;
  final List<String> ihtiyaclar;
  final List<String> dogalIcerikler;
  final List<String> kimyasalIcerikler;
  final List<String> makyajOnerileri;
  final List<String> makyajUzakDurulacaklar;
  final String? imagePath; // <-- YENİ EKLENDİ

  ScanResult({
    this.id = '',
    required this.date,
    required this.ciltTipi,
    required this.benzerlikYuzdesi,
    required this.belirtiler,
    required this.ihtiyaclar,
    required this.dogalIcerikler,
    required this.kimyasalIcerikler,
    required this.makyajOnerileri,
    required this.makyajUzakDurulacaklar,
    this.imagePath, // <-- YENİ EKLENDİ
  });

  factory ScanResult.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    Map<String, dynamic> aiData = data['raw_ai_output'] ?? {};

    String dateStr = "Unknown Date";
    if (data['created_at'] != null) {
      Timestamp timestamp = data['created_at'];
      DateTime dateTime = timestamp.toDate();
      dateStr = DateFormat('dd MMM yyyy, HH:mm').format(dateTime);
    }

    return ScanResult(
      id: doc.id,
      date: dateStr,
      ciltTipi: aiData['cilt_tipi'] ?? 'Bilinmiyor',
      benzerlikYuzdesi: aiData['cilt_tipi_benzerlik_yuzdesi'] ?? '',
      belirtiler: List<String>.from(aiData['belirtiler'] ?? []),
      ihtiyaclar: List<String>.from(aiData['ihtiyaclar'] ?? []),
      dogalIcerikler: List<String>.from(aiData['dogal_icerikler'] ?? []),
      kimyasalIcerikler: List<String>.from(
        aiData['kimyasal_aktif_icerikler'] ?? [],
      ),
      makyajOnerileri: List<String>.from(
        aiData['makyaj_kullanilmasi_gerekenler'] ?? [],
      ),
      makyajUzakDurulacaklar: List<String>.from(
        aiData['makyaj_uzak_durulmasi_gerekenler'] ?? [],
      ),
      imagePath:
          data['image_path'], // <-- YENİ EKLENDİ (Veritabanından çekiyoruz)
    );
  }
}
