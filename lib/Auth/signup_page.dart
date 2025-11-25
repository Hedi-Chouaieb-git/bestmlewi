import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({Key? key}) : super(key: key);

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();

  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  // Méthode pour générer un code client unique
  String _generateClientCode(String name, String phone) {
    final namePart = name.length >= 3 ? name.substring(0, 3).toUpperCase() : name.toUpperCase();
    final phonePart = phone.length >= 4 ? phone.substring(phone.length - 4) : phone;
    final random = DateTime.now().millisecondsSinceEpoch.toString().substring(9);
    return 'CL${namePart}$phonePart$random';
  }

  // Méthode pour vérifier si le numéro de téléphone existe déjà
  Future<bool> _isPhoneNumberExists(String phone) async {
    try {
      final response = await Supabase.instance.client
          .from('Client')
          .select()
          .eq('phone', phone);

      return response.isNotEmpty;
    } catch (e) {
      print('Erreur vérification téléphone: $e');
      return false;
    }
  }

  // Méthode d'inscription
  Future<void> _onInscrir() async {
    if (_isLoading) return;

    final String name = _nameController.text.trim();
    final String email = _emailController.text.trim();
    final String password = _passwordController.text.trim();
    final String confirmPassword = _confirmPasswordController.text.trim();
    final String phone = _phoneController.text.trim();
    final String address = _addressController.text.trim();

    // Génération automatique du code client
    final String code = _generateClientCode(name, phone);

    // Validation des champs
    if (name.isEmpty || email.isEmpty || password.isEmpty ||
        confirmPassword.isEmpty || phone.isEmpty || address.isEmpty) {
      _showSnackBar('Veuillez remplir tous les champs');
      return;
    }

    // Validation email
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
      _showSnackBar('Veuillez entrer un email valide');
      return;
    }

    // Validation mot de passe
    if (password.length < 6) {
      _showSnackBar('Le mot de passe doit contenir au moins 6 caractères');
      return;
    }

    // Validation confirmation mot de passe
    if (password != confirmPassword) {
      _showSnackBar('Les mots de passe ne correspondent pas');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Vérifier si le numéro de téléphone existe déjà
      final bool phoneExists = await _isPhoneNumberExists(phone);
      if (phoneExists) {
        _showSnackBar('Ce numéro de téléphone est déjà utilisé');
        return;
      }

      // 1. Inscription dans l'authentification Supabase
      final AuthResponse authResponse = await Supabase.instance.client.auth.signUp(
        email: email,
        password: password,
        data: {
          'name': name,
          'phone': phone,
          'client_code': code,
        },
      );

      final User? user = authResponse.user;

      if (user != null) {
        // 2. Enregistrement dans la table client
        await _createClientInDatabase(
          userId: user.id,
          name: name,
          email: email,
          phone: phone,
          address: address,
          code: code,
        );

        _showSnackBar('Inscription réussie! Votre code client: $code');

        // Redirection vers l'écran d'accueil
        if (mounted) {
          Navigator.pushReplacementNamed(context, '/home');
        }
      } else {
        _showSnackBar('Erreur lors de la création du compte');
      }
    } on AuthException catch (e) {
      if (e.message.toLowerCase().contains('already registered')) {
        _showSnackBar('Cet email est déjà utilisé');
      } else {
        _showSnackBar('Erreur d\'authentification: ${e.message}');
      }
    } on PostgrestException catch (e) {
      if (e.code == '23505') {
        _showSnackBar('Ce numéro de téléphone est déjà utilisé');
      } else if (e.code == '42501') {
        _showSnackBar('Erreur RLS - Vérifiez les politiques de sécurité');
      } else {
        _showSnackBar('Erreur base de données: ${e.message}');
      }
    } catch (e) {
      _showSnackBar('Erreur inattendue: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _createClientInDatabase({
    required String userId,
    required String name,
    required String email,
    required String phone,
    required String address,
    required String code,
  }) async {
    await Supabase.instance.client.from('Client').insert({

      'name': name,
      'phone': phone,
      'address': address,
      'code': code,
      'createdAt': DateTime.now().toIso8601String(),
    });
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: message.toLowerCase().contains('erreur') ||
            message.toLowerCase().contains('déjà') ||
            message.toLowerCase().contains('correspondent') ||
            message.toLowerCase().contains('utilisé')
            ? Colors.red
            : Colors.green,
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 4),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Image Layer
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/group55.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),

          // Grey Overlay with Food Pattern
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              color: const Color(0xFF2B2B2B).withOpacity(0.85),
              image: DecorationImage(
                image: AssetImage('assets/images/group55.png'),
                fit: BoxFit.cover,
                opacity: 0.1,
              ),
            ),
          ),

          // Content
          SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 60),

                    // Sign Up Title
                    const Text(
                      'Sign Up',
                      style: TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFFF6B35),
                      ),
                    ),

                    const SizedBox(height: 8),

                    // Welcome Text
                    const Text(
                      'Welcome',
                      style: TextStyle(
                        fontSize: 28,
                        color: Colors.white,
                        fontWeight: FontWeight.w300,
                      ),
                    ),

                    const SizedBox(height: 50),

                    // Name Input
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF3D3D5C),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: TextField(
                        controller: _nameController,
                        style: const TextStyle(color: Colors.white),
                        decoration: const InputDecoration(
                          hintText: 'Full Name',
                          hintStyle: TextStyle(
                            color: Color(0xFF7C7C8D),
                            fontSize: 16,
                          ),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 18,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Email Input
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF3D3D5C),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: TextField(
                        controller: _emailController,
                        style: const TextStyle(color: Colors.white),
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(
                          hintText: 'Email',
                          hintStyle: TextStyle(
                            color: Color(0xFF7C7C8D),
                            fontSize: 16,
                          ),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 18,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Password Input
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF3D3D5C),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: TextField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: 'Password',
                          hintStyle: TextStyle(
                            color: Color(0xFF7C7C8D),
                            fontSize: 16,
                          ),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 18,
                          ),
                          suffixIcon: IconButton(
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              color: Color(0xFF7C7C8D),
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Confirm Password Input
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF3D3D5C),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: TextField(
                        controller: _confirmPasswordController,
                        obscureText: _obscureConfirmPassword,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: 'Confirm Password',
                          hintStyle: TextStyle(
                            color: Color(0xFF7C7C8D),
                            fontSize: 16,
                          ),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 18,
                          ),
                          suffixIcon: IconButton(
                            onPressed: () {
                              setState(() {
                                _obscureConfirmPassword = !_obscureConfirmPassword;
                              });
                            },
                            icon: Icon(
                              _obscureConfirmPassword
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              color: Color(0xFF7C7C8D),
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Phone Input
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF3D3D5C),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: TextField(
                        controller: _phoneController,
                        style: const TextStyle(color: Colors.white),
                        keyboardType: TextInputType.phone,
                        decoration: const InputDecoration(
                          hintText: 'Phone Number',
                          hintStyle: TextStyle(
                            color: Color(0xFF7C7C8D),
                            fontSize: 16,
                          ),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 18,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Address Input
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF3D3D5C),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: TextField(
                        controller: _addressController,
                        style: const TextStyle(color: Colors.white),
                        decoration: const InputDecoration(
                          hintText: 'Address',
                          hintStyle: TextStyle(
                            color: Color(0xFF7C7C8D),
                            fontSize: 16,
                          ),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 18,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 50),

                    // Sign Up Button
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _onInscrir,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFF6B35),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: _isLoading
                            ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                            : const Text(
                          'Sign Up',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // I Have an Account
                    GestureDetector(
                      onTap: _isLoading
                          ? null
                          : () {
                        Navigator.pop(context);
                      },
                      child: Text(
                        'I Have an Account',
                        style: TextStyle(
                          color: _isLoading ? Colors.grey : Colors.white,
                          fontSize: 16,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),

                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}