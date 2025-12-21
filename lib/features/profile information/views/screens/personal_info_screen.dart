import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:skin_type_app/core/services/scan_service.dart';
import '../widgets/personal_info_widgets.dart';

class PersonalInfoScreen extends StatefulWidget {
  const PersonalInfoScreen({super.key});

  @override
  State<PersonalInfoScreen> createState() => _PersonalInfoScreenState();
}

class _PersonalInfoScreenState extends State<PersonalInfoScreen> {
  final ScanService _scanService = ScanService();
  final ImagePicker _picker = ImagePicker();

  // Color Constants from Profile Screen
  final Color primarySlate = const Color.fromRGBO(107, 124, 151, 1);
  final Color darkText = const Color(0xFF2D3142);
  final Color scaffoldBg = const Color(0xFFF5F7FA);

  // --- State Variables ---
  String _fullName = "Not set yet";
  String _bornDate = "Not set yet";
  String _selectedGender = "";
  String? _profileImagePath;

  List<String> _skinConcerns = [];
  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadAllUserData();
  }

  Future<void> _pickImage() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 500,
        imageQuality: 80,
      );

      if (pickedFile != null) {
        setState(() {
          _profileImagePath = pickedFile.path;
        });
      }
    } catch (e) {
      debugPrint("Error picking image: $e");
    }
  }

  Future<void> _loadAllUserData() async {
    try {
      final profileDoc = await _scanService.getUserProfile();
      if (profileDoc != null && profileDoc.exists) {
        final data = profileDoc.data() as Map<String, dynamic>;

        setState(() {
          _fullName = data['full_name'] ?? "Not set yet";
          _selectedGender = data['gender'] ?? "";
          _profileImagePath = data['profile_image_path'];

          final dynamic rawBornDate = data['born_date'];
          if (rawBornDate != null) {
            if (rawBornDate is Timestamp) {
              DateTime dateTime = rawBornDate.toDate();
              _bornDate = DateFormat('MMMM dd, yyyy').format(dateTime);
            } else {
              _bornDate = rawBornDate.toString();
            }
          } else {
            _bornDate = "Not set yet";
          }
        });
      }

      _scanService.getRecentScans(1).listen((scans) {
        if (scans.isNotEmpty && mounted) {
          setState(() {
            _skinConcerns = scans.first.belirtiler;
            _isLoading = false;
          });
        } else {
          if (mounted) setState(() => _isLoading = false);
        }
      });
    } catch (e) {
      debugPrint("Error loading user data: $e");
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleSave() async {
    setState(() => _isSaving = true);
    try {
      await _scanService.updateUserProfile(
        fullName: _fullName == "Not set yet" ? "" : _fullName,
        bornDate: _bornDate == "Not set yet" ? "" : _bornDate,
        gender: _selectedGender,
        profileImagePath: _profileImagePath,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Profile updated successfully!")),
        );
      }
    } catch (e) {
      debugPrint("Save error: $e");
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _showEditDialog(
    String title,
    String currentValue,
    Function(String) onSave,
  ) {
    TextEditingController controller = TextEditingController(
      text: currentValue == "Not set yet" ? "" : currentValue,
    );
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Edit $title"),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(hintText: "Enter $title"),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: primarySlate),
              onPressed: () {
                onSave(
                  controller.text.isEmpty ? "Not set yet" : controller.text,
                );
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
      backgroundColor: scaffoldBg,
      appBar: AppBar(
        backgroundColor: scaffoldBg,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: darkText),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Personal Information",
          style: TextStyle(
            color: darkText,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: primarySlate))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  GestureDetector(
                    onTap: _pickImage,
                    child: Center(
                      child: Stack(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                            child: CircleAvatar(
                              radius: 50,
                              backgroundColor: const Color(0xFFF0F4F8),
                              backgroundImage:
                                  (_profileImagePath != null &&
                                      File(_profileImagePath!).existsSync())
                                  ? FileImage(File(_profileImagePath!))
                                  : null,
                              child:
                                  (_profileImagePath == null ||
                                      !File(_profileImagePath!).existsSync())
                                  ? Icon(
                                      Icons.person,
                                      size: 50,
                                      color: primarySlate.withOpacity(0.5),
                                    )
                                  : null,
                            ),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: primarySlate,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white,
                                  width: 3,
                                ),
                              ),
                              child: const Icon(
                                Icons.camera_alt,
                                color: Colors.white,
                                size: 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  InteractiveField(
                    label: "Full Name",
                    value: _fullName,
                    onTap: () => _showEditDialog(
                      "Full Name",
                      _fullName,
                      (val) => setState(() => _fullName = val),
                    ),
                  ),
                  const SizedBox(height: 15),
                  InteractiveField(
                    label: "Date of Birth",
                    value: _bornDate,
                    icon: Icons.calendar_today_outlined,
                    onTap: () => _showEditDialog(
                      "Date of Birth",
                      _bornDate,
                      (val) => setState(() => _bornDate = val),
                    ),
                  ),
                  const SizedBox(height: 25),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Gender (Optional)",
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: ["Female", "Male", "Other"].map((gender) {
                      return Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: SelectableButton(
                            text: gender,
                            isSelected: _selectedGender == gender,
                            onTap: () {
                              setState(() {
                                if (_selectedGender == gender) {
                                  _selectedGender = "";
                                } else {
                                  _selectedGender = gender;
                                }
                              });
                            },
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 25),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
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
                        Text(
                          "Skin Concerns (From Latest Analysis)",
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 15),
                        if (_skinConcerns.isEmpty)
                          const Text(
                            "No scan history found.",
                            style: TextStyle(color: Colors.grey, fontSize: 13),
                          )
                        else
                          ..._skinConcerns.map(
                            (concern) => ReadOnlyListItem(label: concern),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 25),
                  const InfoBoxWidget(),
                  const SizedBox(height: 30),
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
                          child: Text(
                            "Cancel",
                            style: TextStyle(
                              color: darkText,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _isSaving ? null : _handleSave,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primarySlate,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: _isSaving
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text(
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
