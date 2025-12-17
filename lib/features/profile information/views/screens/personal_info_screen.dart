import 'package:flutter/material.dart';
import 'package:skin_type_app/constants/profile_colors.dart';
import 'package:skin_type_app/core/database/data_service.dart'; // Veritabanı servisi eklendi
import '../widgets/personal_info_widgets.dart';

class PersonalInfoScreen extends StatefulWidget {
  const PersonalInfoScreen({super.key});

  @override
  State<PersonalInfoScreen> createState() => _PersonalInfoScreenState();
}

class _PersonalInfoScreenState extends State<PersonalInfoScreen> {
  // --- State Değişkenleri ---

  // Düzenlenebilir alanlar için değişkenler
  String _fullName = "Emma Richardson";
  String _dateOfBirth = "March 15, 1992";

  String _selectedGender = "Female";

  // Varsayılan cilt tipi (Listeden biriyle eşleşmeli)
  String _selectedSkinType = "KARMA CİLT";

  // Veritabanından gelecek belirtiler listesi
  List<String> _belirtiler = [];
  bool _isLoading = true;

  // Yeni Cilt Tipi Seçenekleri
  final List<String> _skinTypeOptions = [
    "YAĞLI / AKNEYE EĞİLİMLİ CİLT",
    "KURU CİLT",
    "KARMA CİLT",
    "HASSAS / ROSACEA EĞİLİMLİ CİLT",
    "LEKELİ / PİGMENTASYON SORUNLU CİLT",
  ];

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  // Veritabanından belirtileri çekme fonksiyonu
  Future<void> _loadUserData() async {
    final storage = SkinAnalysisStorage();
    final loadedData = await storage.loadAnalysisData();

    if (loadedData != null) {
      if (mounted) {
        setState(() {
          // 'belirtiler' anahtarını kullanıyoruz
          _belirtiler = List<String>.from(loadedData['belirtiler'] ?? []);
          // Eğer veritabanında kayıtlı cilt tipi varsa onu seçili yap
          if (loadedData['cilt_tipi'] != null &&
              _skinTypeOptions.contains(loadedData['cilt_tipi'])) {
            _selectedSkinType = loadedData['cilt_tipi'];
          }
          _isLoading = false;
        });
      }
    } else {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // İsim veya Tarih düzenleme dialogu
  void _showEditDialog(
    String title,
    String currentValue,
    Function(String) onSave,
  ) {
    TextEditingController controller = TextEditingController(
      text: currentValue,
    );
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Edit $title"),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(hintText: "Enter new $title"),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: ProfileColors.primaryGreen,
              ),
              onPressed: () {
                onSave(controller.text);
                Navigator.pop(context);
              },
              child: const Text("Save", style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ProfileColors.background,
      appBar: AppBar(
        backgroundColor: ProfileColors.background,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: ProfileColors.textDark),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Personal Information",
          style: TextStyle(
            color: ProfileColors.textDark,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            // 1. Profil Resmi
            const ProfileImageWidget(),
            const SizedBox(height: 30),

            // 2. Form Alanları (Düzenlenebilir)
            InteractiveField(
              label: "Full Name",
              value: _fullName,
              onTap: () {
                _showEditDialog("Full Name", _fullName, (newValue) {
                  setState(() => _fullName = newValue);
                });
              },
            ),
            const SizedBox(height: 15),
            InteractiveField(
              label: "Date of Birth",
              value: _dateOfBirth,
              icon: Icons.calendar_today_outlined,
              onTap: () {
                _showEditDialog("Date of Birth", _dateOfBirth, (newValue) {
                  setState(() => _dateOfBirth = newValue);
                });
              },
            ),
            const SizedBox(height: 25),

            // 3. Cinsiyet Seçimi
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Gender (Optional)",
                style: TextStyle(color: ProfileColors.textLight, fontSize: 14),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: SelectableButton(
                    text: "Female",
                    isSelected: _selectedGender == "Female",
                    onTap: () => setState(() => _selectedGender = "Female"),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: SelectableButton(
                    text: "Male",
                    isSelected: _selectedGender == "Male",
                    onTap: () => setState(() => _selectedGender = "Male"),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: SelectableButton(
                    text: "Other",
                    isSelected: _selectedGender == "Other",
                    onTap: () => setState(() => _selectedGender = "Other"),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 25),

            // 4. Cilt Tipi Seçimi (YENİ LİSTE YAPISI)
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Skin Type",
                style: TextStyle(color: ProfileColors.textLight, fontSize: 14),
              ),
            ),
            const SizedBox(height: 10),
            // Uzun metinler için Column kullanıyoruz
            Column(
              children: _skinTypeOptions.map((type) {
                return SkinTypeCard(
                  text: type,
                  isSelected: _selectedSkinType == type,
                  onTap: () => setState(() => _selectedSkinType = type),
                );
              }).toList(),
            ),
            const SizedBox(height: 25),

            // 5. Cilt Sorunları (VERİTABANINDAN GELEN LİSTE - Read Only)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: ProfileColors.cardWhite,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.02),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Skin Concerns (Identified by Analysis)",
                    style: TextStyle(
                      color: ProfileColors.textLight,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 15),

                  // Liste boşsa veya yükleniyorsa durum kontrolü
                  if (_isLoading)
                    const Center(
                      child: CircularProgressIndicator(
                        color: ProfileColors.primaryGreen,
                      ),
                    )
                  else if (_belirtiler.isEmpty)
                    const Text(
                      "No specific concerns identified yet.",
                      style: TextStyle(color: Colors.grey),
                    )
                  else
                    ..._belirtiler.map((concern) {
                      return ReadOnlyListItem(label: concern);
                    }),
                ],
              ),
            ),
            // Alerji kısmı tamamen kaldırıldı.
            const SizedBox(height: 25),

            // 7. Bilgi Kutusu
            const InfoBoxWidget(),
            const SizedBox(height: 30),

            // 8. Alt Butonlar
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: const BorderSide(color: Colors.grey),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      "Cancel",
                      style: TextStyle(
                        color: ProfileColors.textDark,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      // Kaydetme işlemi buraya eklenebilir
                      // Örn: storage.saveProfile(_fullName, _dateOfBirth, _selectedSkinType);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ProfileColors.primaryGreen,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      "Save Changes",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
