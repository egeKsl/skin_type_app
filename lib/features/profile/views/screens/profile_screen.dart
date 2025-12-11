import 'package:flutter/material.dart';
import 'package:skin_type_app/common/widgets/top_menu_overlay.dart';
// Yeni oluşturduğumuz widget'ları buraya çağırıyoruz:
import '../widgets/stat_card.dart';
import '../widgets/section_header.dart';
import '../widgets/profile_list_tile.dart';
import '../widgets/history_card.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 1. ÜST HEADER ALANI
            _buildHeader(context),

            // 2. İSTATİSTİK KARTLARI
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 20,
              ),
              child: Row(
                children: const [
                  Expanded(
                    child: StatCard(value: "87", label: "Skin Score"),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: StatCard(value: "42", label: "Days Active"),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: StatCard(value: "15", label: "Products"),
                  ),
                ],
              ),
            ),

            // 3. PERSONAL INFORMATION
            const SectionHeader(title: "Personal Information"),
            const ProfileListTile(
              icon: Icons.person,
              title: "Full Name",
              value: "Sarah Johnson",
            ),
            const ProfileListTile(
              icon: Icons.email,
              title: "Email",
              value: "sarah.j@email.com",
            ),
            const ProfileListTile(
              icon: Icons.phone,
              title: "Phone",
              value: "+1 (555) 123-4567",
            ),
            const ProfileListTile(
              icon: Icons.cake,
              title: "Age",
              value: "28 years",
            ),

            const SizedBox(height: 20),

            // 4. SCAN HISTORY
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  SectionHeader(
                    title: "Scan History",
                    padding: EdgeInsets.zero,
                  ),
                  Text(
                    "View All",
                    style: TextStyle(
                      color: Color(0xFF6B7C97),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),

            // Tarihçe Listesi
            const HistoryCard(
              title: "Full Face Scan",
              date: "2 days ago",
              score: "87",
              status: "Improving",
              statusColor: Color(0xFFD1E9F6),
            ),
            const HistoryCard(
              title: "Routine Check",
              date: "1 week ago",
              score: "82",
              status: "Stable",
              statusColor: Color(0xFFD1E9F6),
            ),
            const HistoryCard(
              title: "Initial Scan",
              date: "6 weeks ago",
              score: "68",
              status: "Baseline",
              statusColor: Color(0xFFD1E9F6),
            ),

            const SizedBox(height: 20),

            // 5. SETTINGS
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
              icon: Icons.help,
              title: "Help & Support",
              value: "",
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
    );
  }

  // Header kısmı sadece bu ekrana özel olduğu için private metod olarak burada bıraktık
  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 50, bottom: 20, left: 16, right: 16),
      color: Colors.white,
      child: Column(
        children: [
          Container(
            height: 60,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              color: const Color(0xFF6B7C97),
              borderRadius: BorderRadius.circular(5),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // BURASI GÜNCELLENDİ: IconButton Kullanıldı
                IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () {
                    Navigator.pop(context); // Bir önceki ekrana döner
                  },
                ),

                GestureDetector(
                  onTap: () {
                    showTopMenuOverlay(context);
                  },
                  child: const Icon(Icons.menu, color: Colors.white),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // ... Kalan kodlarınız aynı ...
          Row(
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
        ],
      ),
    );
  }
}
