import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class SkinAnalysisStorage {
  static const String _analysisKey = 'skinAnalysisData';
  static const String _routineStatusKey = 'routineCompletedSteps';
  static const String _imagePathKey = 'lastFaceImagePath';
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

  Future<void> saveRoutineStatus(Map<String, bool> completedSteps) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String jsonString = json.encode(completedSteps);
    await prefs.setString(_routineStatusKey, jsonString);
  }

  Future<Map<String, bool>> loadRoutineStatus() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? jsonString = prefs.getString(_routineStatusKey);

    if (jsonString != null) {
      Map<String, dynamic> decoded = json.decode(jsonString);
      return Map<String, bool>.from(decoded);
    }
    return {};
  }

  Future<bool> deleteRoutineStatus() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      bool isDeleted = await prefs.remove(_routineStatusKey);
      return isDeleted;
    } catch (e) {
      print("❌ An error has been occured: $e");
      return false;
    }
  }

  //resim
  Future<void> saveFaceImagePath(String? imagePath) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    if (imagePath != null && imagePath.isNotEmpty) {
      await prefs.setString(_imagePathKey, imagePath);
      print("✅ Yüz resmi yolu kaydedildi: $imagePath");
    } else {
      // Eğer null veya boşsa, kaydı sil
      await prefs.remove(_imagePathKey);
      print("ℹ️ Yüz resmi yolu silindi");
    }
  }

  Future<String?> loadFaceImagePath() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? imagePath = prefs.getString(_imagePathKey);

    if (imagePath != null && imagePath.isNotEmpty) {
      print("✅ Kayıtlı yüz resmi yolu bulundu: $imagePath");
      return imagePath;
    } else {
      print("ℹ️ Kayıtlı yüz resmi yolu bulunamadı");
      return null;
    }
  }

  Future<void> deleteFaceImageData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove(_imagePathKey);
    print("✅ Yüz resmi verisi silindi");
  }
}
