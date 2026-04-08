import 'package:flutter/material.dart';
import 'package:enstabhouse/constants.dart';
import 'package:enstabhouse/widgets/settings_shared.dart';

class AccountSettingsScreen extends StatelessWidget {
  const AccountSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: Column(
          children: [
            buildSettingsHeader(context, "Account Settings", Icons.manage_accounts_outlined),

            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  SectionLabel("Personal Information"),
                  const SizedBox(height: 12),
                  _SettingField(label: "Full Name", value: "Ahmed Ben Salah", icon: Icons.person_outline),
                  const SizedBox(height: 12),
                  _SettingField(label: "Email", value: "ahmed@enstab.ucar.tn", icon: Icons.email_outlined),
                  const SizedBox(height: 12),
                  _SettingField(label: "Student ID", value: "2024-CS-1234", icon: Icons.badge_outlined),
                  const SizedBox(height: 24),
                  SectionLabel("Security"),
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
