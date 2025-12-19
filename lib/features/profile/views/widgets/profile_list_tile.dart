import 'package:flutter/material.dart';

class ProfileListTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final Widget? trailing; // Switch gibi özel elemanlar için eklendi

  const ProfileListTile({
    super.key,
    required this.icon,
    required this.title,
    required this.value,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16.0),
          leading: CircleAvatar(
            backgroundColor: const Color(0xFFF5F7FA),
            child: Icon(icon, color: const Color(0xFF6B7C97), size: 20),
          ),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (value.isNotEmpty)
                Text(
                  title,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              Text(
                value.isNotEmpty ? value : title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
          trailing:
              trailing ??
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (title == "Language")
                    const Text(
                      "English",
                      style: TextStyle(color: Colors.grey, fontSize: 14),
                    ),
                  const SizedBox(width: 10),
                  const Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: Colors.grey,
                  ),
                ],
              ),
        ),
        const Divider(indent: 70, endIndent: 16, height: 1),
      ],
    );
  }
}
