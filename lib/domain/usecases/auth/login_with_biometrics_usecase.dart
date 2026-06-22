import 'package:dartz/dartz.dart';
import '../../../core/errors/failures.dart';
import '../../entities/user.dart';
import '../../repositories/auth_repository.dart';

class LoginWithBiometricsUseCase {
  final AuthRepository repository;

  LoginWithBiometricsUseCase(this.repository);

  Future<Either<Failure, User>> execute() async {
    return await repository.loginWithBiometrics();
  }
}
