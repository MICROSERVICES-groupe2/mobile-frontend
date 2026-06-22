import '../../domain/entities/affiliated_operator.dart';

class AffiliatedOperatorModel extends AffiliatedOperator {
  const AffiliatedOperatorModel({
    required super.id,
    required super.operatorCode,
    required super.operatorAccountId,
    super.dateAffiliation,
    required super.statut,
  });

  factory AffiliatedOperatorModel.fromJson(Map<String, dynamic> json) {
    return AffiliatedOperatorModel(
      id: json['id'] ?? '',
      operatorCode: json['operatorCode'] ?? '',
      operatorAccountId: json['operatorAccountId'] ?? '',
      dateAffiliation: json['dateAffiliation'] != null ? DateTime.tryParse(json['dateAffiliation']) : null,
      statut: json['statut'] ?? 'ACTIVE',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'operatorCode': operatorCode,
      'operatorAccountId': operatorAccountId,
      'dateAffiliation': dateAffiliation?.toIso8601String(),
      'statut': statut,
    };
  }
}
