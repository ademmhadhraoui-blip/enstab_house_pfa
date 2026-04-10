import 'package:flutter/material.dart';
import 'package:enstabhouse/constants.dart';
import 'package:enstabhouse/widgets/settings_shared.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AccountSettingsScreen extends StatefulWidget {
  const AccountSettingsScreen({super.key});

  @override
  State<AccountSettingsScreen> createState() => _AccountSettingsScreenState();
}

class _AccountSettingsScreenState extends State<AccountSettingsScreen> {
  final _auth = FirebaseAuth.instance;
  bool _isLoading = true;

  // User data from Firestore
  String _fullName = '';
  String _email = '';
  String _phone = '';
  String _role = '';

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (doc.exists && mounted) {
        final data = doc.data()!;
        setState(() {
          _fullName = data['name'] ?? '';
          _email = data['email'] ?? user.email ?? '';
          _phone = data['phone'] ?? '';
          _role = data['role'] ?? '';
          _isLoading = false;
        });
      } else {
        if (mounted) {
          setState(() {
            _email = user.email ?? '';
            _isLoading = false;
          });
        }
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ── Change password dialog
  void _showChangePasswordDialog() {
    final currentPassCtrl = TextEditingController();
    final newPassCtrl = TextEditingController();
    final confirmPassCtrl = TextEditingController();
    bool obscureCurrent = true;
    bool obscureNew = true;
    bool obscureConfirm = true;
    bool isSubmitting = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: const Row(
              children: [
                Icon(Icons.lock_reset, color: kPrimaryColor, size: 26),
                SizedBox(width: 10),
                Text(
                  'Changer le mot de passe',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Current password
                  TextField(
                    controller: currentPassCtrl,
                    obscureText: obscureCurrent,
                    decoration: InputDecoration(
                      labelText: 'Mot de passe actuel',
                      prefixIcon: const Icon(Icons.lock_outline,
                          color: kPrimaryColor, size: 20),
                      suffixIcon: IconButton(
                        icon: Icon(
                          obscureCurrent
                              ? Icons.visibility_off
                              : Icons.visibility,
                          color: Colors.grey,
                          size: 20,
                        ),
                        onPressed: () => setDialogState(
                            () => obscureCurrent = !obscureCurrent),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide:
                            const BorderSide(color: kPrimaryColor, width: 1.5),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      filled: true,
                      fillColor: Colors.grey.shade50,
                    ),
                  ),
                  const SizedBox(height: 14),

                  // New password
                  TextField(
                    controller: newPassCtrl,
                    obscureText: obscureNew,
                    decoration: InputDecoration(
                      labelText: 'Nouveau mot de passe',
                      prefixIcon: const Icon(Icons.lock,
                          color: kPrimaryColor, size: 20),
                      suffixIcon: IconButton(
                        icon: Icon(
                          obscureNew
                              ? Icons.visibility_off
                              : Icons.visibility,
                          color: Colors.grey,
                          size: 20,
                        ),
                        onPressed: () =>
                            setDialogState(() => obscureNew = !obscureNew),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide:
                            const BorderSide(color: kPrimaryColor, width: 1.5),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      filled: true,
                      fillColor: Colors.grey.shade50,
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Confirm new password
                  TextField(
                    controller: confirmPassCtrl,
                    obscureText: obscureConfirm,
                    decoration: InputDecoration(
                      labelText: 'Confirmer le mot de passe',
                      prefixIcon: const Icon(Icons.lock,
                          color: kPrimaryColor, size: 20),
                      suffixIcon: IconButton(
                        icon: Icon(
                          obscureConfirm
                              ? Icons.visibility_off
                              : Icons.visibility,
                          color: Colors.grey,
                          size: 20,
                        ),
                        onPressed: () => setDialogState(
                            () => obscureConfirm = !obscureConfirm),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide:
                            const BorderSide(color: kPrimaryColor, width: 1.5),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      filled: true,
                      fillColor: Colors.grey.shade50,
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child:
                    const Text('Annuler', style: TextStyle(color: Colors.grey)),
              ),
              ElevatedButton(
                onPressed: isSubmitting
                    ? null
                    : () async {
                        // Validation
                        if (currentPassCtrl.text.isEmpty ||
                            newPassCtrl.text.isEmpty ||
                            confirmPassCtrl.text.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content:
                                    Text('Veuillez remplir tous les champs')),
                          );
                          return;
                        }
                        if (newPassCtrl.text.length < 6) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text(
                                    'Le mot de passe doit contenir au moins 6 caractères')),
                          );
                          return;
                        }
                        if (newPassCtrl.text != confirmPassCtrl.text) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text(
                                    'Les mots de passe ne correspondent pas')),
                          );
                          return;
                        }

                        setDialogState(() => isSubmitting = true);

                        try {
                          final user = _auth.currentUser!;
                          // Re-authenticate first
                          final credential = EmailAuthProvider.credential(
                            email: user.email!,
                            password: currentPassCtrl.text,
                          );
                          await user
                              .reauthenticateWithCredential(credential);

                          // Update password
                          await user.updatePassword(newPassCtrl.text);

                          if (ctx.mounted) Navigator.pop(ctx);
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                    'Mot de passe modifié avec succès ✓'),
                                backgroundColor: kPrimaryColor,
                              ),
                            );
                          }
                        } on FirebaseAuthException catch (e) {
                          setDialogState(() => isSubmitting = false);
                          String msg;
                          switch (e.code) {
                            case 'wrong-password':
                              msg = 'Mot de passe actuel incorrect';
                              break;
                            case 'weak-password':
                              msg =
                                  'Le nouveau mot de passe est trop faible';
                              break;
                            case 'requires-recent-login':
                              msg =
                                  'Veuillez vous reconnecter et réessayer';
                              break;
                            default:
                              msg = e.message ?? 'Erreur inconnue';
                          }
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(msg)),
                            );
                          }
                        } catch (e) {
                          setDialogState(() => isSubmitting = false);
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content: Text('Erreur: $e')),
                            );
                          }
                        }
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: kPrimaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: isSubmitting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text('Confirmer'),
              ),
            ],
          );
        },
      ),
    );
  }

  // ── Edit name dialog
  void _showEditNameDialog() {
    final nameCtrl = TextEditingController(text: _fullName);
    bool isSubmitting = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: const Row(
              children: [
                Icon(Icons.edit, color: kPrimaryColor, size: 24),
                SizedBox(width: 10),
                Text('Modifier le nom',
                    style:
                        TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
              ],
            ),
            content: TextField(
              controller: nameCtrl,
              autofocus: true,
              decoration: InputDecoration(
                labelText: 'Nom complet',
                prefixIcon: const Icon(Icons.person_outline,
                    color: kPrimaryColor, size: 20),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide:
                      const BorderSide(color: kPrimaryColor, width: 1.5),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                filled: true,
                fillColor: Colors.grey.shade50,
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child:
                    const Text('Annuler', style: TextStyle(color: Colors.grey)),
              ),
              ElevatedButton(
                onPressed: isSubmitting
                    ? null
                    : () async {
                        final newName = nameCtrl.text.trim();
                        if (newName.isEmpty) return;

                        setDialogState(() => isSubmitting = true);
                        try {
                          await FirebaseFirestore.instance
                              .collection('users')
                              .doc(_auth.currentUser!.uid)
                              .update({'name': newName});
                          if (mounted) {
                            setState(() => _fullName = newName);
                          }
                          if (ctx.mounted) Navigator.pop(ctx);
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Nom modifié avec succès ✓'),
                                backgroundColor: kPrimaryColor,
                              ),
                            );
                          }
                        } catch (e) {
                          setDialogState(() => isSubmitting = false);
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Erreur: $e')),
                            );
                          }
                        }
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: kPrimaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: isSubmitting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2),
                      )
                    : const Text('Enregistrer'),
              ),
            ],
          );
        },
      ),
    );
  }

  String _formatRole(String role) {
    if (role.isEmpty) return '';
    return role[0].toUpperCase() + role.substring(1);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: Column(
          children: [
            buildSettingsHeader(
                context, "Account Settings", Icons.manage_accounts_outlined),

            if (_isLoading)
              const Expanded(
                child: Center(
                  child: CircularProgressIndicator(color: kPrimaryColor),
                ),
              )
            else
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(20),
                  children: [
                    // ── Profile avatar
                    Center(
                      child: Column(
                        children: [
                          CircleAvatar(
                            radius: 40,
                            backgroundColor: kPrimaryColor,
                            child: Text(
                              _fullName.isNotEmpty
                                  ? _fullName[0].toUpperCase()
                                  : 'U',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            _fullName,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (_role.isNotEmpty)
                            Container(
                              margin: const EdgeInsets.only(top: 6),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 4),
                              decoration: BoxDecoration(
                                color: kPrimaryColor.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                _formatRole(_role),
                                style: const TextStyle(
                                  color: kPrimaryColor,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // ── Personal Information
                    const SectionLabel("Informations Personnelles"),
                    const SizedBox(height: 12),
                    _SettingField(
                      label: "Nom Complet",
                      value: _fullName.isNotEmpty ? _fullName : '—',
                      icon: Icons.person_outline,
                      onTap: _showEditNameDialog,
                    ),
                    const SizedBox(height: 12),
                    _SettingField(
                      label: "Email",
                      value: _email.isNotEmpty ? _email : '—',
                      icon: Icons.email_outlined,
                      // Email is not editable (linked to Firebase Auth)
                      editable: false,
                    ),
                    const SizedBox(height: 12),
                    _SettingField(
                      label: "Téléphone",
                      value: _phone.isNotEmpty ? _phone : '—',
                      icon: Icons.phone_outlined,
                      editable: false,
                    ),
                    const SizedBox(height: 12),
                    _SettingField(
                      label: "Rôle",
                      value: _role.isNotEmpty ? _formatRole(_role) : '—',
                      icon: Icons.badge_outlined,
                      editable: false,
                    ),

                    const SizedBox(height: 24),

                    // ── Security
                    const SectionLabel("Sécurité"),
                    const SizedBox(height: 12),
                    _SettingField(
                      label: "Mot de passe",
                      value: "••••••••",
                      icon: Icons.lock_outline,
                      isPassword: true,
                      onTap: _showChangePasswordDialog,
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

// ─────────────────────────────────────────────────────────────────────────────
//  SETTING FIELD TILE
// ─────────────────────────────────────────────────────────────────────────────
class _SettingField extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final bool isPassword;
  final bool editable;
  final VoidCallback? onTap;

  const _SettingField({
    required this.label,
    required this.value,
    required this.icon,
    this.isPassword = false,
    this.editable = true,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: editable ? onTap : null,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withValues(alpha: 0.04), blurRadius: 8),
          ],
        ),
        child: Row(
          children: [
            Icon(icon, color: kPrimaryColor, size: 22),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style:
                          const TextStyle(fontSize: 12, color: Colors.grey)),
                  const SizedBox(height: 2),
                  Text(value,
                      style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: Colors.black87)),
                ],
              ),
            ),
            if (editable)
              Icon(
                isPassword ? Icons.chevron_right : Icons.edit_outlined,
                color: Colors.grey,
                size: 18,
              ),
          ],
        ),
      ),
    );
  }
}
