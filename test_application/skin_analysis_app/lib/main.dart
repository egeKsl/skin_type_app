import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'API Test',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // API URL'si - DEĞİŞTİRMEN GEREKECEK
  String apiUrl = "https://backend-server-skin-app--vertex-api-c4832.us-central1.hosted.app/analyze-skin";
  
  File? selectedImage;
  String result = "";
  bool isLoading = false;

  // Galeriden fotoğraf seç
  void pickImage() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);
    
    if (image != null) {
      setState(() {
        selectedImage = File(image.path);
        result = "";
      });
    }
  }

  // API'ye fotoğraf gönder
  void sendToApi() async {
    if (selectedImage == null) {
      showMessage("Lütfen önce fotoğraf seçin");
      return;
    }

    setState(() {
      isLoading = true;
      result = "Analiz ediliyor...";
    });

    try {
      // Multipart request oluştur
    var request = http.MultipartRequest(
      'POST',  // ✅ POST method
      Uri.parse(apiUrl),
    );

    request.files.add(
      await http.MultipartFile.fromPath(
        'image', // ✅ Backend'deki field adıyla aynı
        selectedImage!.path,
      ),
    );

      // Gönder
      var response = await request.send();
      var responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        var json = jsonDecode(responseBody);
        setState(() {
          result = json['result'] ?? "Sonuç bulunamadı";
        });
      } else {
        setState(() {
          result = "Hata: ${response.statusCode}\n$responseBody";
        });
      }
    } catch (error) {
      setState(() {
        result = "Hata oluştu:\n$error";
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void showMessage(String text) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(text))
    );
  }

  void changeApiUrl() {
    showDialog(
      context: context,
      builder: (context) {
        String newUrl = apiUrl;
        return AlertDialog(
          title: const Text("API URL Değiştir"),
          content: TextField(
            autofocus: true,
            decoration: const InputDecoration(hintText: "API endpoint"),
            onChanged: (value) => newUrl = value,
            controller: TextEditingController(text: apiUrl),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("İptal"),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  apiUrl = newUrl;
                });
                Navigator.pop(context);
                showMessage("API URL güncellendi");
              },
              child: const Text("Kaydet"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("API Test"),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: changeApiUrl,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // API URL bilgisi
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "API Endpoint:",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    apiUrl,
                    style: TextStyle(
                      color: apiUrl.contains("localhost") 
                          ? Colors.orange 
                          : Colors.green,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Fotoğraf seç butonu
            ElevatedButton(
              onPressed: pickImage,
              child: const Text("Fotoğraf Seç"),
            ),

            const SizedBox(height: 20),

            // Seçilen fotoğraf
            Container(
              height: 200,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8),
              ),
              child: selectedImage != null
                  ? Image.file(selectedImage!, fit: BoxFit.cover)
                  : const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.photo, size: 50, color: Colors.grey),
                          Text("Fotoğraf seçilmedi"),
                        ],
                      ),
                    ),
            ),

            const SizedBox(height: 20),

            // Gönder butonu
            ElevatedButton(
              onPressed: isLoading ? null : sendToApi,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                padding: const EdgeInsets.all(16),
              ),
              child: isLoading
                  ? const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(color: Colors.white),
                        ),
                        SizedBox(width: 10),
                        Text("Gönderiliyor..."),
                      ],
                    )
                  : const Text(
                      "API'ye Gönder",
                      style: TextStyle(fontSize: 16),
                    ),
            ),

            const SizedBox(height: 20),

            // Sonuç
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.blue),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: SingleChildScrollView(
                  child: Text(
                    result.isEmpty ? "Sonuç burada görünecek..." : result,
                    style: TextStyle(
                      fontSize: 16,
                      color: result.contains("Hata") ? Colors.red : Colors.black,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}