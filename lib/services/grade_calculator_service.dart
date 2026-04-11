import 'package:enstabhouse/models/semester_s1.dart';

/// Résultat du calcul d'une matière.
class MatiereResult {
  final Matiere matiere;
  final double note;
  final bool isValidated;

  const MatiereResult({
    required this.matiere,
    required this.note,
    required this.isValidated,
  });
}

/// Résultat du calcul d'une UE.
class UEResult {
  final UE ue;
  final double moyenne;
  final bool isValidated;
  final List<MatiereResult> matiereResults;

  const UEResult({
    required this.ue,
    required this.moyenne,
    required this.isValidated,
    required this.matiereResults,
  });
}

/// Service contenant toute la logique de calcul de moyennes.
///
/// Toutes les fonctions acceptent une liste d'UEs en paramètre pour
/// fonctionner avec n'importe quel semestre (S1, S2, etc.).
class GradeCalculatorService {
  /// Valide qu'une note est entre 0 et 20.
  /// Retourne `null` si valide, un message d'erreur sinon.
  static String? validateNote(String? value) {
    if (value == null || value.trim().isEmpty) return null; // champ optionnel
    final n = double.tryParse(value.trim().replaceAll(',', '.'));
    if (n == null) return 'Nombre invalide';
    if (n < 0 || n > 20) return 'Entre 0 et 20';
    return null;
  }

  /// Calcule la note finale d'une matière selon son régime.
  ///
  /// [controle] : note du contrôle continu (obligatoire).
  /// [examen]   : note d'examen (obligatoire pour mixte_40_60 et mixte_50_50).
  ///
  /// Retourne `null` si les notes fournies sont insuffisantes.
  static double? calculerNoteMatiere({
    required Regime regime,
    required double? controle,
    double? examen,
  }) {
    if (controle == null) return null;

    switch (regime) {
      case Regime.mixte4060:
        if (examen == null) return null;
        return (controle * 0.4) + (examen * 0.6);
      case Regime.mixte5050:
        if (examen == null) return null;
        return (controle * 0.5) + (examen * 0.5);
      case Regime.controleContinu:
        return controle;
    }
  }

  /// Calcule la moyenne pondérée d'une UE.
  ///
  /// [notes] : Map\<nomMatière, noteFinalCalculée\>.
  /// Retourne `null` si aucune note n'est disponible.
  static double? calculerMoyenneUE(UE ue, Map<String, double?> notes) {
    double sommeNotes = 0;
    double sommeCoeffs = 0;

    for (final matiere in ue.matieres) {
      final note = notes[matiere.nom];
      if (note == null) continue;
      sommeNotes += note * matiere.coefficient;
      sommeCoeffs += matiere.coefficient;
    }

    if (sommeCoeffs == 0) return null;
    return sommeNotes / sommeCoeffs;
  }

  /// Calcule la moyenne générale d'un semestre.
  ///
  /// [ues]   : la liste des UEs du semestre courant.
  /// [notes] : Map\<nomMatière, noteFinalCalculée\>.
  /// Retourne `null` si aucune note n'est disponible.
  static double? calculerMoyenneGenerale(
    List<UE> ues,
    Map<String, double?> notes,
  ) {
    double sommeNotes = 0;
    double sommeCoeffs = 0;

    for (final ue in ues) {
      for (final matiere in ue.matieres) {
        final note = notes[matiere.nom];
        if (note == null) continue;
        sommeNotes += note * matiere.coefficient;
        sommeCoeffs += matiere.coefficient;
      }
    }

    if (sommeCoeffs == 0) return null;
    return sommeNotes / sommeCoeffs;
  }

  /// Retourne les matières non validées (note < 10).
  static List<MatiereResult> matieresNonValidees(
    List<UE> ues,
    Map<String, double?> notes,
  ) {
    final results = <MatiereResult>[];

    for (final ue in ues) {
      for (final matiere in ue.matieres) {
        final note = notes[matiere.nom];
        if (note != null && note < 10) {
          results.add(MatiereResult(
            matiere: matiere,
            note: note,
            isValidated: false,
          ));
        }
      }
    }

    return results;
  }

  /// Simule la note d'examen nécessaire pour atteindre [target] (défaut 10).
  ///
  /// Pour les matières en contrôle continu, retourne `null` (pas d'examen).
  /// Pour les matières mixtes, retourne la note d'examen requise.
  /// Retourne `null` si la cible est inatteignable (> 20).
  static double? simulerNoteExamenRequise({
    required Regime regime,
    required double controle,
    double target = 10.0,
  }) {
    switch (regime) {
      case Regime.controleContinu:
        return null; // Pas d'examen possible
      case Regime.mixte4060:
        // target = controle * 0.4 + examen * 0.6
        // examen = (target - controle * 0.4) / 0.6
        final examen = (target - controle * 0.4) / 0.6;
        if (examen < 0 || examen > 20) return null;
        return examen;
      case Regime.mixte5050:
        // target = controle * 0.5 + examen * 0.5
        // examen = (target - controle * 0.5) / 0.5
        final examen = (target - controle * 0.5) / 0.5;
        if (examen < 0 || examen > 20) return null;
        return examen;
    }
  }

  /// Calcule les résultats détaillés par UE.
  static List<UEResult> calculerResultatsUE(
    List<UE> ues,
    Map<String, double?> notes,
  ) {
    final results = <UEResult>[];

    for (final ue in ues) {
      final matiereResults = <MatiereResult>[];

      for (final matiere in ue.matieres) {
        final note = notes[matiere.nom];
        if (note != null) {
          matiereResults.add(MatiereResult(
            matiere: matiere,
            note: note,
            isValidated: note >= 10,
          ));
        }
      }

      final moyenne = calculerMoyenneUE(ue, notes);

      results.add(UEResult(
        ue: ue,
        moyenne: moyenne ?? 0,
        isValidated: moyenne != null && moyenne >= 10,
        matiereResults: matiereResults,
      ));
    }

    return results;
  }
}
