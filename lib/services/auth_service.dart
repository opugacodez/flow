import 'package:firebase_auth/firebase_auth.dart' as firebase;
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final firebase.FirebaseAuth _auth = firebase.FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<firebase.User?> get authStateChanges => _auth.authStateChanges();

  Future<void> signUp({
    required String email,
    required String password,
    required String name,
    required String phone,
  }) async {
    try {
      firebase.UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'name': name,
        'email': email,
        'phone': phone,
      });
    } catch (e) {
      throw Exception('Ocorreu um erro durante o cadastro. Tente novamente.');
    }
  }

  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
    } catch (e) {
      throw Exception('Ocorreu um erro durante o login. Tente novamente.');
    }
  }

  Future<void> recoverPassword({String? email}) async {
    try {
      await _auth.sendPasswordResetEmail(email: email!);
    } catch (e) {
      throw Exception('Ocorreu um erro ao tentar recuperar a senha.');
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }
  
  firebase.User? getCurrentUser() {
    return _auth.currentUser;
  }

  Future<Map<String, dynamic>?> getUserData(String uid) async {
    try {
      DocumentSnapshot doc = await _firestore.collection('users').doc(uid).get();
      return doc.data() as Map<String, dynamic>?;
    } catch (e) {
      return null;
    }
  }
}