import 'package:equatable/equatable.dart';

class AffiliatedOperator extends Equatable {
  final String id;
  final String operatorCode;
  final String operatorAccountId;
  final DateTime? dateAffiliation;
  final String statut;

  const AffiliatedOperator({
    required this.id,
    required this.operatorCode,
    required this.operatorAccountId,
    this.dateAffiliation,
    required this.statut,
  });

  @override
  List<Object?> get props => [id, operatorCode, operatorAccountId, dateAffiliation, statut];
}
