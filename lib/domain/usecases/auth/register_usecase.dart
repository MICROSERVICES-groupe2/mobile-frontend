import 'package:dartz/dartz.dart';
import '../../../core/errors/failures.dart';
import '../../entities/register_result.dart';
import '../../repositories/auth_repository.dart';

class RegisterUseCase {
  final AuthRepository repository;

  RegisterUseCase(this.repository);

  Future<Either<Failure, RegisterResult>> execute(
    String firstName,
    String lastName,
    String email,
    String password,
    String phone,
  ) async {
    return await repository.register(
      firstName,
      lastName,
      email,
      password,
      phone,
    );
  }
}
