import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _obscurePassword = true;

  // Form değişkenleri (Firebase için sen dolduracaksın)
  String _email = '';
  String _password = '';

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
                    'Giriş Yap',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 10),

                  Text(
                    'Hesabınıza giriş yapın',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                  SizedBox(height: 40),

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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Şifre',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                          color: Colors.grey[700],
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          // Şifremi unuttum ekranı
                        },
                        child: Text(
                          'Şifremi Unuttum',
                          style: TextStyle(
                            color: Color(0xFF6C63FF),
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
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
                  SizedBox(height: 30),

                  // Giriş Butonu
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: _isLoading
                          ? null
                          : () {
                              if (_formKey.currentState!.validate()) {
                                // ✅ Form doğrulandı
                                // 📌 BURAYA FIREBASE LOGIN KODUNU YAZACAKSIN
                                setState(() {
                                  _isLoading = true;
                                });

                                // Simüle loading
                                Future.delayed(Duration(seconds: 2), () {
                                  setState(() {
                                    _isLoading = false;
                                  });

                                  // Başarılı giriş simülasyonu
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
                              'Giriş Yap',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  ),
                  SizedBox(height: 25),

                  // Kayıt ol linki
                  Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Hesabınız yok mu? ',
                          style: TextStyle(
                            color: Colors.grey[600],
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => RegisterScreen(),
                              ),
                            );
                          },
                          child: Text(
                            'Kayıt Ol',
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

                  // Test Hesabı
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[200]!),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              size: 18,
                              color: Color(0xFF6C63FF),
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Test Hesabı',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF6C63FF),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Email: test@test.com\nŞifre: 123456',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[700],
                          ),
                        ),
                        SizedBox(height: 8),
                        SizedBox(
                          width: double.infinity,
                          child: TextButton(
                            onPressed: () {
                              // Test girişi
                              setState(() {
                                _email = 'test@test.com';
                                _password = '123456';
                              });
                            },
                            child: Text(
                              'Test Bilgilerini Doldur',
                              style: TextStyle(fontSize: 13),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
