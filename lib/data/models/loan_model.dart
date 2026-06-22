import '../../domain/entities/loan.dart';

class LoanModel extends Loan {
  const LoanModel({
    required super.id,
    required super.accountId,
    required super.montantInitial,
    required super.resteAPayer,
    required super.tauxInteret,
    required super.dureeMois,
    required super.statut,
    required super.dateCreation,
    super.dateProchainPaiement,
    required super.montantMensualite,
  });

  factory LoanModel.fromJson(Map<String, dynamic> json) {
    return LoanModel(
      id: json['id'] ?? '',
      accountId: json['accountId'] ?? '',
      montantInitial: (json['montantInitial'] ?? 0).toDouble(),
      resteAPayer: (json['resteAPayer'] ?? 0).toDouble(),
      tauxInteret: (json['tauxInteret'] ?? 0).toDouble(),
      dureeMois: json['dureeMois'] ?? 0,
      statut: json['statut'] ?? 'PENDING',
      dateCreation: json['dateCreation'] != null ? DateTime.parse(json['dateCreation']) : DateTime.now(),
      dateProchainPaiement: json['dateProchainPaiement'] != null ? DateTime.parse(json['dateProchainPaiement']) : null,
      montantMensualite: (json['montantMensualite'] ?? 0).toDouble(),
    );
  }
}
