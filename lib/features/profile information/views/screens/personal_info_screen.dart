import 'package:flutter/material.dart';
import 'package:skin_type_app/constants/profile_colors.dart';
import '../widgets/personal_info_widgets.dart'; // Oluşturduğumuz widget dosyasını çağırıyoruz

class PersonalInfoScreen extends StatefulWidget {
  const PersonalInfoScreen({super.key});

  @override
  State<PersonalInfoScreen> createState() => _PersonalInfoScreenState();
}

class _PersonalInfoScreenState extends State<PersonalInfoScreen> {
  // State Değişkenleri
  String _selectedGender = "Female";
  String _selectedSkinType = "Combination";

  final Map<String, bool> _skinConcerns = {
    "Acne & Breakouts": true,
    "Redness & Irritation": false,
    "Pigmentation & Dark Spots": true,
    "Aging & Fine Lines": true,
    "Dehydration & Dullness": false,
  };

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

            // 2. Form Alanları
            const ReadOnlyField(label: "Full Name", value: "Emma Richardson"),
            const SizedBox(height: 15),
            const ReadOnlyField(
              label: "Date of Birth",
              value: "March 15, 1992",
              icon: Icons.calendar_today_outlined,
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

            // 4. Cilt Tipi Seçimi
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Skin Type",
                style: TextStyle(color: ProfileColors.textLight, fontSize: 14),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: SkinTypeCard(
                    text: "Dry",
                    icon: Icons.water_drop_outlined,
                    isSelected: _selectedSkinType == "Dry",
                    onTap: () => setState(() => _selectedSkinType = "Dry"),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: SkinTypeCard(
                    text: "Oily",
                    icon: Icons.spa_outlined,
                    isSelected: _selectedSkinType == "Oily",
                    onTap: () => setState(() => _selectedSkinType = "Oily"),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: SkinTypeCard(
                    text: "Combination",
                    icon: Icons.layers_outlined,
                    isSelected: _selectedSkinType == "Combination",
                    onTap: () =>
                        setState(() => _selectedSkinType = "Combination"),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: SkinTypeCard(
                    text: "Sensitive",
                    icon: Icons.favorite_border,
                    isSelected: _selectedSkinType == "Sensitive",
                    onTap: () =>
                        setState(() => _selectedSkinType = "Sensitive"),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 25),

            // 5. Cilt Sorunları (Map döngüsü)
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
                    "Skin Concerns (Select all that apply)",
                    style: TextStyle(
                      color: ProfileColors.textLight,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 15),
                  ..._skinConcerns.keys.map((key) {
                    return CustomCheckboxItem(
                      label: key,
                      isChecked: _skinConcerns[key]!,
                      onTap: () {
                        setState(() {
                          _skinConcerns[key] = !_skinConcerns[key]!;
                        });
                      },
                    );
                  }),
                ],
              ),
            ),
            const SizedBox(height: 25),

            // 6. Alerjiler
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: ProfileColors.cardWhite,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    "Allergies / Sensitivities",
                    style: TextStyle(
                      color: ProfileColors.textLight,
                      fontSize: 12,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    "Fragrance, Essential Oils, Retinol",
                    style: TextStyle(color: Color(0xFFAAAAAA), fontSize: 16),
                  ),
                ],
              ),
            ),
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
                      // Kaydetme işlemi
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
