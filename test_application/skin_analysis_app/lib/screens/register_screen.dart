import 'package:flutter/material.dart';

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  // Form değişkenleri
  String _email = '';
  String _password = '';
  String _confirmPassword = '';
  String _name = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Colors.black,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 20),

                  // Başlık
                  Text(
                    'Kayıt Ol',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 10),

                  Text(
                    'Yeni hesabınızı oluşturun',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                  SizedBox(height: 40),

                  // İsim Input
                  Text(
                    'İsim',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                      color: Colors.grey[700],
                    ),
                  ),
                  SizedBox(height: 8),

                  TextFormField(
                    decoration: InputDecoration(
                      hintText: 'Adınız ve soyadınız',
                      prefixIcon: Icon(Icons.person_outline),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide:
                            BorderSide(color: Color(0xFF6C63FF), width: 2),
                      ),
                      filled: true,
                      fillColor: Colors.grey[50],
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'İsim gereklidir';
                      }
                      return null;
                    },
                    onChanged: (value) {
                      _name = value;
                    },
                  ),
                  SizedBox(height: 20),

                  // Email Input
                  Text(
                    'Email',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                      color: Colors.grey[700],
                    ),
                  ),
                  SizedBox(height: 8),

                  TextFormField(
                    decoration: InputDecoration(
                      hintText: 'ornek@email.com',
                      prefixIcon: Icon(Icons.email_outlined),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide:
                            BorderSide(color: Color(0xFF6C63FF), width: 2),
                      ),
                      filled: true,
                      fillColor: Colors.grey[50],
                    ),
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Email gereklidir';
                      }
                      if (!value.contains('@')) {
                        return 'Geçerli bir email adresi girin';
                      }
                      return null;
                    },
                    onChanged: (value) {
                      _email = value;
                    },
                  ),
                  SizedBox(height: 20),

                  // Şifre Input
                  Text(
                    'Şifre',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                      color: Colors.grey[700],
                    ),
                  ),
                  SizedBox(height: 8),

                  TextFormField(
                    decoration: InputDecoration(
                      hintText: '••••••••',
                      prefixIcon: Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_off
                              : Icons.visibility,
                          color: Colors.grey[500],
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide:
                            BorderSide(color: Color(0xFF6C63FF), width: 2),
                      ),
                      filled: true,
                      fillColor: Colors.grey[50],
                    ),
                    obscureText: _obscurePassword,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Şifre gereklidir';
                      }
                      if (value.length < 6) {
                        return 'Şifre en az 6 karakter olmalı';
                      }
                      return null;
                    },
                    onChanged: (value) {
                      _password = value;
                    },
                  ),
                  SizedBox(height: 20),

                  // Şifre Tekrar
                  Text(
                    'Şifre Tekrar',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                      color: Colors.grey[700],
                    ),
                  ),
                  SizedBox(height: 8),

                  TextFormField(
                    decoration: InputDecoration(
                      hintText: '••••••••',
                      prefixIcon: Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureConfirmPassword
                              ? Icons.visibility_off
                              : Icons.visibility,
                          color: Colors.grey[500],
                        ),
                        onPressed: () {
                          setState(() {
                            _obscureConfirmPassword = !_obscureConfirmPassword;
                          });
                        },
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide:
                            BorderSide(color: Color(0xFF6C63FF), width: 2),
                      ),
                      filled: true,
                      fillColor: Colors.grey[50],
                    ),
                    obscureText: _obscureConfirmPassword,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Şifre tekrarı gereklidir';
                      }
                      if (value != _password) {
                        return 'Şifreler eşleşmiyor';
                      }
                      return null;
                    },
                    onChanged: (value) {
                      _confirmPassword = value;
                    },
                  ),
                  SizedBox(height: 30),

                  // Kayıt Butonu
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: _isLoading
                          ? null
                          : () {
                              if (_formKey.currentState!.validate()) {
                                // ✅ Form doğrulandı
                                // 📌 BURAYA FIREBASE REGISTER KODUNU YAZACAKSIN
                                setState(() {
                                  _isLoading = true;
                                });

                                // Simüle loading
                                Future.delayed(Duration(seconds: 2), () {
                                  setState(() {
                                    _isLoading = false;
                                  });

                                  // Başarılı kayıt simülasyonu
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => HomeScreen(),
                                    ),
                                  );
                                });
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF6C63FF),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        elevation: 2,
                      ),
                      child: _isLoading
                          ? SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Text(
                              'Kayıt Ol',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  ),
                  SizedBox(height: 25),

                  // Giriş yap linki
                  Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Zaten hesabınız var mı? ',
                          style: TextStyle(
                            color: Colors.grey[600],
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => LoginScreen(),
                              ),
                            );
                          },
                          child: Text(
                            'Giriş Yap',
                            style: TextStyle(
                              color: Color(0xFF6C63FF),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
