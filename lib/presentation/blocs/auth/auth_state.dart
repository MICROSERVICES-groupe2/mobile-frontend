import 'package:equatable/equatable.dart';
import '../../../domain/entities/user.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthAuthenticated extends AuthState {
  final User user;

  const AuthAuthenticated(this.user);

  @override
  List<Object?> get props => [user];
}

class AuthUnauthenticated extends AuthState {}

class AuthError extends AuthState {
  final String message;

  const AuthError(this.message);

  @override
  List<Object?> get props => [message];
}

class AuthRequires2FA extends AuthState {
  final String email;

  const AuthRequires2FA(this.email);

  @override
  List<Object?> get props => [email];
}

class AuthRegisterSuccess extends AuthState {
  final String email;
  final String userId;
  final String? otp;

  const AuthRegisterSuccess(this.email, this.userId, {this.otp});

  @override
  List<Object?> get props => [email, userId, otp];
}

class AuthOtpSent extends AuthState {
  final String email;

  const AuthOtpSent(this.email);

  @override
  List<Object?> get props => [email];
}

class AuthOtpVerified extends AuthState {
  const AuthOtpVerified();

  @override
  List<Object?> get props => [];
}

class AuthProfileUpdated extends AuthState {
  final User user;

  const AuthProfileUpdated(this.user);

  @override
  List<Object?> get props => [user];
}
