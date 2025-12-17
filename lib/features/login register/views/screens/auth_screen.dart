import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:skin_type_app/constants/profile_colors.dart';
import 'package:skin_type_app/core/services/auth_service.dart';
import 'package:skin_type_app/core/services/user_service.dart';
import 'package:skin_type_app/features/home/views/screens/home_screen.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  // True = Login, False = Register
  bool _isLoginMode = true;

  final AuthService _authService = AuthService();
  final UserService userService = UserService();
  // Controllers
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();

  DateTime? _selectedDob;

  bool _obscurePassword = true;

  // ================= DATE PICKER =================
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(const Duration(days: 365 * 18)),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: ProfileColors.primaryGreen,
              onPrimary: Colors.white,
              onSurface: ProfileColors.textDark,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedDob = picked;
        _dobController.text = DateFormat('MMMM dd, yyyy').format(picked);
      });
    }
  }

  // ================= SWITCH MODE =================
  void _switchAuthMode() {
    setState(() {
      _isLoginMode = !_isLoginMode;
      _emailController.clear();
      _passwordController.clear();
      _dobController.clear();
      _selectedDob = null;
    });
  }

  // ================= SUBMIT =================
  Future<void> _submit() async {
    try {
      final email = _emailController.text.trim();
      final password = _passwordController.text.trim();

      if (email.isEmpty || password.isEmpty) {
        throw Exception("Email and password are required");
      }

      if (_isLoginMode) {
        // LOGIN
        await _authService.login(email: email, password: password);
      } else {
        // REGISTER
        if (_selectedDob == null) {
          throw Exception("Date of birth is required");
        }

        final user = await _authService.register(
          email: email,
          password: password,
        );
        await userService.createUser(
          uid: user.uid,
          email: email,
          dateOfBirth: _selectedDob!,
        );
      }

      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/home');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
      );
    }
  }

  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ProfileColors.background,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: ProfileColors.primaryGreen.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.spa_rounded,
                    size: 50,
                    color: ProfileColors.primaryGreen,
                  ),
                ),
              ),
              const SizedBox(height: 30),

              Text(
                _isLoginMode ? "Welcome Back!" : "Create Account",
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: ProfileColors.textDark,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _isLoginMode
                    ? "Sign in to continue your skincare journey."
                    : "Join us and get your personalized routine.",
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              ),
              const SizedBox(height: 40),

              CustomAuthField(
                label: "Email Address",
                hintText: "example@mail.com",
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                prefixIcon: Icons.email_outlined,
              ),
              const SizedBox(height: 20),

              CustomAuthField(
                label: "Password",
                hintText: "••••••••",
                controller: _passwordController,
                obscureText: _obscurePassword,
                prefixIcon: Icons.lock_outline,
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    color: ProfileColors.primaryGreen,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
                ),
              ),
              const SizedBox(height: 20),

              if (!_isLoginMode)
                CustomAuthField(
                  label: "Date of Birth",
                  hintText: "Select your birth date",
                  controller: _dobController,
                  readOnly: true,
                  prefixIcon: Icons.calendar_today_outlined,
                  onTap: () => _selectDate(context),
                ),

              const SizedBox(height: 40),

              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ProfileColors.primaryGreen,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  child: Text(
                    _isLoginMode ? "Login" : "Create Account",
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 25),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _isLoginMode
                        ? "Don't have an account? "
                        : "Already have an account? ",
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  GestureDetector(
                    onTap: _switchAuthMode,
                    child: Text(
                      _isLoginMode ? "Sign Up" : "Login",
                      style: const TextStyle(
                        color: ProfileColors.primaryGreen,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ================= CUSTOM INPUT =================
class CustomAuthField extends StatelessWidget {
  final String label;
  final String hintText;
  final TextEditingController controller;
  final bool obscureText;
  final TextInputType? keyboardType;
  final IconData prefixIcon;
  final Widget? suffixIcon;
  final bool readOnly;
  final VoidCallback? onTap;

  const CustomAuthField({
    super.key,
    required this.label,
    required this.hintText,
    required this.controller,
    this.obscureText = false,
    this.keyboardType,
    required this.prefixIcon,
    this.suffixIcon,
    this.readOnly = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: ProfileColors.cardWhite,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: ProfileColors.textLight,
              fontSize: 12,
            ),
          ),
          TextFormField(
            controller: controller,
            obscureText: obscureText,
            keyboardType: keyboardType,
            readOnly: readOnly,
            onTap: onTap,
            decoration: InputDecoration(
              hintText: hintText,
              border: InputBorder.none,
              prefixIcon: Icon(prefixIcon, color: ProfileColors.primaryGreen),
              suffixIcon: suffixIcon,
            ),
          ),
        ],
      ),
    );
  }
}
