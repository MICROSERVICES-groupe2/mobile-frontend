import '../../domain/entities/transaction.dart';

class TransactionModel extends Transaction {
  const TransactionModel({
    required super.id,
    required super.accountId,
    required super.type,
    required super.montant,
    required super.devise,
    required super.statut,
    super.description,
    required super.timestamp,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['id'] ?? '',
      accountId: json['accountId'] ?? '',
      type: json['type'] ?? 'UNKNOWN',
      montant: (json['montant'] ?? 0).toDouble(),
      devise: json['devise'] ?? 'XAF',
      statut: json['statut'] ?? 'PENDING',
      description: json['description'],
      timestamp: json['timestamp'] != null ? DateTime.parse(json['timestamp']) : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'accountId': accountId,
      'type': type,
      'montant': montant,
      'devise': devise,
      'statut': statut,
      'description': description,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}
