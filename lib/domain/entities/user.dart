import 'package:equatable/equatable.dart';

class User extends Equatable {
  final String id;
  final String email;
  final String role;
  final String nom;
  final String? prenom;
  final String? phone;
  final bool twoFaEnabled;
  final bool isVerified;
  final String? avatarUrl;
  final String? clientId;

  const User({
    required this.id,
    required this.email,
    required this.role,
    required this.nom,
    this.prenom,
    this.phone,
    this.twoFaEnabled = false,
    this.isVerified = false,
    this.avatarUrl,
    this.clientId,
  });

  User copyWith({
    String? id,
    String? email,
    String? role,
    String? nom,
    String? prenom,
    String? phone,
    bool? twoFaEnabled,
    bool? isVerified,
    String? avatarUrl,
    String? clientId,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      role: role ?? this.role,
      nom: nom ?? this.nom,
      prenom: prenom ?? this.prenom,
      phone: phone ?? this.phone,
      twoFaEnabled: twoFaEnabled ?? this.twoFaEnabled,
      isVerified: isVerified ?? this.isVerified,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      clientId: clientId ?? this.clientId,
    );
  }

  @override
  List<Object?> get props => [id, email, role, nom, prenom, phone, twoFaEnabled, isVerified, avatarUrl, clientId];
}
