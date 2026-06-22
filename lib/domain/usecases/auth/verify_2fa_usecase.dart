import 'package:dartz/dartz.dart';
import '../../../core/errors/failures.dart';
import '../../entities/user.dart';
import '../../repositories/auth_repository.dart';

class Verify2FAUseCase {
  final AuthRepository repository;

  Verify2FAUseCase(this.repository);

  Future<Either<Failure, User>> execute(String code) async {
    return await repository.verify2FA(code);
  }
}
