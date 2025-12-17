import 'package:flutter/material.dart';
//import 'features/home/views/screens/home_screen.dart';
import 'features/profile information/views/screens/personal_info_screen.dart';
import 'features/login register/views/screens/auth_screen.dart';
import 'constants/app_colors.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Skincare App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: AppColors.background,
        useMaterial3: true,
      ),
      home: const AuthScreen(),
    );
  }
}
