import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:skin_type_app/models/scan_model.dart';

class ScanService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // 1. Veriyi Kaydetme
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
      'raw_ai_output': apiResponse,
      'image_path': imagePath,
      'created_at': FieldValue.serverTimestamp(),
    });
  }

  // 2. Tüm Taramaları Çekme - Stream
  Stream<List<ScanResult>> getScans() {
    final user = _auth.currentUser;

    if (user == null) {
      return const Stream.empty();
    }

    return _firestore
        .collection('users')
        .doc(user.uid)
        .collection('scans')
        .orderBy('created_at', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            return ScanResult.fromFirestore(doc);
          }).toList();
        });
  }

  // 3. Belirli bir scan altındaki favorileri getiren stream
  Stream<List<Map<String, dynamic>>> getFavorites(
    String scanId,
    String collectionName,
  ) {
    final user = _auth.currentUser;
    if (user == null) return const Stream.empty();

    return _firestore
        .collection('users')
        .doc(user.uid)
        .collection('scans')
        .doc(scanId)
        .collection(
          collectionName,
        ) // 'kimyasal_favoriler' veya 'dogal_favoriler'
        .orderBy('saved_at', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
  }

  // 4. En son taramayı getiren metod (Limitli)
  Stream<List<ScanResult>> getRecentScans(int limit) {
    final user = _auth.currentUser;

    if (user == null) {
      return const Stream.empty();
    }

    return _firestore
        .collection('users')
        .doc(user.uid)
        .collection('scans')
        .orderBy('created_at', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            return ScanResult.fromFirestore(doc);
          }).toList();
        });
  }

  // 5. Favorilerden Ürün Kaldırma (Yeni Eklendi)
  // Bu metod çağrıldığında Firestore'daki doküman silinir ve anlık dinleyiciler (stream) sayesinde UI otomatik güncellenir.
  Future<void> removeFavorite({
    required String scanId,
    required String collectionName,
    required String ingredientName,
  }) async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('scans')
          .doc(scanId)
          .collection(collectionName)
          .doc(ingredientName)
          .delete();

      print("✅ $ingredientName favorilerden kaldırıldı.");
    } catch (e) {
      print("❌ Favori kaldırma hatası: $e");
    }
  }
}
