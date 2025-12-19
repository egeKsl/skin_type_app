import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:skin_type_app/common/widgets/top_menu_overlay.dart';
import 'package:skin_type_app/core/services/scan_service.dart';
import 'package:skin_type_app/features/scan history/views/screens/scan_history_screen.dart';
import 'package:skin_type_app/features/scan details/views/screens/scan_detail_screen.dart';
import 'package:skin_type_app/models/scan_model.dart';
import 'package:skin_type_app/features/profile information/views/screens/personal_info_screen.dart';

import '../widgets/section_header.dart';
import '../widgets/profile_list_tile.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ScanService _scanService = ScanService();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // State Variables
  String _fullName = "Loading...";
  String _email = "";
  String _age = "Not set";
  String _skinType = "No analysis yet";
  String? _profileImagePath;
  bool _isNotificationActive = false; // Initial state: off
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  // Veritabanından profil ve analiz verilerini çeker
  Future<void> _loadProfileData() async {
    try {
      final profileDoc = await _scanService.getUserProfile();
      final user = _auth.currentUser;

      if (profileDoc != null && profileDoc.exists) {
        final data = profileDoc.data() as Map<String, dynamic>;
        if (mounted) {
          setState(() {
            _fullName = data['full_name'] ?? "Name not set";
            _email = user?.email ?? data['email'] ?? "No email provided";
            _profileImagePath = data['profile_image_path'];

            if (data['born_date'] != null) {
              _age = _calculateAge(data['born_date']);
            }
          });
        }
      }

      _scanService.getRecentScans(1).listen((scans) {
        if (scans.isNotEmpty && mounted) {
          setState(() {
            _skinType = scans.first.ciltTipi;
            _isLoading = false;
          });
        } else if (mounted) {
          setState(() => _isLoading = false);
        }
      });
    } catch (e) {
      debugPrint("❌ Error loading profile: $e");
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String _calculateAge(dynamic bornDateData) {
    try {
      DateTime birthDate;
      if (bornDateData is String) {
        birthDate = DateFormat('MMMM dd, yyyy').parse(bornDateData);
      } else {
        return "Not set";
      }

      DateTime today = DateTime.now();
      int age = today.year - birthDate.year;
      if (today.month < birthDate.month ||
          (today.month == birthDate.month && today.day < birthDate.day)) {
        age--;
      }
      return "$age years";
    } catch (e) {
      return "Not set";
    }
  }

  // Bildirim izni isteyen fonksiyon - Sonucu bool döner
  Future<bool> _requestNotificationPermission(bool value) async {
    if (value) {
      PermissionStatus status = await Permission.notification.request();
      return status.isGranted;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: SingleChildScrollView(
              // Kaydırma pozisyonunu korumak için key ekleyebiliriz
              key: const PageStorageKey('profile_scroll'),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  const SectionHeader(title: "Personal Information"),

                  GestureDetector(
                    onTap: () => _navigateToPersonalInfo(context),
                    child: ProfileListTile(
                      icon: Icons.person,
                      title: "Full Name",
                      value: _fullName,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => _navigateToPersonalInfo(context),
                    child: ProfileListTile(
                      icon: Icons.email,
                      title: "Email",
                      value: _email,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => _navigateToPersonalInfo(context),
                    child: ProfileListTile(
                      icon: Icons.cake,
                      title: "Age",
                      value: _age,
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Scan History Section
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
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const ScanHistoryScreen(),
                            ),
                          ),
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

                  StreamBuilder<List<ScanResult>>(
                    stream: _scanService.getRecentScans(3),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const SizedBox(
                          height: 100,
                          child: Center(child: CircularProgressIndicator()),
                        );
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
                        children: historyData
                            .map(
                              (scan) => _buildPhotoHistoryCard(context, scan),
                            )
                            .toList(),
                      );
                    },
                  ),

                  const SizedBox(height: 20),
                  const SectionHeader(title: "Settings"),

                  // 🔥 FIX: StatefulBuilder kullanarak sadece bu kısmı rebuild ediyoruz
                  StatefulBuilder(
                    builder: (context, setLocalState) {
                      return Padding(
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
                              value: _isNotificationActive,
                              onChanged: (val) async {
                                bool isGranted =
                                    await _requestNotificationPermission(val);
                                // Sadece bu widget'ı günceller, sayfa en başa atmaz
                                setLocalState(() {
                                  _isNotificationActive = isGranted;
                                });
                                // Parent state'i sessizce güncelle (navigasyon vb. durumlar için)
                                _isNotificationActive = isGranted;
                              },
                              activeColor: const Color(0xFFD1E9F6),
                              activeTrackColor: Colors.blue.shade200,
                            ),
                          ],
                        ),
                      );
                    },
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
    ).then((_) => _loadProfileData());
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
                child:
                    (scan.imagePath != null &&
                        File(scan.imagePath!).existsSync())
                    ? Image.file(File(scan.imagePath!), fit: BoxFit.cover)
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
                  ),
                  const SizedBox(height: 4),
                  Text(
                    scan.date,
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
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

  Widget _buildHeader(BuildContext context) {
    return Column(
      children: [
        Container(
          width: double.infinity,
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
        Container(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              CircleAvatar(
                radius: 35,
                backgroundColor: Colors.grey.shade300,
                backgroundImage:
                    (_profileImagePath != null &&
                        File(_profileImagePath!).existsSync())
                    ? FileImage(File(_profileImagePath!))
                    : null,
                child:
                    (_profileImagePath == null ||
                        !File(_profileImagePath!).existsSync())
                    ? const Icon(Icons.person, size: 40, color: Colors.white)
                    : null,
              ),
              const SizedBox(width: 15),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _fullName,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(_email, style: const TextStyle(color: Colors.grey)),
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
                      children: [
                        const Icon(
                          Icons.auto_awesome,
                          size: 14,
                          color: Colors.amber,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          _skinType,
                          style: const TextStyle(
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
