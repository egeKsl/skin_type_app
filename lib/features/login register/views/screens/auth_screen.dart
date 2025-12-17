import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:skin_type_app/constants/profile_colors.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  // Hangi moddayız? True = Login, False = Register
  bool _isLoginMode = true;

  // Controller'lar
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();

  // Şifre görünürlüğü
  bool _obscurePassword = true;

  // Tarih Seçici Göster
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(
        const Duration(days: 365 * 18),
      ), // Varsayılan 18 yaş
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        // Takvim renklerini temaya uydurma
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
        // intl paketi ile formatlama: "March 15, 1992" formatı
        _dobController.text = DateFormat('MMMM dd, yyyy').format(picked);
      });
    }
  }

  // Modu değiştir (Login <-> Register)
  void _switchAuthMode() {
    setState(() {
      _isLoginMode = !_isLoginMode;
    });
    // Mod değişince inputları temizle
    _emailController.clear();
    _passwordController.clear();
    _dobController.clear();
  }

  @override
  Widget build(BuildContext context) {
    // Ekran boyutunu al (Responsive tasarım için)
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: ProfileColors.background,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. HEADER KISMI (Logo ve Başlık)
              Center(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: ProfileColors.primaryGreen.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.spa_rounded, // Skincare temalı bir ikon
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

              // 2. FORM ALANLARI
              // E-posta (Her iki modda da var)
              CustomAuthField(
                label: "Email Address",
                hintText: "example@mail.com",
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                prefixIcon: Icons.email_outlined,
              ),
              const SizedBox(height: 20),

              // Şifre (Her iki modda da var)
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

              // Doğum Tarihi (Sadece Register modunda var)
              if (!_isLoginMode)
                CustomAuthField(
                  label: "Date of Birth",
                  hintText: "Select your birth date",
                  controller: _dobController,
                  readOnly: true, // Klavye açılmasın
                  prefixIcon: Icons.calendar_today_outlined,
                  onTap: () =>
                      _selectDate(context), // Tıklanınca takvim açılsın
                ),

              const SizedBox(height: 40),

              // 3. ANA BUTON (Login veya Sign Up)
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: () {
                    // Buraya giriş/kayıt fonksiyonları gelecek
                    print("Email: ${_emailController.text}");
                    print("Password: ${_passwordController.text}");
                    if (!_isLoginMode) print("DOB: ${_dobController.text}");
                  },
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

              // 4. MOD DEĞİŞTİRME LİNKİ
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

// --- ÖZEL INPUT WIDGET'I (Referans tasarıma uygun) ---
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
      width: double.infinity,
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
          // Üstteki Etiket (Label)
          Text(
            label,
            style: const TextStyle(
              color: ProfileColors.textLight,
              fontSize: 12,
            ),
          ),
          // Input Alanı
          TextFormField(
            controller: controller,
            obscureText: obscureText,
            keyboardType: keyboardType,
            readOnly: readOnly,
            onTap: onTap,
            style: const TextStyle(
              color: ProfileColors.textDark,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: TextStyle(color: Colors.grey.shade400),
              border: InputBorder.none, // Alt çizgiyi kaldır
              contentPadding: const EdgeInsets.symmetric(vertical: 10),
              prefixIcon: Icon(prefixIcon, color: ProfileColors.primaryGreen),
              suffixIcon: suffixIcon,
            ),
          ),
        ],
      ),
    );
  }
}
