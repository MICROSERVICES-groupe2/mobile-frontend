import '../../domain/entities/user.dart';

class UserModel extends User {
  const UserModel({
    required super.id,
    required super.email,
    required super.role,
    required super.nom,
    super.prenom,
    super.phone,
    super.twoFaEnabled,
    super.isVerified,
    super.avatarUrl,
    super.clientId,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    // Le backend auth-service expose firstName/lastName
    final nom = json['nom'] ?? json['lastName'] ?? '';
    final prenom = json['prenom'] ?? json['firstName'];
    return UserModel(
      id: json['id'] ?? '',
      email: json['email'] ?? '',
      role: json['role'] ?? '',
      nom: nom,
      prenom: prenom,
      phone: json['phone'],
      twoFaEnabled: json['twoFaEnabled'] ?? false,
      isVerified: json['isVerified'] ?? false,
      avatarUrl: json['avatarUrl'],
      clientId: json['clientId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'role': role,
      'nom': nom,
      'prenom': prenom,
      'phone': phone,
      'twoFaEnabled': twoFaEnabled,
      'isVerified': isVerified,
      'avatarUrl': avatarUrl,
      'clientId': clientId,
    };
  }
}
