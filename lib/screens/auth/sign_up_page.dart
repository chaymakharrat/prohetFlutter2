// ============================================================
// IMPORTS
// ============================================================
// Widgets Material Flutter
import 'package:flutter/material.dart';
// Firebase Authentication (création de compte)
import 'package:firebase_auth/firebase_auth.dart';
// Cloud Firestore (stockage des infos utilisateur)
import 'package:projet_flutter/models/user_profile.dart';
import 'package:projet_flutter/controller/User_controller.dart';

// ============================================================
// SIGN UP PAGE (INSCRIPTION)
// ============================================================
class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

// ============================================================
// STATE DE LA PAGE
// ============================================================
class _SignUpPageState extends State<SignUpPage> {
  // ----------------------------- CONTROLLERS -----------------------------
  // Récupèrent les valeurs saisies dans les champs
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();

  // ----------------------------- CLEANUP -----------------------------
  // Libération de la mémoire des controllers
  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // ============================================================
  // FONCTION D'INSCRIPTION FIREBASE
  // ============================================================
  Future<void> signUp(
    String name,
    String email,
    String phone,
    String password,
  ) async {
    try {
      // 1. Création de l'utilisateur dans Firebase Authentication
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);

      // 2. Récupération de l'UID (identifiant unique Firebase)
      String uid = userCredential.user!.uid;
      final userService = UserService();

      // Créer le profil utilisateur
      final profile = UserProfile(
        id: uid,
        name: name,
        email: email,
        phone: phone,
      );

      // Sauvegarder le profil via le service
      try {
        await userService.createUserProfile(profile);
        print("Utilisateur ajouté à Firestore !");
      } catch (e) {
        print("Erreur Firestore : $e");
      }

      // 4. Redirection après succès
      if (mounted) {
        Navigator.pushNamed(context, '/login');
      }
    }
    // ----------------------------- GESTION DES ERREURS -----------------------------
    on FirebaseAuthException catch (e) {
      String message;
      if (e.code == 'email-already-in-use') {
        message = 'Cet email est déjà utilisé.';
      } else if (e.code == 'weak-password') {
        message = 'Le mot de passe est trop faible.';
      } else {
        message = e.message ?? 'Erreur inconnue';
      }

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(message)));
      }
    }
  }

  // ============================================================
  // UI PRINCIPALE
  // ============================================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE3F2FD),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFE3F2FD), Color(0xFFBBDEFB)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ----------------------------- TITRES -----------------------------
                  const Text(
                    'Créer un compte',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1976D2),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Rejoignez Wesalnii pour vos trajets',
                    style: TextStyle(fontSize: 14, color: Color(0xFF1976D2)),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),

                  // ----------------------------- FORMULAIRE -----------------------------
                  _buildTextField(_nameController, 'Nom complet', Icons.person),
                  const SizedBox(height: 16),
                  _buildTextField(
                    _emailController,
                    'Email',
                    Icons.email,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    _phoneController,
                    'Numéro de téléphone',
                    Icons.phone,
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    _passwordController,
                    'Mot de passe',
                    Icons.lock,
                    obscureText: true,
                  ),
                  const SizedBox(height: 24),

                  // ----------------------------- BOUTON INSCRIPTION -----------------------------
                  SizedBox(
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () {
                        // Vérification simple des champs obligatoires
                        if (_nameController.text.isEmpty ||
                            _emailController.text.isEmpty ||
                            _passwordController.text.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Veuillez remplir tous les champs'),
                            ),
                          );
                          return;
                        }

                        // Appel de la fonction d'inscription
                        signUp(
                          _nameController.text.trim(),
                          _emailController.text.trim(),
                          _phoneController.text.trim(),
                          _passwordController.text.trim(),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1976D2),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'S’inscrire',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // ----------------------------- LIEN LOGIN -----------------------------
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Vous avez déjà un compte ? ',
                        style: TextStyle(color: Color(0xFF1976D2)),
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            Navigator.pushNamed(context, '/login');
                          },
                          child: const Text(
                            'Se connecter',
                            style: TextStyle(
                              color: Color(0xFF4CAF50),
                              fontWeight: FontWeight.bold,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // WIDGET CHAMP DE TEXTE RÉUTILISABLE
  // ============================================================
  Widget _buildTextField(
    TextEditingController controller,
    String label,
    IconData icon, {
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: const Color(0xFF1976D2)),
          labelText: label,
          border: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(12)),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
      ),
    );
  }
}
