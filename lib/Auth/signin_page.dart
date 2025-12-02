import 'package:flutter/material.dart';
import 'package:supabase_app/services/auth_service.dart';
import 'package:supabase_app/Routes/app_routes.dart';
import 'signup_page.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final _authService = AuthService();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isClient = true;
  bool _isLoading = false;
  bool _rememberMe = true;

  @override
  void dispose() {
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleSignIn() async {
    if (_isClient) {
      if (_phoneController.text.isEmpty || _passwordController.text.isEmpty) {
        _showSnackBar('Veuillez remplir tous les champs');
        return;
      }
    } else {
      if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
        _showSnackBar('Veuillez remplir tous les champs');
        return;
      }
    }

    setState(() => _isLoading = true);

    try {
      Map<String, dynamic> result;

      if (_isClient) {
        result = await _authService.signInClient(
          phone: _phoneController.text.trim(),
          password: _passwordController.text.trim(),
        );
        // Save user data
        await _authService.saveCurrentUser(result);
        if (!mounted) return;
        Navigator.pushReplacementNamed(context, AppRoutes.clientMenu);
      } else {
        result = await _authService.signInCollaborateur(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );
        // Save user data
        await _authService.saveCurrentUser(result);
        if (!mounted) return;

        final role = result['userRole'] as UserRole?;
        switch (role) {
          case UserRole.gerant:
            Navigator.pushReplacementNamed(context, AppRoutes.gerantDashboard);
            break;
          case UserRole.coordinateur:
            Navigator.pushReplacementNamed(context, AppRoutes.coordinateurHome);
            break;
          case UserRole.livreur:
            Navigator.pushReplacementNamed(context, AppRoutes.livreurHome);
            break;
          default:
            Navigator.pushReplacementNamed(context, AppRoutes.gerantDashboard);
        }
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
        backgroundColor: message.contains('succès') || message.contains('réussi')
            ? Colors.green
            : Colors.red,
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
                    const SizedBox(height: 80),
                    const Text(
                      'Connexion',
                      style: TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFFF6B35),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Bienvenue',
                      style: TextStyle(
                        fontSize: 28,
                        color: Colors.white,
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                    const SizedBox(height: 40),

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
                              onTap: () => setState(() => _isClient = false),
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

                    if (_isClient)
                      _buildTextField(
                        controller: _phoneController,
                        hint: 'Numéro de téléphone',
                        icon: Icons.phone,
                        keyboardType: TextInputType.phone,
                      ),

                    if (!_isClient)
                      _buildTextField(
                        controller: _emailController,
                        hint: 'Email',
                        icon: Icons.email,
                        keyboardType: TextInputType.emailAddress,
                      ),

                    const SizedBox(height: 20),

                    _buildTextField(
                      controller: _passwordController,
                      hint: 'Mot de passe',
                      icon: Icons.lock,
                      obscureText: true,
                    ),
                    const SizedBox(height: 16),

                    Row(
                      children: [
                        GestureDetector(
                          onTap: () => setState(() => _rememberMe = !_rememberMe),
                          child: Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: _rememberMe ? const Color(0xFFFF6B35) : Colors.transparent,
                              border: Border.all(color: const Color(0xFFFF6B35), width: 2),
                            ),
                            child: _rememberMe
                                ? const Icon(Icons.check, size: 16, color: Colors.white)
                                : null,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          'Se souvenir de moi',
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                      ],
                    ),
                    const SizedBox(height: 40),

                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _handleSignIn,
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
                          'Se connecter',
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
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SignUpPage(initialIsClient: _isClient),
                          ),
                        );
                      },
                      child: const Text(
                        "Créer un compte",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Mot de passe oublié ?',
                      style: TextStyle(
                        color: Color(0xFF7C7C8D),
                        fontSize: 14,
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

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: const Color(0xFF3D3D5C),
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
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
}
