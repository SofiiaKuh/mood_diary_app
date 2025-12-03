import 'package:firebase_auth/firebase_auth.dart';

class AuthRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> signUp({required String email, required String password}) async {
    try {
      await _auth.createUserWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch (e) {
      throw e.message ?? 'Помилка при реєстрації';
    }
  }

  Future<void> signIn({required String email, required String password}) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch (e) {
      throw e.message ?? 'Помилка при вході';
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  String? getUsername() {
    final user = _auth.currentUser;
    if (user != null && user.email != null) {
      return user.email!.split('@')[0];
    }
    return null;
  }
}
