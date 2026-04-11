/// Régime de calcul de la note d'une matière.
enum Regime {
  /// note = contrôle × 0.4 + examen × 0.6
  mixte4060,

  /// note = contrôle × 0.5 + examen × 0.5
  mixte5050,

  /// note = contrôle
  controleContinu,
}

/// Représente une matière avec son coefficient et son régime de calcul.
class Matiere {
  final String nom;
  final double coefficient;
  final Regime regime;

  const Matiere({
    required this.nom,
    required this.coefficient,
    required this.regime,
  });

  /// Indique si cette matière requiert une note d'examen.
  bool get requiresExamen =>
      regime == Regime.mixte4060 || regime == Regime.mixte5050;

  /// Libellé lisible du régime.
  String get regimeLabel {
    switch (regime) {
      case Regime.mixte4060:
        return 'Mixte (40/60)';
      case Regime.mixte5050:
        return 'Mixte (50/50)';
      case Regime.controleContinu:
        return 'Continuous Assessment';
    }
  }
}

/// Représente une Unité d'Enseignement contenant plusieurs matières.
class UE {
  final String nom;
  final List<Matiere> matieres;

  const UE({required this.nom, required this.matieres});

  /// Somme des coefficients de cette UE.
  double get totalCoefficients =>
      matieres.fold(0.0, (sum, m) => sum + m.coefficient);
}

/// Représente un semestre complet avec ses métadonnées et ses UEs.
class Semester {
  final String id;       // 'S1' or 'S2'
  final String label;    // 'Semester 1' or 'Semester 2'
  final String subtitle; // Description courte
  final List<UE> ues;

  const Semester({
    required this.id,
    required this.label,
    required this.subtitle,
    required this.ues,
  });

  /// Somme totale des coefficients du semestre.
  double get totalCoefficients =>
      ues.fold(0.0, (sum, ue) => sum + ue.totalCoefficients);

  /// Nombre total de matières du semestre.
  int get totalMatieres =>
      ues.fold(0, (sum, ue) => sum + ue.matieres.length);
}

/// Données statiques de tous les semestres — 1ère année Technologies Avancées.
class SemesterData {
  /// Liste de tous les semestres disponibles.
  static const List<Semester> semesters = [sempiereS1, semestreS2];

  // ─────────────────────────────────────────────
  //  S1 — Semestre 1
  // ─────────────────────────────────────────────
  static const Semester sempiereS1 = Semester(
    id: 'S1',
    label: 'Semester 1',
    subtitle: '1st Year · Advanced Technologies',
    ues: [
      UE(
        nom: 'UE1-1 : Math-Info 1',
        matieres: [
          Matiere(
            nom: 'Analyse pour l\'ingénieur',
            coefficient: 2.5,
            regime: Regime.mixte4060,
          ),
          Matiere(
            nom: 'Probabilités',
            coefficient: 2,
            regime: Regime.mixte4060,
          ),
          Matiere(
            nom: 'Python for Data Science',
            coefficient: 1,
            regime: Regime.controleContinu,
          ),
          Matiere(
            nom: 'Algorithmique et Programmation',
            coefficient: 3,
            regime: Regime.mixte5050,
          ),
        ],
      ),
      UE(
        nom: 'UE1-2 : Sciences de l\'ingénieur 1',
        matieres: [
          Matiere(
            nom: 'Physique pour l\'ingénieur',
            coefficient: 2,
            regime: Regime.mixte4060,
          ),
          Matiere(
            nom: 'Mécanique des fluides',
            coefficient: 2,
            regime: Regime.mixte5050,
          ),
          Matiere(
            nom: 'Semi-conducteurs',
            coefficient: 2,
            regime: Regime.mixte5050,
          ),
        ],
      ),
      UE(
        nom: 'UE1-3 : Techniques de l\'ingénieur 1',
        matieres: [
          Matiere(
            nom: 'Circuits et systèmes électriques',
            coefficient: 3,
            regime: Regime.mixte5050,
          ),
          Matiere(
            nom: 'Métrologie pour l\'ingénieur',
            coefficient: 1.5,
            regime: Regime.controleContinu,
          ),
          Matiere(
            nom: 'Systèmes mécaniques pour la Robotique',
            coefficient: 1.5,
            regime: Regime.mixte4060,
          ),
        ],
      ),
      UE(
        nom: 'UE1-4 : Socio-économiques 1',
        matieres: [
          Matiere(
            nom: 'Anglais 1',
            coefficient: 2,
            regime: Regime.controleContinu,
          ),
          Matiere(
            nom: 'Comptabilité et Gestion d\'entreprise',
            coefficient: 2,
            regime: Regime.controleContinu,
          ),
          Matiere(
            nom: 'Techniques de communication',
            coefficient: 1.5,
            regime: Regime.controleContinu,
          ),
        ],
      ),
    ],
  );

  // ─────────────────────────────────────────────
  //  S2 — Semestre 2
  // ─────────────────────────────────────────────
  static const Semester semestreS2 = Semester(
    id: 'S2',
    label: 'Semester 2',
    subtitle: '1st Year · Advanced Technologies',
    ues: [
      UE(
        nom: 'UE1-5 : Mathématiques pour l\'ingénieur 1',
        matieres: [
          Matiere(
            nom: 'Analyse numérique',
            coefficient: 2,
            regime: Regime.mixte5050,
          ),
          Matiere(
            nom: 'Optimisation',
            coefficient: 2,
            regime: Regime.mixte4060,
          ),
          Matiere(
            nom: 'Statistiques pour l\'ingénieur',
            coefficient: 2,
            regime: Regime.mixte4060,
          ),
        ],
      ),
      UE(
        nom: 'UE1-6 : Outils digitaux pour l\'ingénieur 1',
        matieres: [
          Matiere(
            nom: 'Introduction à l\'AI',
            coefficient: 1,
            regime: Regime.controleContinu,
          ),
          Matiere(
            nom: 'Programmation orientée objet',
            coefficient: 2.5,
            regime: Regime.mixte5050,
          ),
          Matiere(
            nom: 'Outils numériques pour l\'ingénieur 2 : CATIA',
            coefficient: 1.5,
            regime: Regime.controleContinu,
          ),
        ],
      ),
      UE(
        nom: 'UE1-7 : Sciences de l\'ingénieur 2',
        matieres: [
          Matiere(
            nom: 'Thermodynamique pour l\'ingénieur',
            coefficient: 2,
            regime: Regime.mixte4060,
          ),
          Matiere(
            nom: 'Electronique des composants',
            coefficient: 2.5,
            regime: Regime.mixte5050,
          ),
          Matiere(
            nom: 'Asservissement et Régulation Industrielle',
            coefficient: 2.5,
            regime: Regime.mixte5050,
          ),
          Matiere(
            nom: 'Projet de synthèse 1',
            coefficient: 1.5,
            regime: Regime.controleContinu,
          ),
        ],
      ),
      UE(
        nom: 'UE1-8 : Socio-économiques 2',
        matieres: [
          Matiere(
            nom: 'Anglais 2',
            coefficient: 2,
            regime: Regime.controleContinu,
          ),
          Matiere(
            nom: 'Droit',
            coefficient: 1.5,
            regime: Regime.controleContinu,
          ),
          Matiere(
            nom: 'Philo pour l\'ingénieur',
            coefficient: 1.5,
            regime: Regime.controleContinu,
          ),
          Matiere(
            nom: 'Économie et économie verte',
            coefficient: 2,
            regime: Regime.controleContinu,
          ),
        ],
      ),
    ],
  );
}
