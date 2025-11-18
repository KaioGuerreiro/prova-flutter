import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Auth state changes stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Sign in with Email and Password
  Future<UserCredential?> signInWithEmail(String email, String password) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      print('Firebase Auth Error (login): ${e.code} - ${e.message}');
      if (e.code == 'configuration-not-found') {
        throw Exception(
            'Autenticação não configurada. Habilite "E-mail/Senha" no Firebase Console.');
      }
      rethrow;
    } catch (e) {
      print('Error signing in with email: $e');
      rethrow;
    }
  }

  // Register with Email and Password
  Future<UserCredential?> registerWithEmail(
      String email, String password) async {
    try {
      return await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      print('Firebase Auth Error (register): ${e.code} - ${e.message}');
      if (e.code == 'configuration-not-found') {
        throw Exception(
            'Autenticação não configurada. Habilite "E-mail/Senha" no Firebase Console em Authentication > Sign-in method.');
      }
      rethrow;
    } catch (e) {
      print('Error registering with email: $e');
      rethrow;
    }
  }

  // Sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }
}
