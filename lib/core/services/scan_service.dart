import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:skin_type_app/models/scan_model.dart'; // Model dosyanızın yolu

class ScanService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Veriyi Kaydetme (Mevcut kodunuz)
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
        .doc();

    await scanRef.set({
      'meta': {'source': 'gallery', 'model': apiResponse['model'] ?? 'unknown'},
      // Ana verileri 'raw_ai_output' içine veya doğrudan root'a kaydedebiliriz.
      // Sizin yapınızda 'raw_ai_output' kullanılmış, okurken oradan okuyacağız.
      'raw_ai_output': apiResponse,
      'image_path': imagePath,
      'created_at': FieldValue.serverTimestamp(),
    });
  }

  // YENİ EKLENEN: Verileri Çekme (Stream ile anlık takip)
  Stream<List<ScanResult>> getScans() {
    final user = _auth.currentUser;

    if (user == null) {
      return const Stream.empty();
    }

    return _firestore
        .collection('users')
        .doc(user.uid)
        .collection('scans')
        .orderBy('created_at', descending: true) // En yeni en üstte
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            // Firestore dökümanını ScanResult modeline çeviriyoruz
            return ScanResult.fromFirestore(doc);
          }).toList();
        });
  }
}
