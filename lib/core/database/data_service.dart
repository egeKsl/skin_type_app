import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class SkinAnalysisStorage {
  static const String _analysisKey = 'skinAnalysisData';

  // API'den gelen JSON verisini kaydeder
  Future<void> saveAnalysisData(Map<String, dynamic> jsonData) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    
    // Map'i JSON dizesine dönüştür
    String jsonString = json.encode(jsonData);
    
    // JSON dizesini yerel olarak kaydet
    await prefs.setString(_analysisKey, jsonString);
    print("Analiz verisi Shared Preferences'a kaydedildi.");
  }

  // Kaydedilmiş JSON verisini geri okur ve Map'e dönüştürür
  Future<Map<String, dynamic>?> loadAnalysisData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    
    // Kayıtlı JSON dizesini al
    String? jsonString = prefs.getString(_analysisKey);
    
    if (jsonString != null) {
      // JSON dizesini Dart Map'ine dönüştür
      Map<String, dynamic> jsonData = json.decode(jsonString);
      print("Analiz verisi Shared Preferences'tan yüklendi.");
      return jsonData;
    }
    
    print("Kayıtlı analiz verisi bulunamadı.");
    return null;
  }
  
}