import 'dart:io';
import 'package:flutter/material.dart';
import 'package:skin_type_app/core/services/scan_service.dart';
import 'package:skin_type_app/features/scan details/views/screens/scan_detail_screen.dart';
import 'package:skin_type_app/models/scan_model.dart';

class ScanHistoryScreen extends StatelessWidget {
  const ScanHistoryScreen({super.key});

  // Helper function to show deletion confirmation dialog
  Future<void> _showDeleteConfirmation(
    BuildContext context,
    ScanService service,
    String scanId,
  ) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Delete Record"),
          content: const Text(
            "Are you sure you want to delete this scan history? This action cannot be undone.",
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("No", style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () async {
                Navigator.pop(context); // Close dialog
                try {
                  await service.deleteScan(scanId);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Record deleted successfully"),
                      ),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Failed to delete record")),
                    );
                  }
                }
              },
              child: const Text("Yes", style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final ScanService _scanService = ScanService();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: Column(
        children: [
          // 1. Header
          Container(
            padding: const EdgeInsets.only(
              top: 50,
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
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
                const SizedBox(width: 10),
                const Text(
                  "Scan History",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          // 2. Dynamic List (StreamBuilder)
          Expanded(
            child: StreamBuilder<List<ScanResult>>(
              stream: _scanService.getScans(),
              builder: (context, snapshot) {
                // Error State
                if (snapshot.hasError) {
                  return Center(
                    child: Text("An error occurred: ${snapshot.error}"),
                  );
                }

                // Loading State
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(color: Color(0xFF6B7C97)),
                  );
                }

                final historyData = snapshot.data ?? [];

                // Empty State
                if (historyData.isEmpty) {
                  return const Center(
                    child: Text(
                      "No scan history found.",
                      style: TextStyle(color: Colors.grey, fontSize: 16),
                    ),
                  );
                }

                // List View
                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: historyData.length,
                  itemBuilder: (context, index) {
                    final scan = historyData[index];
                    return _buildHistoryCard(context, _scanService, scan);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryCard(
    BuildContext context,
    ScanService service,
    ScanResult scan,
  ) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ScanDetailScreen(scanResult: scan),
          ),
        );
      },
      // LONG PRESS TO DELETE
      onLongPress: () => _showDeleteConfirmation(context, service, scan.id),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Image Area
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

            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    scan.ciltTipi,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2D3142),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    scan.date,
                    style: const TextStyle(color: Colors.grey, fontSize: 13),
                  ),
                  const SizedBox(height: 8),

                  // Match Chip
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE3F2FD),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      "Match: ${scan.benzerlikYuzdesi}",
                      style: const TextStyle(
                        color: Color(0xFF1565C0),
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}
