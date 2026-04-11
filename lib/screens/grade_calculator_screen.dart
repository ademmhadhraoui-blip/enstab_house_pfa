import 'package:flutter/material.dart';
import 'package:enstabhouse/constants.dart';
import 'package:enstabhouse/models/semester_s1.dart';
import 'package:enstabhouse/services/grade_calculator_service.dart';

// ════════════════════════════════════════════════════════════════════
//  1. SEMESTER SELECTION SCREEN
// ════════════════════════════════════════════════════════════════════

/// Entry point — lets the student choose between S1 and S2.
class GradeCalculatorScreen extends StatelessWidget {
  const GradeCalculatorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: Column(
          children: [
            // ─── Header
            _buildHeader(context),

            // ─── Semester cards
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
                children: [
                  // Info
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.blue.shade100),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.school_outlined,
                            color: Colors.blue.shade700, size: 22),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Select a semester to calculate your average.\n'
                            '1st Year — Advanced Technologies.',
                            style: TextStyle(
                              color: Colors.blue.shade800,
                              fontSize: 13,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Semester cards
                  for (final semester in SemesterData.semesters) ...[
                    _SemesterCard(semester: semester),
                    const SizedBox(height: 16),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [kPrimaryColor, kPrimaryDarkColor],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: const Icon(Icons.arrow_back, color: Colors.white, size: 28),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.calculate_outlined,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(width: 14),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Semester Average Calculator',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Choose your semester',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Interactive card for selecting a semester.
class _SemesterCard extends StatelessWidget {
  final Semester semester;
  const _SemesterCard({required this.semester});

  @override
  Widget build(BuildContext context) {
    final isS1 = semester.id == 'S1';
    final gradient = isS1
        ? [const Color(0xFF4A148C), const Color(0xFF7B1FA2)]
        : [const Color(0xFF006064), const Color(0xFF00897B)];
    final icon = isS1 ? Icons.looks_one_rounded : Icons.looks_two_rounded;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => _SemesterCalculatorPage(semester: semester),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: gradient,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: gradient[0].withValues(alpha: 0.35),
              blurRadius: 14,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: Colors.white, size: 32),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    semester.label,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    semester.subtitle,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.75),
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _chip('${semester.ues.length} UEs'),
                      const SizedBox(width: 8),
                      _chip('${semester.totalMatieres} Subjects'),
                      const SizedBox(width: 8),
                      _chip('Coeff ${semester.totalCoefficients}'),
                    ],
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: Colors.white.withValues(alpha: 0.6),
              size: 18,
            ),
          ],
        ),
      ),
    );
  }

  Widget _chip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════
//  2. CALCULATOR PAGE (for a given semester)
// ════════════════════════════════════════════════════════════════════

class _SemesterCalculatorPage extends StatefulWidget {
  final Semester semester;
  const _SemesterCalculatorPage({required this.semester});

  @override
  State<_SemesterCalculatorPage> createState() =>
      _SemesterCalculatorPageState();
}

