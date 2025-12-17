import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart'; // Tarih formatı için (pubspec.yaml'a intl ekleyin)

class ScanResult {
  final String id; // Belge ID'si
  final String date;
  final String ciltTipi;
  final String benzerlikYuzdesi;
  final List<String> belirtiler;
  final List<String> ihtiyaclar;
  final List<String> dogalIcerikler;
  final List<String> kimyasalIcerikler;
  final List<String> makyajOnerileri;
  final List<String> makyajUzakDurulacaklar;

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
  });

  // Firestore'dan gelen veriyi modele çeviren factory
  factory ScanResult.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    // Veriler 'raw_ai_output' içinde kayıtlı olduğu için oraya bakıyoruz
    Map<String, dynamic> aiData = data['raw_ai_output'] ?? {};

    // Tarih Formatlama (Timestamp -> String)
    String dateStr = "Unknown Date";
    if (data['created_at'] != null) {
      Timestamp timestamp = data['created_at'];
      DateTime dateTime = timestamp.toDate();
      dateStr = DateFormat(
        'dd MMM yyyy, HH:mm',
      ).format(dateTime); // Örn: 12 Dec 2025, 14:30
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
    );
  }
}
