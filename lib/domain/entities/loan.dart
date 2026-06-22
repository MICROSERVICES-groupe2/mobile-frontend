import 'package:equatable/equatable.dart';

class Loan extends Equatable {
  final String id;
  final String accountId;
  final double montantInitial;
  final double resteAPayer;
  final double tauxInteret;
  final int dureeMois;
  final String statut;
  final DateTime dateCreation;
  final DateTime? dateProchainPaiement;
  final double montantMensualite;

  const Loan({
    required this.id,
    required this.accountId,
    required this.montantInitial,
    required this.resteAPayer,
    required this.tauxInteret,
    required this.dureeMois,
    required this.statut,
    required this.dateCreation,
    this.dateProchainPaiement,
    required this.montantMensualite,
  });

  @override
  List<Object?> get props => [
        id,
        accountId,
        montantInitial,
        resteAPayer,
        tauxInteret,
        dureeMois,
        statut,
        dateCreation,
        dateProchainPaiement,
        montantMensualite,
      ];
}