class _SemesterCalculatorPageState extends State<_SemesterCalculatorPage>
    with SingleTickerProviderStateMixin {
  // Controllers : controle[nomMatière] et examen[nomMatière]
  final Map<String, TextEditingController> _controleControllers = {};
  final Map<String, TextEditingController> _examenControllers = {};
  final _formKey = GlobalKey<FormState>();

  // Résultats
  bool _showResults = false;
  double? _moyenneGenerale;
  List<UEResult> _ueResults = [];
  List<MatiereResult> _matieresEchouees = [];

  // Animation
  late AnimationController _animController;
  late Animation<double> _fadeAnim;

  List<UE> get _ues => widget.semester.ues;

  @override
  void initState() {
    super.initState();

    for (final ue in _ues) {
      for (final matiere in ue.matieres) {
        _controleControllers[matiere.nom] = TextEditingController();
        if (matiere.requiresExamen) {
          _examenControllers[matiere.nom] = TextEditingController();
        }
      }
    }

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnim = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOutCubic,
    );
  }

  @override
  void dispose() {
    for (final c in _controleControllers.values) {
      c.dispose();
    }
    for (final c in _examenControllers.values) {
      c.dispose();
    }
    _animController.dispose();
    super.dispose();
  }

  double? _parseNote(TextEditingController? controller) {
    if (controller == null) return null;
    final text = controller.text.trim().replaceAll(',', '.');
    if (text.isEmpty) return null;
    return double.tryParse(text);
  }

  void _calculer() {
    if (!_formKey.currentState!.validate()) return;

    final Map<String, double?> notes = {};

    for (final ue in _ues) {
      for (final matiere in ue.matieres) {
        final controle = _parseNote(_controleControllers[matiere.nom]);
        final examen = _parseNote(_examenControllers[matiere.nom]);

        notes[matiere.nom] = GradeCalculatorService.calculerNoteMatiere(
          regime: matiere.regime,
          controle: controle,
          examen: examen,
        );
      }
    }

    setState(() {
      _moyenneGenerale =
          GradeCalculatorService.calculerMoyenneGenerale(_ues, notes);
      _ueResults = GradeCalculatorService.calculerResultatsUE(_ues, notes);
      _matieresEchouees =
          GradeCalculatorService.matieresNonValidees(_ues, notes);
      _showResults = true;
    });

    _animController.forward(from: 0);
  }

  void _reinitialiser() {
    for (final c in _controleControllers.values) {
      c.clear();
    }
    for (final c in _examenControllers.values) {
      c.clear();
    }
    setState(() {
      _showResults = false;
      _moyenneGenerale = null;
      _ueResults = [];
      _matieresEchouees = [];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: Form(
                key: _formKey,
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                  children: [
                    _buildInfoCard(),
                    const SizedBox(height: 20),

                    for (int i = 0; i < _ues.length; i++) ...[
                      _buildUESection(_ues[i], i),
                      const SizedBox(height: 16),
                    ],

                    _buildActionButtons(),

                    if (_showResults) ...[
                      const SizedBox(height: 24),
                      FadeTransition(
                        opacity: _fadeAnim,
                        child: _buildResultsSection(),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ──────────────────────────────────────────────
  //  Header
  // ──────────────────────────────────────────────
  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [kPrimaryColor, kPrimaryDarkColor],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: const Icon(Icons.arrow_back, color: Colors.white, size: 28),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.calculate_outlined,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Average Calculator',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${widget.semester.label} — ${widget.semester.subtitle}',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ──────────────────────────────────────────────
  //  Info Card
  // ──────────────────────────────────────────────
  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.shade100),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: Colors.blue.shade700, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Enter your continuous assessment and exam grades for each subject. '
              'Empty fields will be ignored in the calculation.',
              style: TextStyle(
                color: Colors.blue.shade800,
                fontSize: 12.5,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ──────────────────────────────────────────────
  //  UE Section
  // ──────────────────────────────────────────────
  Widget _buildUESection(UE ue, int ueIndex) {
    final colors = [
      Colors.indigo,
      Colors.teal,
      Colors.deepOrange,
      Colors.purple,
    ];
    final accentColor = colors[ueIndex % colors.length];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // UE title bar
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.08),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
              border: Border(
                bottom: BorderSide(
                  color: accentColor.withValues(alpha: 0.15),
                ),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 4,
                  height: 24,
                  decoration: BoxDecoration(
                    color: accentColor,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    ue.nom,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: accentColor.shade700,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: accentColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Coeff: ${ue.totalCoefficients}',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: accentColor.shade700,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Matières
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            child: Column(
              children: [
                for (int i = 0; i < ue.matieres.length; i++) ...[
                  _buildMatiereRow(ue.matieres[i], accentColor),
                  if (i < ue.matieres.length - 1)
                    Divider(height: 24, color: Colors.grey.shade200),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ──────────────────────────────────────────────
  //  Matière Row
  // ──────────────────────────────────────────────
  Widget _buildMatiereRow(Matiere matiere, MaterialColor accentColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          matiere.nom,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            _buildTag(
              'Coeff ${matiere.coefficient}',
              accentColor.withValues(alpha: 0.1),
              accentColor.shade700,
            ),
            const SizedBox(width: 6),
            _buildTag(
              matiere.regimeLabel,
              Colors.grey.shade100,
              Colors.grey.shade700,
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _buildNoteField(
                controller: _controleControllers[matiere.nom]!,
                label: 'Continuous Assessment',
                icon: Icons.edit_note,
              ),
            ),
            if (matiere.requiresExamen) ...[
              const SizedBox(width: 12),
              Expanded(
                child: _buildNoteField(
                  controller: _examenControllers[matiere.nom]!,
                  label: 'Exam',
                  icon: Icons.school_outlined,
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }

  Widget _buildTag(String text, Color bg, Color fg) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: fg),
      ),
    );
  }

  Widget _buildNoteField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      validator: GradeCalculatorService.validateNote,
      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(fontSize: 12, color: Colors.grey.shade600),
        prefixIcon: Icon(icon, size: 18, color: Colors.grey.shade500),
        hintText: '/20',
        hintStyle: TextStyle(fontSize: 12, color: Colors.grey.shade400),
        filled: true,
        fillColor: Colors.grey.shade50,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: kPrimaryColor, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.red.shade300),
        ),
        isDense: true,
      ),
    );
  }

  // ──────────────────────────────────────────────
  //  Action Buttons
  // ──────────────────────────────────────────────
  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: _reinitialiser,
            icon: const Icon(Icons.refresh, size: 18),
            label: const Text('Reset'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.grey.shade700,
              side: BorderSide(color: Colors.grey.shade400),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          flex: 2,
          child: ElevatedButton.icon(
            onPressed: _calculer,
            icon: const Icon(Icons.calculate, size: 20),
            label: const Text(
              'Calculate Average',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: kPrimaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ──────────────────────────────────────────────
  //  Results Section
  // ──────────────────────────────────────────────
  Widget _buildResultsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildMoyenneGeneraleCard(),
        const SizedBox(height: 16),

        for (final ueResult in _ueResults) ...[
          _buildUEResultCard(ueResult),
          const SizedBox(height: 12),
        ],

        if (_matieresEchouees.isNotEmpty) ...[
          const SizedBox(height: 8),
          _buildEchoueesSection(),
        ],

        if (_matieresEchouees.isNotEmpty) ...[
          const SizedBox(height: 16),
          _buildSimulationSection(),
        ],
      ],
    );
  }

  Widget _buildMoyenneGeneraleCard() {
    final moy = _moyenneGenerale;
    final isValid = moy != null && moy >= 10;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isValid
              ? [Colors.green.shade600, Colors.green.shade800]
              : moy != null
                  ? [Colors.red.shade600, Colors.red.shade800]
                  : [Colors.grey.shade600, Colors.grey.shade800],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color:
                (isValid ? Colors.green : Colors.red).withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            '${widget.semester.label.toUpperCase()} — OVERALL AVERAGE',
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            moy != null ? moy.toStringAsFixed(2) : '—',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 42,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            '/20',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.7),
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              moy == null
                  ? 'No grades entered'
                  : isValid
                      ? '✓ Semester Passed'
                      : '✗ Semester Not Passed',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUEResultCard(UEResult ueResult) {
    final isValid = ueResult.moyenne >= 10;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isValid ? Colors.green.shade200 : Colors.red.shade200,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 6,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isValid ? Colors.green : Colors.red,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  ueResult.ue.nom,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color:
                      isValid ? Colors.green.shade50 : Colors.red.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  ueResult.moyenne.toStringAsFixed(2),
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: isValid
                        ? Colors.green.shade700
                        : Colors.red.shade700,
                  ),
                ),
              ),
            ],
          ),
          if (ueResult.matiereResults.isNotEmpty) ...[
            const SizedBox(height: 10),
            ...ueResult.matiereResults.map((mr) => Padding(
                  padding: const EdgeInsets.only(left: 16, bottom: 4),
                  child: Row(
                    children: [
                      Icon(
                        mr.isValidated
                            ? Icons.check_circle_outline
                            : Icons.cancel_outlined,
                        size: 14,
                        color: mr.isValidated
                            ? Colors.green
                            : Colors.red.shade400,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          mr.matiere.nom,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ),
                      Text(
                        mr.note.toStringAsFixed(2),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: mr.isValidated
                              ? Colors.green.shade700
                              : Colors.red.shade600,
                        ),
                      ),
                    ],
                  ),
                )),
          ],
        ],
      ),
    );
  }

  Widget _buildEchoueesSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.warning_amber_rounded,
                  color: Colors.orange.shade700, size: 20),
              const SizedBox(width: 8),
              Text(
                'Failed Subjects (${_matieresEchouees.length})',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange.shade800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          for (final m in _matieresEchouees)
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                children: [
                  Icon(Icons.close, size: 14, color: Colors.red.shade400),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      m.matiere.nom,
                      style: TextStyle(
                        fontSize: 12.5,
                        color: Colors.grey.shade800,
                      ),
                    ),
                  ),
                  Text(
                    '${m.note.toStringAsFixed(2)}/20',
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                      color: Colors.red.shade700,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  // ──────────────────────────────────────────────
  //  Simulation Section
  // ──────────────────────────────────────────────
  Widget _buildSimulationSection() {
    final simulatable = _matieresEchouees
        .where((m) => m.matiere.regime != Regime.controleContinu)
        .toList();

    if (simulatable.isEmpty) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.lightbulb_outline,
                  color: Colors.blue.shade700, size: 20),
              const SizedBox(width: 8),
              Text(
                'Simulation — Required Exam Grade',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Exam grade required to reach 10/20 :',
            style: TextStyle(fontSize: 12, color: Colors.blue.shade700),
          ),
          const SizedBox(height: 10),
          for (final m in simulatable) _buildSimulationRow(m),
        ],
      ),
    );
  }

  Widget _buildSimulationRow(MatiereResult m) {
    final controle = _parseNote(_controleControllers[m.matiere.nom]);
    double? requise;
    if (controle != null) {
      requise = GradeCalculatorService.simulerNoteExamenRequise(
        regime: m.matiere.regime,
        controle: controle,
      );
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(
            requise != null ? Icons.trending_up : Icons.block,
            size: 16,
            color: requise != null
                ? Colors.green.shade600
                : Colors.red.shade400,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              m.matiere.nom,
              style: TextStyle(fontSize: 12.5, color: Colors.grey.shade800),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: requise != null
                  ? Colors.green.shade100
                  : Colors.red.shade100,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              requise != null
                  ? '≥ ${requise.toStringAsFixed(2)}'
                  : 'Impossible',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: requise != null
                    ? Colors.green.shade800
                    : Colors.red.shade700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
