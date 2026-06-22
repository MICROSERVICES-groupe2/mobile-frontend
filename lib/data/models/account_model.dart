import '../../domain/entities/account.dart';

class AccountModel extends Account {
  const AccountModel({
    required super.id,
    required super.type,
    required super.solde,
    required super.devise,
    required super.statut,
    super.numero,
  });

  factory AccountModel.fromJson(Map<String, dynamic> json) {
    return AccountModel(
      id: json['id'] ?? '',
      type: json['type'] ?? 'UNKNOWN',
      solde: (json['solde'] ?? 0).toDouble(),
      devise: json['devise'] ?? 'XAF',
      statut: json['statut'] ?? 'ACTIVE',
      numero: json['numero'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'solde': solde,
      'devise': devise,
      'statut': statut,
      'numero': numero,
    };
  }
}
