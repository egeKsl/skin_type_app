import 'package:cloud_firestore/cloud_firestore.dart';

class UserService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> createUserProfile({
    required String uid,
    required String email,
    required DateTime birthDate,
  }) async {
    await _db.collection('users').doc(uid).set({
      'email': email,
      'birthDate': Timestamp.fromDate(birthDate),
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
}
