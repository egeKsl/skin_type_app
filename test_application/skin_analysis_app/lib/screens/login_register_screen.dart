import 'package:flutter/material.dart';

class LoginRegisterScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Üst boşluk
            SizedBox(height: 60),

            // Logo/Başlık
            Icon(
              Icons.lock_outline,
              size: 100,
              color: Color(0xFF6C63FF), // Mor renk
            ),
            SizedBox(height: 20),

            Text(
              'Hoş Geldiniz',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 10),

            Text(
              'Cilt Analiz Uygulaması',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: 50),

            // Butonlar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Column(
                children: [
                  // GİRİŞ YAP BUTONU
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: () {
                        // Login ekranına git
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => LoginScreen(),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF6C63FF), // Mor
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        elevation: 2,
                      ),
                      child: Text(
                        'Giriş Yap',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),

                  // KAYIT OL BUTONU
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: OutlinedButton(
                      onPressed: () {
                        // Register ekranına git
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => RegisterScreen(),
                          ),
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Color(0xFF6C63FF),
                        side: BorderSide(color: Color(0xFF6C63FF), width: 2),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      child: Text(
                        'Kayıt Ol',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 30),

                  // VEYA TEXT
                  Row(
                    children: [
                      Expanded(
                        child: Divider(
                          color: Colors.grey[300],
                          thickness: 1,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 15),
                        child: Text(
                          'veya',
                          style: TextStyle(
                            color: Colors.grey[600],
                          ),
                        ),
                      ),
                      Expanded(
                        child: Divider(
                          color: Colors.grey[300],
                          thickness: 1,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 30),

                  // TEST BUTONU
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: TextButton(
                      onPressed: () {
                        // Test olarak direkt ana sayfaya git
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => HomeScreen(),
                          ),
                        );
                      },
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.grey[700],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      child: Text(
                        'Test için Geç',
                        style: TextStyle(
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Spacer(),

            // Alt bilgi
            Padding(
              padding: const EdgeInsets.only(bottom: 30),
              child: Text(
                'Cilt Analiz Uygulaması v1.0',
                style: TextStyle(
                  color: Colors.grey[500],
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
