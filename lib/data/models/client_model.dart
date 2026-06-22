import '../../domain/entities/client.dart';

class ClientModel extends Client {
  const ClientModel({
    required super.id,
    required super.nom,
    required super.prenom,
    required super.email,
    required super.telephone,
    required super.dateNaissance,
    required super.adresse,
    required super.statut,
    super.dateCreation,
    super.dateMiseAJour,
  });

  factory ClientModel.fromJson(Map<String, dynamic> json) {
    return ClientModel(
      id: json['id'] ?? '',
      nom: json['nom'] ?? '',
      prenom: json['prenom'] ?? '',
      email: json['email'] ?? '',
      telephone: json['telephone'] ?? '',
      dateNaissance: json['dateNaissance'] ?? '',
      adresse: json['adresse'] ?? '',
      statut: json['statut'] ?? 'PENDING',
      dateCreation: json['dateCreation'] != null ? DateTime.tryParse(json['dateCreation']) : null,
      dateMiseAJour: json['dateMiseAJour'] != null ? DateTime.tryParse(json['dateMiseAJour']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nom': nom,
      'prenom': prenom,
      'email': email,
      'telephone': telephone,
      'dateNaissance': dateNaissance,
      'adresse': adresse,
      'statut': statut,
      'dateCreation': dateCreation?.toIso8601String(),
      'dateMiseAJour': dateMiseAJour?.toIso8601String(),
    };
  }
}
