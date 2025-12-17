import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ScanService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> saveScan({
    required Map<String, dynamic> apiResponse,
    required String imagePath,
  }) async {
    final user = _auth.currentUser;

    if (user == null) {
      throw Exception("User not authenticated");
    }

    final scanRef = _firestore
        .collection('users')
        .doc(user.uid)
        .collection('scans')
        .doc(); // otomatik scanId

    await scanRef.set({
      'meta': {'source': 'gallery', 'model': apiResponse['model'] ?? 'unknown'},
      'result': apiResponse['result'] ?? {},
      'routine': apiResponse['routine'] ?? {},
      'raw_ai_output': apiResponse,
      'image_path': imagePath,
      'created_at': FieldValue.serverTimestamp(),
    });
  }
}
