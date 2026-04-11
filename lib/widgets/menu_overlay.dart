import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:enstabhouse/constants.dart';
import 'package:enstabhouse/screens/settings/account_settings_screen.dart';
import 'package:enstabhouse/screens/settings/help_support_screen.dart';
import 'package:enstabhouse/screens/documents/documents_screen.dart';
import 'package:enstabhouse/screens/grade_calculator_screen.dart';
import 'package:enstabhouse/screens/admin/admin_panel_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Full-screen slide-in menu overlay.
///
/// Dynamically shows menu items based on the user's role:
/// - All authenticated users see: Account Settings, Documents, Help & Support
/// - Admin users additionally see: Admin Panel
/// - Visitors see: Help & Support, Log In
class MenuOverlay extends StatefulWidget {
  const MenuOverlay({super.key});

  @override
  State<MenuOverlay> createState() => _MenuOverlayState();
}

class _MenuOverlayState extends State<MenuOverlay> {
  String? _userRole;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserRole();
  }

  Future<void> _loadUserRole() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || user.isAnonymous) {
      if (mounted) setState(() => _isLoading = false);
      return;
    }
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      if (doc.exists && mounted) {
        setState(() {
          _userRole = (doc.data()?['role'] as String?)?.toLowerCase();
          _isLoading = false;
        });
      } else {
        if (mounted) setState(() => _isLoading = false);
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  bool get _isVisitor =>
      FirebaseAuth.instance.currentUser?.isAnonymous ?? false;

  bool get _isAdmin => _userRole == 'admin';

  @override
  Widget build(BuildContext context) {
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
                                _isVisitor
                                    ? "Visiting as Guest"
                                    : "My Account",
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 26,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              if (_isVisitor)
                                const Text(
                                  "Sign in to access all features",
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 13,
                                  ),
                                ),
                              if (_isAdmin)
                                Container(
                                  margin: const EdgeInsets.only(top: 6),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Text(
                                    '⚙ Administrator',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                    ),
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

                    // Account Settings — authenticated users only
                    if (!_isVisitor)
                      _buildMenuItem(
                        context: context,
                        icon: Icons.settings_outlined,
                        label: "Account Settings",
                        destination: const AccountSettingsScreen(),
                      ),

                    // Documents — everybody
                    _buildMenuItem(
                        context: context,
                        icon: Icons.folder_outlined,
                        label: "Documents",
                        destination: DocumentsScreen(isAdmin: _isAdmin),
                      ),

                    // Grade Calculator — authenticated users only
                    if (!_isVisitor)
                      _buildMenuItem(
                        context: context,
                        icon: Icons.calculate_outlined,
                        label: "Semester Average Calculator",
                        destination: const GradeCalculatorScreen(),
                      ),

                    // Admin Panel — admin only
                    if (_isAdmin)
                      _buildMenuItem(
                        context: context,
                        icon: Icons.admin_panel_settings_outlined,
                        label: "Admin Panel",
                        destination: const AdminPanelScreen(),
                        color: Colors.red.shade700,
                      ),

                    // Help & Support — everybody
                    _buildMenuItem(
                      context: context,
                      icon: Icons.help_outline,
                      label: "Help & Support",
                      destination: const HelpSupportScreen(),
                    ),

                    const Divider(height: 32, indent: 16, endIndent: 16),

                    // Log Out / Log In
                    ListTile(
                      leading: _isVisitor
                          ? Icon(Icons.login, color: kPrimaryColor)
                          : Icon(Icons.logout, color: kPrimaryColor),
                      title: _isVisitor
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
