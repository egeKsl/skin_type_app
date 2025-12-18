import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class ScanResult {
  final String id;
  final String date;
  final String ciltTipi;
  final String benzerlikYuzdesi;
  final List<String> belirtiler;
  final List<String> ihtiyaclar;
  // Detaylı nesne listeleri (isim, ai_analizi, faydalar vb. içerir)
  final List<dynamic> dogalIcerikler;
  final List<dynamic> kimyasalIcerikler;
  // Favori olarak işaretlenmiş içeriklerin isimlerini tutan listeler
  final List<String> dogalFavoriler;
  final List<String> kimyasalFavoriler;
  final List<String> makyajOnerileri;
  final List<String> makyajUzakDurulacaklar;
  final Map<String, dynamic> rutin; // Sabah ve akşam rutinlerini içeren harita
  final String? imagePath;

  ScanResult({
    this.id = '',
    required this.date,
    required this.ciltTipi,
    required this.benzerlikYuzdesi,
    required this.belirtiler,
    required this.ihtiyaclar,
    required this.dogalIcerikler,
    required this.kimyasalIcerikler,
    this.dogalFavoriler = const [],
    this.kimyasalFavoriler = const [],
    required this.makyajOnerileri,
    required this.makyajUzakDurulacaklar,
    required this.rutin,
    this.imagePath,
  });

  factory ScanResult.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    // Firestore'da 'raw_ai_output' altında sakladığımız AI yanıtını alıyoruz
    Map<String, dynamic> aiData = data['raw_ai_output'] ?? {};

    // Tarih formatlama işlemi
    String dateStr = "Bilinmeyen Tarih";
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
      // Yeni nesne yapısı (Map listesi) olarak alıyoruz
      dogalIcerikler: List<dynamic>.from(aiData['dogal_icerikler'] ?? []),
      kimyasalIcerikler: List<dynamic>.from(
        aiData['kimyasal_aktif_icerikler'] ?? [],
      ),
      // Not: Alt koleksiyonlar (favoriler) bu factory içinde otomatik dolmaz.
      // Bunları ekranda StreamBuilder veya ayrı bir servis çağrısı ile doldurmalısınız.
      dogalFavoriler: [],
      kimyasalFavoriler: [],
      // Makyaj anahtar isimleri
      makyajOnerileri: List<String>.from(
        aiData['makyaj_kullanilmasi_gerekenler'] ?? [],
      ),
      makyajUzakDurulacaklar: List<String>.from(
        aiData['makyaj_uzak_durulmasi_gerekenler'] ?? [],
      ),
      // Rutin alanı sabah ve akşam olarak iki alt dal barındırıyor
      rutin: aiData['rutin'] ?? {},
      imagePath: data['image_path'],
    );
  }
}
