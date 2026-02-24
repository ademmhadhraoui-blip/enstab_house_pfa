import 'package:flutter/material.dart';
import 'package:enstabhouse/constants.dart';

class AccountSettingsScreen extends StatelessWidget {
  const AccountSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: Column(
          children: [
            //  Header
            _buildHeader(context, "Account Settings", Icons.manage_accounts_outlined),

            //  Content
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  _SectionLabel("Personal Information"),
                  const SizedBox(height: 12),
                  _SettingField(label: "Full Name", value: "Ahmed Ben Salah", icon: Icons.person_outline),
                  const SizedBox(height: 12),
                  _SettingField(label: "Email", value: "ahmed@enstab.ucar.tn", icon: Icons.email_outlined),
                  const SizedBox(height: 12),
                  _SettingField(label: "Student ID", value: "2024-CS-1234", icon: Icons.badge_outlined),
                  const SizedBox(height: 24),
                  _SectionLabel("Security"),
                  const SizedBox(height: 12),
                  _SettingField(label: "Password", value: "••••••••", icon: Icons.lock_outline, isPassword: true),
                  const SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kPrimaryColor,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 52),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    child: const Text("Save Changes", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

//
// 🔴 Shared header builder
//
Widget _buildHeader(BuildContext context, String title, IconData icon) {
  return Container(
    width: double.infinity,
    padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
    decoration: const BoxDecoration(color: kPrimaryColor),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: const Icon(Icons.arrow_back, color: Colors.white, size: 28),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Icon(icon, color: Colors.white70, size: 32),
            const SizedBox(width: 12),
            Text(
              title,
              style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ],
    ),
  );
}

//
// Section label
//
class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);
  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1.2),
    );
  }
}

//
//  Setting field tile
//
class _SettingField extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final bool isPassword;

  const _SettingField({
    required this.label,
    required this.value,
    required this.icon,
    this.isPassword = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8)],
      ),
      child: Row(
        children: [
          Icon(icon, color: kPrimaryColor, size: 22),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                const SizedBox(height: 2),
                Text(value, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: Colors.black87)),
              ],
            ),
          ),
          const Icon(Icons.edit_outlined, color: Colors.grey, size: 18),
        ],
      ),
    );
  }
}
