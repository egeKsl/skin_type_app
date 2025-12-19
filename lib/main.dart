import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Firebase Auth paketini ekledik
import 'firebase_options.dart';
import 'package:skin_type_app/features/login register/views/screens/auth_screen.dart';
import 'package:skin_type_app/features/home/views/screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      // home özelliği içinde authStateChanges dinleyerek başlangıç ekranını belirliyoruz
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          // Firebase bağlantı durumunu kontrol ediyoruz
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          // Eğer snapshot veri içeriyorsa (user != null), kullanıcı giriş yapmıştır
          if (snapshot.hasData) {
            return const HomeScreen();
          }

          // Aksi takdirde (user == null), giriş yapılmamıştır veya çıkış yapılmıştır
          return const AuthScreen();
        },
      ),
      routes: {
        '/auth': (context) => const AuthScreen(),
        '/home': (context) => const HomeScreen(),
      },
    );
  }
}
