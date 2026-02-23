import 'package:flutter/material.dart';
import 'package:enstabhouse/constants.dart';

class AppearanceScreen extends StatefulWidget {
  const AppearanceScreen({super.key});

  @override
  State<AppearanceScreen> createState() => _AppearanceScreenState();
}

class _AppearanceScreenState extends State<AppearanceScreen> {
  String _selectedTheme = "Light";
  String _selectedFont = "Default";
  double _fontSize = 16;

  final List<String> _themes = ["Light", "Dark", "System"];
  final List<String> _fonts = ["Default", "Serif", "Monospace"];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context, "Appearance", Icons.palette_outlined),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  _SectionLabel("Theme"),
                  const SizedBox(height: 12),

                  // Theme selector
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8)],
                    ),
                    child: Row(
                      children: _themes.map((theme) {
                        final bool selected = _selectedTheme == theme;
                        return Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => _selectedTheme = theme),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: selected ? kPrimaryColor : Colors.transparent,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                theme,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: selected ? Colors.white : Colors.black54,
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),

                  const SizedBox(height: 24),
                  _SectionLabel("Font Style"),
                  const SizedBox(height: 12),

                  ...(_fonts.map((font) {
                    final bool selected = _selectedFont == font;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: GestureDetector(
                        onTap: () => setState(() => _selectedFont = font),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            border: selected ? Border.all(color: kPrimaryColor, width: 2) : null,
                            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8)],
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.text_fields, color: selected ? kPrimaryColor : Colors.grey),
                              const SizedBox(width: 12),
                              Text(font,
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w500,
                                    color: selected ? kPrimaryColor : Colors.black87,
                                  )),
                              const Spacer(),
                              if (selected) const Icon(Icons.check_circle, color: kPrimaryColor, size: 20),
                            ],
                          ),
                        ),
                      ),
                    );
                  })),

                  const SizedBox(height: 24),
                  _SectionLabel("Font Size"),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8)],
                    ),
                    child: Column(
                      children: [
                        Text("Preview text at size ${_fontSize.round()}",
                            style: TextStyle(fontSize: _fontSize, color: Colors.black87)),
                        Slider(
                          value: _fontSize,
                          min: 12,
                          max: 22,
                          divisions: 5,
                          activeColor: kPrimaryColor,
                          label: _fontSize.round().toString(),
                          onChanged: (v) => setState(() => _fontSize = v),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: const [
                            Text("A", style: TextStyle(fontSize: 12, color: Colors.grey)),
                            Text("A", style: TextStyle(fontSize: 22, color: Colors.grey)),
                          ],
                        ),
                      ],
                    ),
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
