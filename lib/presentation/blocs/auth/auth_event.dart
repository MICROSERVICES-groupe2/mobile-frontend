import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class LoginRequested extends AuthEvent {
  final String email;
  final String password;
  final String? totpCode;

  const LoginRequested({
    required this.email,
    required this.password,
    this.totpCode,
  });

  @override
  List<Object?> get props => [email, password, totpCode];
}

class LoginWithBiometricsRequested extends AuthEvent {}

class RegisterRequested extends AuthEvent {
  final String firstName;
  final String lastName;
  final String email;
  final String password;
  final String phone;

  const RegisterRequested({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.password,
    required this.phone,
  });

  @override
  List<Object?> get props => [firstName, lastName, email, password, phone];
}

class VerifyOtpRequested extends AuthEvent {
  final String userId;
  final String code;

  const VerifyOtpRequested({required this.userId, required this.code});

  @override
  List<Object?> get props => [userId, code];
}

class UpdateProfilePictureRequested extends AuthEvent {
  final String imagePath;

  const UpdateProfilePictureRequested({required this.imagePath});

  @override
  List<Object?> get props => [imagePath];
}

class TwoFAVerified extends AuthEvent {
  final String code;

  const TwoFAVerified({required this.code});

  @override
  List<Object?> get props => [code];
}

class LogoutRequested extends AuthEvent {}

class AuthCheckRequested extends AuthEvent {}
