import 'package:firebase_auth/firebase_auth.dart';

class AuthController {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Connexion avec email + mot de passe
  Future<User?> signInWithEmail(String email, String password) async {
    final userCredential = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    return userCredential.user;
  }

  // Création d’un compte
  Future<User?> signUpWithEmail(String email, String password) async {
    final userCredential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    return userCredential.user;
  }

  // Déconnexion
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Observer l’état de l’utilisateur
  Stream<User?> authStateChanges() => _auth.authStateChanges();
  /*
  Future<void> signInWithPhone(
    String phoneNumber, {
    required Function(String verificationId) onCodeSent,
  }) async {
    await FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: (PhoneAuthCredential credential) async {
        await FirebaseAuth.instance.signInWithCredential(credential);
      },
      verificationFailed: (FirebaseAuthException e) {
        print('Erreur vérification : ${e.message}');
      },
      codeSent: (String verificationId, int? resendToken) {
        onCodeSent(verificationId);
      },
      codeAutoRetrievalTimeout: (String verificationId) {},
    );
  }
  //////////////auth-tel dans view
  Future<void> _signIn() async {
    setState(() => _isLoading = true);

    try {
      if (isPhone) {
        if (_phoneController.text.isEmpty) {
          _showSnack("Numéro de téléphone obligatoire");
          return;
        }
        String phoneNumber = '+216${_phoneController.text.trim()}';
        await _loginWithPhone(phoneNumber);
      } else {
        if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
          _showSnack("Email et mot de passe obligatoires");
          return;
        }
        final user = await _loginWithEmail(
          _emailController.text.trim(),
          _passwordController.text.trim(),
        );

        if (user == null) {
          _showSnack("Utilisateur introuvable");
          return;
        }

        final userProfile = await _fetchUserProfile(user.uid);
        if (userProfile == null) {
          _showSnack("Profil utilisateur introuvable");
          return;
        }

        _updateAppState(userProfile);
        Navigator.pushReplacementNamed(context, '/home');
      }
    } on FirebaseAuthException catch (e) {
      _handleAuthError(e);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loginWithPhone(String phoneNumber) async {
    final authController = AuthController();

    await authController.signInWithPhone(
      phoneNumber,
      onCodeSent: (verificationId) async {
        final smsCode = await _showCodeInputDialog();
        if (smsCode == null || smsCode.isEmpty) {
          _showSnack("Vous devez entrer le code SMS");
          return;
        }
        try {
          final credential = PhoneAuthProvider.credential(
            verificationId: verificationId,
            smsCode: smsCode,
          );

          final userCredential = await FirebaseAuth.instance
              .signInWithCredential(credential);

          if (userCredential.user == null) {
            _showSnack("Impossible de récupérer l'utilisateur");
            return;
          }

          final userProfile = await _fetchUserProfile(userCredential.user!.uid);
          if (userProfile != null) {
            _updateAppState(userProfile);
            Navigator.pushReplacementNamed(context, '/home');
          } else {
            _showSnack("Profil utilisateur introuvable");
          }
        } catch (e) {
          _showSnack("Erreur connexion : ${e.toString()}");
        }
      },
    );
  }

  Future<String?> _showCodeInputDialog() async {
    String code = '';
    return await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text('Entrez le code SMS'),
        content: TextField(
          keyboardType: TextInputType.number,
          onChanged: (value) => code = value,
          decoration: InputDecoration(hintText: 'Code'),
        ),
        actions: [
          TextButton(
            onPressed: () =>
                Navigator.of(context).pop(code), // renvoie le code ici
            child: Text('Valider'),
          ),
        ],
      ),
    );
  }


  */
}
