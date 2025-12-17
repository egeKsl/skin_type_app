class ScanResult {
  final String date; // Tarama tarihi
  final String ciltTipi;
  final String benzerlikYuzdesi;
  final List<String> belirtiler;
  final List<String> ihtiyaclar;
  final List<String> dogalIcerikler;
  final List<String> kimyasalIcerikler;
  final List<String> makyajOnerileri;
  final List<String> makyajUzakDurulacaklar;

  ScanResult({
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

  // JSON'dan nesne oluşturma (Simülasyon için)
  factory ScanResult.fromJson(Map<String, dynamic> json) {
    return ScanResult(
      date: json['date'] ?? DateTime.now().toString().split(' ')[0],
      ciltTipi: json['cilt_tipi'] ?? '',
      benzerlikYuzdesi: json['cilt_tipi_benzerlik_yuzdesi'] ?? '',
      belirtiler: List<String>.from(json['belirtiler'] ?? []),
      ihtiyaclar: List<String>.from(json['ihtiyaclar'] ?? []),
      dogalIcerikler: List<String>.from(json['dogal_icerikler'] ?? []),
      kimyasalIcerikler: List<String>.from(
        json['kimyasal_aktif_icerikler'] ?? [],
      ),
      makyajOnerileri: List<String>.from(
        json['makyaj_kullanilmasi_gerekenler'] ?? [],
      ),
      makyajUzakDurulacaklar: List<String>.from(
        json['makyaj_uzak_durulmasi_gerekenler'] ?? [],
      ),
    );
  }
}
