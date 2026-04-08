import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:enstabhouse/constants.dart';
import 'package:enstabhouse/screens/settings/account_settings_screen.dart';
import 'package:enstabhouse/screens/settings/help_support_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Full-screen slide-in menu overlay.
class MenuOverlay extends StatefulWidget {
  const MenuOverlay({super.key});

  @override
  State<MenuOverlay> createState() => _MenuOverlayState();
}

class _MenuOverlayState extends State<MenuOverlay> {
  @override
  Widget build(BuildContext context) {
    final isVisitor =
        FirebaseAuth.instance.currentUser?.isAnonymous ?? false;
    return Stack(
      children: [
        // Left 15% — blurred background
        Positioned(
          left: 0,
          top: 0,
          bottom: 0,
          width: MediaQuery.of(context).size.width * 0.15,
          child: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
              child: Container(
                color: Colors.black.withValues(alpha: 0.35),
              ),
            ),
          ),
        ),

        // Right 85% — menu panel
        Align(
          alignment: Alignment.centerRight,
          child: FractionallySizedBox(
            widthFactor: 0.85,
            child: Material(
              color: Colors.white,
              child: SafeArea(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.fromLTRB(20, 40, 20, 24),
                      decoration: const BoxDecoration(color: kPrimaryColor),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                isVisitor
                                    ? "Visiting as Guest"
                                    : "My Account",
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 26,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              if (isVisitor)
                                const Text(
                                  "Sign in to access all features",
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 13,
                                  ),
                                ),
                            ],
                          ),
                          GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: const Icon(Icons.close,
                                color: Colors.white, size: 26),
                          ),
                        ],
                      ),
                    ),

                    // Menu items
                    const SizedBox(height: 8),
                    if (!isVisitor)
                      _buildMenuItem(
                        context: context,
                        icon: Icons.settings_outlined,
                        label: "Account Settings",
                        destination: const AccountSettingsScreen(),
                      ),
                    _buildMenuItem(
                      context: context,
                      icon: Icons.help_outline,
                      label: "Help & Support",
                      destination: const HelpSupportScreen(),
                    ),

                    const Divider(height: 32, indent: 16, endIndent: 16),

                    // Log Out / Log In
                    ListTile(
                      leading: isVisitor
                          ? Icon(Icons.login, color: kPrimaryColor)
                          : Icon(Icons.logout, color: kPrimaryColor),
                      title: isVisitor
                          ? Text(
                              'Log In',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: kPrimaryColor,
                              ),
                            )
                          : Text(
                              'Log out',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: kPrimaryColor,
                              ),
                            ),
                      trailing:
                          Icon(Icons.chevron_right, color: Colors.grey[400]),
                      onTap: () {
                        Navigator.pushNamedAndRemoveUntil(
                          context,
                          '/login',
                          (route) => false,
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMenuItem({
    required BuildContext context,
    required IconData icon,
    required String label,
    Color color = Colors.black87,
    required Widget destination,
  }) {
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(
        label,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: color,
        ),
      ),
      trailing: Icon(Icons.chevron_right, color: Colors.grey[400]),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => destination),
        );
      },
    );
  }
}
