import 'package:equatable/equatable.dart';

class Account extends Equatable {
  final String id;
  final String type;
  final double solde;
  final String devise;
  final String statut;
  final String? numero;

  const Account({
    required this.id,
    required this.type,
    required this.solde,
    required this.devise,
    required this.statut,
    this.numero,
  });

  @override
  List<Object?> get props => [id, type, solde, devise, statut, numero];
}
