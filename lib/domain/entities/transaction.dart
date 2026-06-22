import 'package:equatable/equatable.dart';

class Transaction extends Equatable {
  final String id;
  final String accountId;
  final String type;
  final double montant;
  final String devise;
  final String statut;
  final String? description;
  final DateTime timestamp;

  const Transaction({
    required this.id,
    required this.accountId,
    required this.type,
    required this.montant,
    required this.devise,
    required this.statut,
    this.description,
    required this.timestamp,
  });

  @override
  List<Object?> get props => [id, accountId, type, montant, devise, statut, description, timestamp];
}
