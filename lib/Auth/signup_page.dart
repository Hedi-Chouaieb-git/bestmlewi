import 'package:flutter/material.dart';
import 'package:supabase_app/services/auth_service.dart';
import 'package:supabase_app/Routes/app_routes.dart';

class SignUpPage extends StatefulWidget {
  final bool initialIsClient;

  const SignUpPage({super.key, this.initialIsClient = true});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _authService = AuthService();
  final _nomController = TextEditingController();
  final _prenomController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _adresseController = TextEditingController();
  final _telephoneController = TextEditingController();
  final _accessCodeController = TextEditingController();

  bool _isClient = true;
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  String? _selectedRole;

  // Special access code for equipe signup
  static const String _equipeAccessCode = "MLEWI2024";

  @override
  void initState() {
    super.initState();
    _isClient = widget.initialIsClient;
    if (!_isClient) {
      _selectedRole = 'livreur';
    }
  }

  @override
  void dispose() {
    _nomController.dispose();
    _prenomController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _adresseController.dispose();
    _telephoneController.dispose();
    _accessCodeController.dispose();
    super.dispose();
  }

  Future<void> _handleSignUp() async {
    if (_isClient) {
      if (_nomController.text.isEmpty ||
          _phoneController.text.isEmpty ||
          _passwordController.text.isEmpty) {
        _showSnackBar('Veuillez remplir tous les champs obligatoires');
        return;
      }
    } else {
      if (_nomController.text.isEmpty ||
          _prenomController.text.isEmpty ||
          _emailController.text.isEmpty ||
          _passwordController.text.isEmpty ||
          _selectedRole == null) {
        _showSnackBar('Veuillez remplir tous les champs obligatoires');
        return;
      }

      // Validate access code for equipe signup
      if (_accessCodeController.text.trim() != _equipeAccessCode) {
        _showSnackBar('Code d\'accès invalide. Contactez l\'administration.');
        return;
      }
    }

    if (_passwordController.text != _confirmPasswordController.text) {
      _showSnackBar('Les mots de passe ne correspondent pas');
      return;
    }

    if (_passwordController.text.length < 6) {
      _showSnackBar('Le mot de passe doit contenir au moins 6 caractères');
      return;
    }

    setState(() => _isLoading = true);

    try {
      Map<String, dynamic> result;

      if (_isClient) {
        result = await _authService.signUpClient(
          nom: _nomController.text.trim(),
          phone: _phoneController.text.trim(),
          password: _passwordController.text.trim(),
          prenom: _prenomController.text.isEmpty ? null : _prenomController.text.trim(),
          adresse: _adresseController.text.isEmpty ? null : _adresseController.text.trim(),
          email: _emailController.text.isEmpty ? null : _emailController.text.trim(),
        );
        if (!mounted) return;
        _showSnackBar('Compte créé avec succès!');
        Navigator.pushReplacementNamed(context, AppRoutes.clientMenu);
      } else {
        result = await _authService.signUpCollaborateur(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
          nom: _nomController.text.trim(),
          prenom: _prenomController.text.trim(),
          role: _selectedRole!,
          telephone: _telephoneController.text.isEmpty ? null : _telephoneController.text.trim(),
        );
        if (!mounted) return;
        _showSnackBar('Compte créé avec succès!');
        Navigator.pushReplacementNamed(context, AppRoutes.signIn);
      }
    } catch (e) {
      _showSnackBar(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: message.contains('succès') ? Colors.green : Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/group55.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              color: const Color(0xFF2B2B2B).withOpacity(0.85),
              image: const DecorationImage(
                image: AssetImage('assets/images/group55.png'),
                fit: BoxFit.cover,
                opacity: 0.1,
              ),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 40),
                    const Text(
                      'Inscription',
                      style: TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFFF6B35),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Créer un compte',
                      style: TextStyle(
                        fontSize: 28,
                        color: Colors.white,
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                    const SizedBox(height: 30),

                    // User Type Toggle
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF3D3D5C),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () => setState(() => _isClient = true),
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                decoration: BoxDecoration(
                                  color: _isClient ? const Color(0xFFFF6B35) : Colors.transparent,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Text(
                                  'Client',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: GestureDetector(
                              onTap: () => setState(() {
                                _isClient = false;
                                _selectedRole = 'livreur';
                              }),
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                decoration: BoxDecoration(
                                  color: !_isClient ? const Color(0xFFFF6B35) : Colors.transparent,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Text(
                                  'Équipe',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 30),

                    _buildTextField(_nomController, 'Nom*', Icons.person),
                    const SizedBox(height: 16),

                    if (!_isClient) ...[
                      _buildTextField(_prenomController, 'Prénom*', Icons.person_outline),
                      const SizedBox(height: 16),
                    ],

                    if (_isClient) ...[
                      _buildTextField(_phoneController, 'Numéro de téléphone*', Icons.phone, TextInputType.phone),
                      const SizedBox(height: 16),
                    ],

                    if (!_isClient) ...[
                      _buildTextField(_emailController, 'Email*', Icons.email, TextInputType.emailAddress),
                      const SizedBox(height: 16),
                    ],

                    if (_isClient) ...[
                      _buildTextField(_emailController, 'Email (optionnel)', Icons.email, TextInputType.emailAddress),
                      const SizedBox(height: 16),
                    ],

                    if (_isClient) ...[
                      _buildTextField(_adresseController, 'Adresse', Icons.location_on),
                      const SizedBox(height: 16),
                    ],

                    if (!_isClient) ...[
                      _buildTextField(_telephoneController, 'Téléphone', Icons.phone, TextInputType.phone),
                      const SizedBox(height: 16),
                    ],

                    if (!_isClient) ...[
                      Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFF3D3D5C),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: DropdownButtonFormField<String>(
                          value: _selectedRole,
                          dropdownColor: const Color(0xFF3D3D5C),
                          style: const TextStyle(color: Colors.white),
                          decoration: const InputDecoration(
                            labelText: 'Rôle*',
                            labelStyle: TextStyle(color: Color(0xFF7C7C8D)),
                            border: InputBorder.none,
                          ),
                          items: const [
                            DropdownMenuItem(value: 'livreur', child: Text('Livreur')),
                            DropdownMenuItem(value: 'coordinateur', child: Text('Coordinateur')),
                            DropdownMenuItem(value: 'cuisinier', child: Text('Cuisinier')),
                            DropdownMenuItem(value: 'chef', child: Text('Chef')),
                            DropdownMenuItem(value: 'gerant', child: Text('Gérant')),
                          ],
                          onChanged: (value) => setState(() => _selectedRole = value),
                        ),
                      ),
                      const SizedBox(height: 16),

                      _buildTextField(_accessCodeController, 'Code d\'accès*', Icons.vpn_key),
                      const SizedBox(height: 8),
                      const Text(
                        'Code d\'accès requis pour rejoindre l\'équipe',
                        style: TextStyle(
                          color: Color(0xFF7C7C8D),
                          fontSize: 12,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                    ],

                    _buildPasswordField(_passwordController, 'Mot de passe*', _obscurePassword, () {
                      setState(() => _obscurePassword = !_obscurePassword);
                    }),
                    const SizedBox(height: 16),

                    _buildPasswordField(_confirmPasswordController, 'Confirmer le mot de passe*', _obscureConfirmPassword, () {
                      setState(() => _obscureConfirmPassword = !_obscureConfirmPassword);
                    }),
                    const SizedBox(height: 40),

                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _handleSignUp,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFF6B35),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: _isLoading
                            ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 3,
                            valueColor: AlwaysStoppedAnimation(Colors.white),
                          ),
                        )
                            : const Text(
                          'S\'inscrire',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const Text(
                        "J'ai déjà un compte",
                        style: TextStyle(
                          color: Colors.white,
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

  Widget _buildTextField(
      TextEditingController controller,
      String hint,
      IconData icon, [
        TextInputType keyboardType = TextInputType.text,
      ]) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF3D3D5C),
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Color(0xFF7C7C8D), fontSize: 16),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          prefixIcon: Icon(icon, color: const Color(0xFF7C7C8D)),
        ),
      ),
    );
  }

  Widget _buildPasswordField(
      TextEditingController controller,
      String hint,
      bool obscureText,
      VoidCallback onToggle,
      ) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF3D3D5C),
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Color(0xFF7C7C8D), fontSize: 16),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          prefixIcon: const Icon(Icons.lock, color: Color(0xFF7C7C8D)),
          suffixIcon: IconButton(
            icon: Icon(
              obscureText ? Icons.visibility : Icons.visibility_off,
              color: const Color(0xFF7C7C8D),
            ),
            onPressed: onToggle,
          ),
        ),
      ),
    );
  }
}
