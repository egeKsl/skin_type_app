import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ana Sayfa'),
        backgroundColor: Color(0xFF6C63FF),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () {
              // 📌 BURAYA FIREBASE LOGOUT KODUNU YAZACAKSIN
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => LoginRegisterScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.check_circle,
              size: 80,
              color: Colors.green,
            ),
            SizedBox(height: 20),
            Text(
              'Başarıyla Giriş Yapıldı!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),
            Text(
              'Firebase Auth eğitimi için hazırsınız',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: 30),
            Container(
              padding: EdgeInsets.all(20),
              margin: EdgeInsets.symmetric(horizontal: 30),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: Column(
                children: [
                  Text(
                    'Yapmanız Gerekenler:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  SizedBox(height: 15),
                  _buildTaskItem('1. Firebase projesi oluştur'),
                  _buildTaskItem('2. Authentication\'u etkinleştir'),
                  _buildTaskItem('3. Email/Password metodunu aç'),
                  _buildTaskItem('4. Firebase paketlerini ekle'),
                  _buildTaskItem('5. Auth servis sınıfı yaz'),
                  _buildTaskItem('6. Login/Register fonksiyonlarını yaz'),
                ],
              ),
            ),
            SizedBox(height: 40),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => LoginRegisterScreen(),
                  ),
                );
              },
              icon: Icon(Icons.logout),
              label: Text('Çıkış Yap'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTaskItem(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(Icons.check_circle_outline, size: 20, color: Colors.green),
          SizedBox(width: 10),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}
