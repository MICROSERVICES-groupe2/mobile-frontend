import 'package:dartz/dartz.dart';
import '../../../core/errors/failures.dart';
import '../../entities/user.dart';
import '../../repositories/auth_repository.dart';

class LoginUseCase {
  final AuthRepository repository;

  LoginUseCase(this.repository);

  Future<Either<Failure, User>> execute(
    String email,
    String password, {
    String? totpCode,
  }) async {
    return await repository.login(email, password, totpCode: totpCode);
  }
}
