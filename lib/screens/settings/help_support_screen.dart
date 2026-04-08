import 'package:flutter/material.dart';
import 'package:enstabhouse/constants.dart';
import 'package:enstabhouse/widgets/settings_shared.dart';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: Column(
          children: [
            buildSettingsHeader(context, "Help & Support", Icons.help_outline),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  SectionLabel("FAQ"),
                  const SizedBox(height: 12),
                  _FaqTile(
                    question: "How do I reset my password?",
                    answer: "Go to Account Settings → Security → Change Password and follow the steps.",
                  ),
                  _FaqTile(
                    question: "Can I delete my account?",
                    answer: "Yes. Go to Account Settings → scroll to the bottom and tap 'Delete Account'.",
                  ),
                  const SizedBox(height: 24),
                  SectionLabel("Contact"),
                  const SizedBox(height: 12),
                  ActionTile(
                    icon: Icons.email_outlined,
                    title: "Email Support",
                    subtitle: "support@enstab.ucar.tn",
                    onTap: () {},
                  ),
                  const SizedBox(height: 12),
                  ActionTile(
                    icon: Icons.chat_bubble_outline,
                    title: "Live Chat",
                    subtitle: "Available Mon–Fri, 9am–5pm",
                    onTap: () {},
                  ),
                  const SizedBox(height: 12),
                  ActionTile(
                    icon: Icons.description_outlined,
                    title: "Terms of Service",
                    subtitle: "Read our terms",
                    onTap: () {},
                  ),
                  const SizedBox(height: 12),
                  ActionTile(
                    icon: Icons.policy_outlined,
                    title: "Privacy Policy",
                    subtitle: "Read our privacy policy",
                    onTap: () {},
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

class _FaqTile extends StatefulWidget {
  final String question;
  final String answer;
  const _FaqTile({required this.question, required this.answer});
  @override
  State<_FaqTile> createState() => _FaqTileState();
}

class _FaqTileState extends State<_FaqTile> {
  bool _expanded = false;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => setState(() => _expanded = !_expanded),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: _expanded ? Border.all(color: kPrimaryColor.withValues(alpha: 0.4)) : null,
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8)],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(widget.question,
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.black87)),
                ),
                Icon(_expanded ? Icons.expand_less : Icons.expand_more, color: kPrimaryColor),
              ],
            ),
            if (_expanded) ...[
              const SizedBox(height: 10),
              const Divider(height: 1, color: Color(0xFFEEEEEE)),
              const SizedBox(height: 10),
              Text(widget.answer, style: const TextStyle(fontSize: 14, color: Colors.black54, height: 1.5)),
            ],
          ],
        ),
      ),
    );
  }
}
