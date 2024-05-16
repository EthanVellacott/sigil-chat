import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// This manages the basic functions for logging in, registering and so forth
class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _store = FirebaseFirestore.instance;

  Future<UserCredential> signInWithEmailAndPassword(
      String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
          email: email, password: password);

      validateUser(userCredential, email);

      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw Exception(e.code);
    }
  }

  Future<UserCredential> createUserWithEmailAndPassword(
      String email, String password) async {
    try {
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);

      validateUser(userCredential, email);

      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw Exception(e.code);
    }
  }

  User? getCurrentUser() {
    return _auth.currentUser;
  }

  /// Ensure that the user is in the "Users" ledger
  Future<void> validateUser(UserCredential userCredential, String email) async {
    _store
        .collection("Users")
        .doc(userCredential.user!.uid)
        .set({'uid': userCredential.user!.uid, 'email': email});
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }
}
