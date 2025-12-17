import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ================= LOGIN =================
  Future<UserCredential> login({
    required String email,
    required String password,
  }) async {
    return await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  // ================= REGISTER =================
  Future<UserCredential> register({
    required String email,
    required String password,
    required DateTime dateOfBirth,
  }) async {
    // 1. Auth kaydı
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    final uid = credential.user!.uid;

    // 2. Firestore user document
    await _firestore.collection('users').doc(uid).set({
      'email': email,
      'dateOfBirth': Timestamp.fromDate(dateOfBirth),
      'createdAt': FieldValue.serverTimestamp(),
    });

    return credential;
  }

  // ================= LOGOUT =================
  Future<void> logout() async {
    await _auth.signOut();
  }
}
