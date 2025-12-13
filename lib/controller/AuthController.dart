import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Connexion avec email + mot de passe
  Future<User?> signInWithEmail(String email, String password) async {
    final userCredential = await _auth.signInWithEmailAndPassword(
        email: email, password: password);
    return userCredential.user;
  }

  void signInWithPhone(String phoneNumber) {
    FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: (PhoneAuthCredential credential) async {
        await FirebaseAuth.instance.signInWithCredential(credential);
      },
      verificationFailed: (FirebaseAuthException e) {},
      codeSent: (String verificationId, int? resendToken) {
        // stocke verificationId pour la 2e étape
      },
      codeAutoRetrievalTimeout: (String verificationId) {},
    );
  }

  // Création d’un compte
  Future<User?> signUpWithEmail(String email, String password) async {
    final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email, password: password);
    return userCredential.user;
  }

  // Déconnexion
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Observer l’état de l’utilisateur
  Stream<User?> authStateChanges() => _auth.authStateChanges();
}
