import 'dart:io'; // Resim dosyasını okumak için gerekli
import 'package:flutter/material.dart';
import 'package:skin_type_app/common/widgets/top_menu_overlay.dart';
import 'package:skin_type_app/core/services/scan_service.dart';
import 'package:skin_type_app/features/scan history/views/screens/scan_history_screen.dart';
import 'package:skin_type_app/features/scan details/views/screens/scan_detail_screen.dart';
import 'package:skin_type_app/models/scan_model.dart';
// Personal Info ekranını import ediyoruz
import 'package:skin_type_app/features/profile information/views/screens/personal_info_screen.dart';

import '../widgets/section_header.dart';
import '../widgets/profile_list_tile.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ScanService _scanService = ScanService();

    return Scaffold(
      backgroundColor: Colors.white,
      // Body'yi Column yaptık, SingleChildScrollView'ı aşağıya aldık.
      // Böylece üst header sabit kalabilir veya kayabilir, tasarımı daha esnek olur.
      body: Column(
        children: [
          // 1. YENİLENMİŞ ÜST HEADER ALANI (Ekranı dolduracak)
          _buildHeader(context),

          // Geri kalan içerik kaydırılabilir alanda
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // 2. PERSONAL INFORMATION (Tıklanabilir Yapıldı)
                  const SizedBox(height: 20),
                  const SectionHeader(title: "Personal Information"),

                  GestureDetector(
                    onTap: () => _navigateToPersonalInfo(context),
                    child: const ProfileListTile(
                      icon: Icons.person,
                      title: "Full Name",
                      value: "Sarah Johnson",
                    ),
                  ),
                  GestureDetector(
                    onTap: () => _navigateToPersonalInfo(context),
                    child: const ProfileListTile(
                      icon: Icons.email,
                      title: "Email",
                      value: "sarah.j@email.com",
                    ),
                  ),
                  GestureDetector(
                    onTap: () => _navigateToPersonalInfo(context),
                    child: const ProfileListTile(
                      icon: Icons.cake,
                      title: "Age",
                      value: "28 years",
                    ),
                  ),

                  const SizedBox(height: 20),

                  // 3. SCAN HISTORY (Fotoğraflı ve Dinamik)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const SectionHeader(
                          title: "Scan History",
                          padding: EdgeInsets.zero,
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const ScanHistoryScreen(),
                              ),
                            );
                          },
                          child: const Text(
                            "View All",
                            style: TextStyle(
                              color: Color(0xFF6B7C97),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),

                  // StreamBuilder ile Son 3 Veri
                  StreamBuilder<List<ScanResult>>(
                    stream: _scanService.getRecentScans(3),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: LinearProgressIndicator(
                            color: Color(0xFF6B7C97),
                          ),
                        );
                      }

                      if (snapshot.hasError) {
                        return const Center(child: Text("Veri yüklenemedi"));
                      }

                      final historyData = snapshot.data ?? [];

                      if (historyData.isEmpty) {
                        return const Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Text(
                            "No scan history available yet.",
                            style: TextStyle(color: Colors.grey),
                          ),
                        );
                      }

                      return Column(
                        children: historyData.map((scan) {
                          return _buildPhotoHistoryCard(context, scan);
                        }).toList(),
                      );
                    },
                  ),

                  const SizedBox(height: 20),

                  // 4. SETTINGS
                  const SectionHeader(title: "Settings"),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 8.0,
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: Colors.blue.shade50,
                          child: const Icon(
                            Icons.notifications,
                            color: Color(0xFF6B7C97),
                          ),
                        ),
                        const SizedBox(width: 15),
                        const Expanded(
                          child: Text(
                            "Notifications",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        Switch(
                          value: true,
                          onChanged: (val) {},
                          activeColor: const Color(0xFFD1E9F6),
                          activeTrackColor: Colors.blue.shade200,
                        ),
                      ],
                    ),
                  ),
                  const Divider(indent: 70, endIndent: 16, height: 1),

                  const ProfileListTile(
                    icon: Icons.privacy_tip,
                    title: "Privacy",
                    value: "",
                  ),
                  const ProfileListTile(
                    icon: Icons.language,
                    title: "Language",
                    value: "English",
                  ),
                  const ProfileListTile(
                    icon: Icons.star,
                    title: "Rate App",
                    value: "",
                  ),
                  const ProfileListTile(
                    icon: Icons.logout,
                    title: "Log Out",
                    value: "",
                  ),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToPersonalInfo(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const PersonalInfoScreen()),
    );
  }

  Widget _buildPhotoHistoryCard(BuildContext context, ScanResult scan) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ScanDetailScreen(scanResult: scan),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade100),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: 60,
                height: 60,
                color: const Color(0xFFF0F4F8),
                child: (scan.imagePath != null && scan.imagePath!.isNotEmpty)
                    ? Image.file(
                        File(scan.imagePath!),
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(
                            Icons.broken_image_outlined,
                            color: Colors.grey,
                          );
                        },
                      )
                    : const Icon(
                        Icons.camera_alt_outlined,
                        color: Color(0xFF6B7C97),
                        size: 28,
                      ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    scan.ciltTipi,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2D3142),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    scan.date,
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE3F2FD),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      "Match: ${scan.benzerlikYuzdesi}",
                      style: const TextStyle(
                        color: Color(0xFF1565C0),
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  // --- YENİLENMİŞ HEADER TASARIMI ---
  Widget _buildHeader(BuildContext context) {
    return Column(
      children: [
        // 1. Üst Kısım (Mavi-Gri Alan)
        Container(
          width: double.infinity,
          // MediaQuery ile üst status bar boşluğunu otomatik alıyoruz
          padding: EdgeInsets.only(
            top: MediaQuery.of(context).padding.top + 10,
            bottom: 20,
            left: 16,
            right: 16,
          ),
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF6B7C97), Color(0xFF8697B0)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            // İsterseniz alt köşeleri hafif yuvarlatabilirsiniz:
            // borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
              const Text(
                "Profile",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              GestureDetector(
                onTap: () => showTopMenuOverlay(context),
                child: const Icon(Icons.menu, color: Colors.white),
              ),
            ],
          ),
        ),

        // 2. Profil Bilgileri (Resim ve İsim) - Hemen altına
        Container(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Stack(
                children: [
                  CircleAvatar(
                    radius: 35,
                    backgroundColor: Colors.grey.shade300,
                    backgroundImage: const NetworkImage(
                      "https://i.pravatar.cc/300?img=5",
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: Container(
                        width: 12,
                        height: 12,
                        decoration: const BoxDecoration(
                          color: Color(0xFF6B7C97),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 15),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Sarah Johnson",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const Text(
                    "sarah.j@email.com",
                    style: TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 5),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: const [
                        Icon(Icons.face, size: 14, color: Colors.grey),
                        SizedBox(width: 5),
                        Text(
                          "Combination Skin",
                          style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFF6B7C97),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
