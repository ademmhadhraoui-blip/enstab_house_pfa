import 'package:flutter/material.dart';
import 'package:enstabhouse/constants.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  bool _pushNotifs = true;
  bool _emailNotifs = false;
  bool _clubActivity = true;
  bool _eventReminders = true;
  bool _newPosts = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context, "Notifications", Icons.notifications_outlined),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  _SectionLabel("Channels"),
                  const SizedBox(height: 12),
                  _ToggleTile(
                    icon: Icons.phone_android_outlined,
                    title: "Push Notifications",
                    subtitle: "Receive alerts on your device",
                    value: _pushNotifs,
                    onChanged: (v) => setState(() => _pushNotifs = v),
                  ),
                  const SizedBox(height: 12),
                  _ToggleTile(
                    icon: Icons.email_outlined,
                    title: "Email Notifications",
                    subtitle: "Get updates by email",
                    value: _emailNotifs,
                    onChanged: (v) => setState(() => _emailNotifs = v),
                  ),
                  const SizedBox(height: 24),
                  _SectionLabel("Activities"),
                  const SizedBox(height: 12),
                  _ToggleTile(
                    icon: Icons.group_outlined,
                    title: "Club Activity",
                    subtitle: "Posts and announcements from clubs",
                    value: _clubActivity,
                    onChanged: (v) => setState(() => _clubActivity = v),
                  ),
                  const SizedBox(height: 12),
                  _ToggleTile(
                    icon: Icons.event_outlined,
                    title: "Event Reminders",
                    subtitle: "Remind me before events start",
                    value: _eventReminders,
                    onChanged: (v) => setState(() => _eventReminders = v),
                  ),
                  const SizedBox(height: 12),
                  _ToggleTile(
                    icon: Icons.feed_outlined,
                    title: "New Posts",
                    subtitle: "Notify when someone posts",
                    value: _newPosts,
                    onChanged: (v) => setState(() => _newPosts = v),
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

class _ToggleTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _ToggleTile({
    required this.icon, required this.title, required this.subtitle,
    required this.value, required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
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
          Switch(value: value, onChanged: onChanged, activeColor: kPrimaryColor),
        ],
      ),
    );
  }
}
