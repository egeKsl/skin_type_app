import 'package:flutter/material.dart';

class FaqItem {
  final String question;
  final String answer;
  bool isExpanded;

  FaqItem({
    required this.question,
    required this.answer,
    this.isExpanded = false,
  });
}

class FaqScreen extends StatefulWidget {
  const FaqScreen({super.key});

  @override
  State<FaqScreen> createState() => _FaqScreenState();
}

class _FaqScreenState extends State<FaqScreen> {
  final List<FaqItem> _faqData = [
    FaqItem(
      question: "What does the app do?",
      answer:
          "The app provides AI-powered skin analysis and personalized skincare guidance based on your skin type and needs.",
    ),
    FaqItem(
      question: "How accurate is the skin analysis?",
      answer:
          "The analysis uses advanced AI technology designed for high accuracy, but results may vary depending on individual differences.",
    ),
    FaqItem(
      question: "Are the product recommendations mandatory?",
      answer:
          "No, All recommendations are optional and meant to support your skincare decisions. You can continue using your own products.",
    ),
    FaqItem(
      question: "Is my personal data secure?",
      answer:
          "Yes. Your data is encrypted, stored safely, and never shared with third parties.",
    ),
    FaqItem(
      question: "Do I need an account to use the app?",
      answer:
          "Yes. An account allows you to save your skin analysis results, routines, and personalized recommendations.",
    ),
    FaqItem(
      question: "How often should I re-analyze my skin?",
      answer:
          "It is recommended to refresh your skin analysis every 2–4 weeks for the most accurate and updated results.",
    ),
    FaqItem(
      question: "Which skin types does the app support?",
      answer:
          "The app supports all major skin types, including oily, dry, combination, normal, and sensitive.",
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "FAQ",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          children: [
            // Arama Çubuğu
            _buildSearchBar(),
            const SizedBox(height: 20),

            // Sıkça Sorulan Sorular Listesi
            _buildCustomExpansionPanelList(),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: TextField(
        decoration: InputDecoration(
          icon: Icon(Icons.search, color: Colors.grey.shade600),
          hintText: "Search questions...",
          hintStyle: TextStyle(color: Colors.grey.shade600),
          border: InputBorder.none,
        ),
      ),
    );
  }

  Widget _buildCustomExpansionPanelList() {
    return Column(
      children: List.generate(_faqData.length, (index) {
        FaqItem item = _faqData[index];
        bool isExpanded = item.isExpanded;

        return Padding(
          padding: const EdgeInsets.only(bottom: 12.0),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              children: [
                // Başlık Alanı (Soru)
                InkWell(
                  onTap: () {
                    setState(() {
                      _faqData[index].isExpanded = !isExpanded;
                    });
                  },
                  borderRadius: BorderRadius.circular(15),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 18.0,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            item.question,
                            style: const TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 15,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                        Icon(
                          isExpanded
                              ? Icons.keyboard_arrow_up
                              : Icons.keyboard_arrow_down,
                          color: Colors.black54,
                        ),
                      ],
                    ),
                  ),
                ),

                // Cevap Alanı (Açıldığında Görünür)
                if (isExpanded)
                  Padding(
                    padding: const EdgeInsets.only(
                      left: 16.0,
                      right: 16.0,
                      bottom: 18.0,
                    ),
                    child: Text(
                      item.answer,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[700],
                        height: 1.4,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      }),
    );
  }
}
