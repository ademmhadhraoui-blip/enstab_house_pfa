import 'package:flutter/material.dart';
import 'package:enstabhouse/constants.dart';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context, "Help & Support", Icons.help_outline),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  _SectionLabel("FAQ"),
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
                  _SectionLabel("Contact"),
                  const SizedBox(height: 12),
                  _ActionTile(
                    icon: Icons.email_outlined,
                    title: "Email Support",
                    subtitle: "support@enstab.ucar.tn",
                    onTap: () {},
                  ),
                  const SizedBox(height: 12),
                  _ActionTile(
                    icon: Icons.chat_bubble_outline,
                    title: "Live Chat",
                    subtitle: "Available Mon–Fri, 9am–5pm",
                    onTap: () {},
                  ),
                  const SizedBox(height: 12),
                  _ActionTile(
                    icon: Icons.description_outlined,
                    title: "Terms of Service",
                    subtitle: "Read our terms",
                    onTap: () {},
                  ),
                  const SizedBox(height: 12),
                  _ActionTile(
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
            Text(title, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
          ],
        ),
      ],
    ),
  );
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);
  @override
  Widget build(BuildContext context) {
    return Text(text.toUpperCase(),
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1.2));
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

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ActionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
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
                  Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.black87)),
                  Text(subtitle, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}
