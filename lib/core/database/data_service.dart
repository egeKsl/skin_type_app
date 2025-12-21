import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class SkinAnalysisStorage {
  static const String _analysisKey = 'skinAnalysisData';
  static const String _routineStatusKey = 'routineCompletedSteps';
  static const String _imagePathKey = 'lastFaceImagePath';

  Future<void> saveAnalysisData(Map<String, dynamic> jsonData) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    String jsonString = json.encode(jsonData);

    await prefs.setString(_analysisKey, jsonString);
    print("Analysis data has been saved on shared preferences.");
  }

  Future<Map<String, dynamic>?> loadAnalysisData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    String? jsonString = prefs.getString(_analysisKey);

    if (jsonString != null) {
      Map<String, dynamic> jsonData = json.decode(jsonString);
      print("Analysis data has been loaded from shared preferences");
      return jsonData;
    }

    print("There is no exist saved analysis data!.");
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
      print(
        "The path of the image of the face has been saved successfuly: $imagePath",
      );
    } else {
      await prefs.remove(_imagePathKey);
      print("The path of the image of the face has been deleted successfuly");
    }
  }

  Future<String?> loadFaceImagePath() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? imagePath = prefs.getString(_imagePathKey);

    if (imagePath != null && imagePath.isNotEmpty) {
      print(
        "The path of the saved image of the face has been found $imagePath",
      );
      return imagePath;
    } else {
      print("The path of the saved image of the face has not been found");
      return null;
    }
  }

  Future<void> deleteFaceImageData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove(_imagePathKey);
    print("The data of image of the face has been deleted");
  }
}
