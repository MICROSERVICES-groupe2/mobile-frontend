import 'package:equatable/equatable.dart';

class OcrParsedData extends Equatable {
  final String? nom;
  final String? prenom;
  final String? numeroId;
  final String? dateNaissance;
  final double? revenus;
  final String? employeur;
  final double? confidence;

  const OcrParsedData({
    this.nom,
    this.prenom,
    this.numeroId,
    this.dateNaissance,
    this.revenus,
    this.employeur,
    this.confidence,
  });

  @override
  List<Object?> get props => [nom, prenom, numeroId, dateNaissance, revenus, employeur, confidence];
}

class OcrResult extends Equatable {
  final String status;
  final String? documentId;
  final OcrParsedData parsedData;

  const OcrResult({
    required this.status,
    this.documentId,
    required this.parsedData,
  });

  @override
  List<Object?> get props => [status, documentId, parsedData];
}

class CreditScore extends Equatable {
  final int score;
  final String decision;
  final List<String> factors;

  const CreditScore({
    required this.score,
    required this.decision,
    required this.factors,
  });

  @override
  List<Object?> get props => [score, decision, factors];
}
