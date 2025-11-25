import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({Key? key}) : super(key: key);

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  final SupabaseClient _supabase = Supabase.instance.client;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _signUp() async {
    // Required fields validation
    if (_nameController.text.isEmpty ||
        _phoneController.text.isEmpty ||
        _passwordController.text.isEmpty) {
      _showSnackBar('Name, phone and password are required');
      return;
    }

    // Password confirmation validation
    if (_passwordController.text != _confirmPasswordController.text) {
      _showSnackBar('Passwords do not match');
      return;
    }

    // Password length validation
    if (_passwordController.text.length < 6) {
      _showSnackBar('Password must be at least 6 characters long');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Check if phone number already exists
      final existingClient = await _supabase
          .from('Client')
          .select()
          .eq('phone', _phoneController.text.trim())
          .maybeSingle();

      if (existingClient != null) {
        _showSnackBar('A client with this phone number already exists');
        return;
      }

      // Direct registration in Client table
      final response = await _supabase
          .from('Client')
          .insert({
        'name': _nameController.text.trim(),
        'phone': _phoneController.text.trim(),
        'address': _addressController.text.trim().isEmpty ? null : _addressController.text.trim(),
        'password': _passwordController.text.trim(), // Store password
        'createdAt': DateTime.now().toIso8601String(),
      })
          .select();

      if (response.isNotEmpty) {
        _showSnackBar('Client account created successfully!');

        // Navigate to login page
        Navigator.pushReplacementNamed(context, '/menu');
      }

    } catch (e) {
      _showSnackBar('Error creating account: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: message.contains('successfully') ? Colors.green : Colors.red,
        duration: Duration(seconds: 4),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background
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
                    const SizedBox(height: 40),

                    // Sign Up Title
                    const Text(
                      'Client Registration',
                      style: TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFFF6B35),
                      ),
                    ),

                    const SizedBox(height: 8),

                    // Welcome Text
                    const Text(
                      'Create Your Account',
                      style: TextStyle(
                        fontSize: 28,
                        color: Colors.white,
                        fontWeight: FontWeight.w300,
                      ),
                    ),

                    const SizedBox(height: 40),

                    // Name
                    _buildTextField(_nameController, 'Full Name*', Icons.person),

                    const SizedBox(height: 16),

                    // Phone
                    _buildTextField(_phoneController, 'Phone Number*', Icons.phone, TextInputType.phone),

                    const SizedBox(height: 16),

                    // Address
                    _buildTextField(_addressController, 'Address', Icons.location_on, TextInputType.streetAddress),

                    const SizedBox(height: 16),

                    // Password
                    _buildPasswordField(_passwordController, 'Password*', _obscurePassword, () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    }),

                    const SizedBox(height: 16),

                    // Confirm Password
                    _buildPasswordField(_confirmPasswordController, 'Confirm Password*', _obscureConfirmPassword, () {
                      setState(() {
                        _obscureConfirmPassword = !_obscureConfirmPassword;
                      });
                    }),

                    const SizedBox(height: 40),

                    // Sign Up Button
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _signUp,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFF6B35),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: _isLoading
                            ? const SizedBox(
                          width: 20,
                          height: 20,
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

                    // Already Have an Account
                    GestureDetector(
                      onTap: _isLoading
                          ? null
                          : () {
                        Navigator.pushReplacementNamed(context, '/signin');
                      },
                      child: Text(
                        "I already have an account",
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

  Widget _buildTextField(TextEditingController controller, String hintText, IconData icon, [TextInputType keyboardType = TextInputType.text]) {
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
          hintText: hintText,
          hintStyle: const TextStyle(
            color: Color(0xFF7C7C8D),
            fontSize: 16,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 18,
          ),
          prefixIcon: Icon(icon, color: const Color(0xFF7C7C8D)),
        ),
      ),
    );
  }

  Widget _buildPasswordField(TextEditingController controller, String hintText, bool obscureText, VoidCallback onToggle) {
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
          hintText: hintText,
          hintStyle: const TextStyle(
            color: Color(0xFF7C7C8D),
            fontSize: 16,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 18,
          ),
          prefixIcon: Icon(Icons.lock, color: const Color(0xFF7C7C8D)),
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