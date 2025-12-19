import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:skin_type_app/models/scan_model.dart';
import 'package:intl/intl.dart';

class ScanService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // 1. Save Scan Result to Firestore
  Future<void> saveScan({
    required Map<String, dynamic> apiResponse,
    required String imagePath,
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception("User not authenticated");

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

  // 2. Update User Profile Information
  Future<void> updateUserProfile({
    required String fullName,
    required String bornDate,
    required String gender,
    String? profileImagePath,
  }) async {
    final user = _auth.currentUser;
    if (user == null) return;

    // Ensures born_date is stored as a Timestamp to prevent loading errors
    dynamic bornDateValue;
    try {
      DateTime dateTime = DateFormat('MMMM dd, yyyy').parse(bornDate);
      bornDateValue = Timestamp.fromDate(dateTime);
    } catch (e) {
      bornDateValue = bornDate;
    }

    await _firestore.collection('users').doc(user.uid).set({
      'full_name': fullName,
      'born_date': bornDateValue,
      'gender': gender,
      if (profileImagePath != null) 'profile_image_path': profileImagePath,
      'updated_at': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  // 3. Get User Profile Document
  Future<DocumentSnapshot?> getUserProfile() async {
    final user = _auth.currentUser;
    if (user == null) return null;
    try {
      return await _firestore.collection('users').doc(user.uid).get();
    } catch (e) {
      print("❌ Error getting user profile: $e");
      return null;
    }
  }

  // 4. Delete a Specific Scan Result
  Future<void> deleteScan(String scanId) async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('scans')
          .doc(scanId)
          .delete();
      print("✅ Scan record deleted: $scanId");
    } catch (e) {
      print("❌ Error deleting scan: $e");
      throw e;
    }
  }

  // 5. Get All Scans - Reactive Stream
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
              .map((doc) {
                try {
                  return ScanResult.fromFirestore(doc);
                } catch (e) {
                  print("❌ Error parsing document: $e");
                  return null;
                }
              })
              .whereType<ScanResult>()
              .toList();
        });
  }

  // 6. Get Favorite Ingredients for a Scan - Reactive Stream
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

  // 7. Get Recent Scans (Limited) - Reactive Stream
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
              .map((doc) {
                try {
                  return ScanResult.fromFirestore(doc);
                } catch (e) {
                  return null;
                }
              })
              .whereType<ScanResult>()
              .toList();
        });
  }

  // 8. Remove an Ingredient from Favorites
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
      print("✅ $ingredientName removed from favorites.");
    } catch (e) {
      print("❌ Favorite removal error: $e");
    }
  }
}
