import 'package:cloud_firestore/cloud_firestore.dart';

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ================= CREATE USER =================
  Future<void> createUser({
    required String uid,
    required String email,
    required DateTime dateOfBirth,
  }) async {
    await _firestore.collection('users').doc(uid).set({
      'email': email,
      'born_date': Timestamp.fromDate(dateOfBirth),
      'created_at': FieldValue.serverTimestamp(),
    });
  }

  // ================= GET USER =================
  Future<DocumentSnapshot<Map<String, dynamic>>> getUser(String uid) {
    return _firestore.collection('users').doc(uid).get();
  }
}
