import 'package:equatable/equatable.dart';
import 'user.dart';

class RegisterResult extends Equatable {
  final User user;
  final String? otp;

  const RegisterResult({required this.user, this.otp});

  @override
  List<Object?> get props => [user, otp];
}
