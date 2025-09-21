import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthRepository {
  final _auth = FirebaseAuth.instance;

  Stream<User?> get authState => _auth.authStateChanges();

  Future<UserCredential> signUpEmail(String email, String password) =>
      _auth.createUserWithEmailAndPassword(email: email, password: password);

  Future<UserCredential> signInEmail(String email, String password) =>
      _auth.signInWithEmailAndPassword(email: email, password: password);

  // Google (API v7)
  Future<UserCredential> signInGoogle() async {
    await GoogleSignIn.instance.initialize();
    final user = await GoogleSignIn.instance.authenticate();
    if (user == null) throw Exception('Inicio cancelado');
    final googleAuth = user.authentication; // según v7 no requiere await
    final cred = GoogleAuthProvider.credential(idToken: googleAuth.idToken);
    return _auth.signInWithCredential(cred);
  }

  Future<void> signOut() => _auth.signOut();
}





