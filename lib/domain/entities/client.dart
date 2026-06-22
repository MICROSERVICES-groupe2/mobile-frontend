import 'package:equatable/equatable.dart';

class Client extends Equatable {
  final String id;
  final String nom;
  final String prenom;
  final String email;
  final String telephone;
  final String dateNaissance;
  final String adresse;
  final String statut;
  final DateTime? dateCreation;
  final DateTime? dateMiseAJour;

  const Client({
    required this.id,
    required this.nom,
    required this.prenom,
    required this.email,
    required this.telephone,
    required this.dateNaissance,
    required this.adresse,
    required this.statut,
    this.dateCreation,
    this.dateMiseAJour,
  });

  Client copyWith({
    String? id,
    String? nom,
    String? prenom,
    String? email,
    String? telephone,
    String? dateNaissance,
    String? adresse,
    String? statut,
    DateTime? dateCreation,
    DateTime? dateMiseAJour,
  }) {
    return Client(
      id: id ?? this.id,
      nom: nom ?? this.nom,
      prenom: prenom ?? this.prenom,
      email: email ?? this.email,
      telephone: telephone ?? this.telephone,
      dateNaissance: dateNaissance ?? this.dateNaissance,
      adresse: adresse ?? this.adresse,
      statut: statut ?? this.statut,
      dateCreation: dateCreation ?? this.dateCreation,
      dateMiseAJour: dateMiseAJour ?? this.dateMiseAJour,
    );
  }

  @override
  List<Object?> get props => [id, nom, prenom, email, telephone, dateNaissance, adresse, statut, dateCreation, dateMiseAJour];
}
