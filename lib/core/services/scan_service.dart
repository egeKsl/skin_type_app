import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:skin_type_app/models/scan_model.dart';

class ScanService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // 1. Tarama Sonucunu Kaydetme
  Future<void> saveScan({
    required Map<String, dynamic> apiResponse,
    required String imagePath,
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception("Kullanıcı kimliği doğrulanmadı");

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

  // 2. Kullanıcı Profil Bilgilerini Güncelleme (profileImagePath eklendi)
  Future<void> updateUserProfile({
    required String fullName,
    required String bornDate,
    required String gender,
    String? profileImagePath,
  }) async {
    final user = _auth.currentUser;
    if (user == null) return;

    await _firestore.collection('users').doc(user.uid).set({
      'full_name': fullName,
      'born_date': bornDate,
      'gender': gender,
      if (profileImagePath != null) 'profile_image_path': profileImagePath,
      'updated_at': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  // 3. Kullanıcı Profil Bilgilerini Getirme
  Future<DocumentSnapshot?> getUserProfile() async {
    final user = _auth.currentUser;
    if (user == null) return null;
    return await _firestore.collection('users').doc(user.uid).get();
  }

  // 4. Tüm Taramaları Getir - Stream
  Stream<List<ScanResult>> getScans() {
    final user = _auth.currentUser;
    if (user == null) return const Stream.empty();

    return _firestore
        .collection('users')
        .doc(user.uid)
        .collection('scans')
        .orderBy('created_at', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => ScanResult.fromFirestore(doc))
              .toList();
        });
  }

  // 5. Belirli Bir Tarama Altındaki Favorileri Getir - Stream
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
        .collection(collectionName)
        .orderBy('saved_at', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
  }

  // 6. Son Taramaları Getir (Limitli)
  Stream<List<ScanResult>> getRecentScans(int limit) {
    final user = _auth.currentUser;
    if (user == null) return const Stream.empty();

    return _firestore
        .collection('users')
        .doc(user.uid)
        .collection('scans')
        .orderBy('created_at', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => ScanResult.fromFirestore(doc))
              .toList();
        });
  }

  // 7. Favorilerden Ürün Kaldırma
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
