import 'package:dartz/dartz.dart';
import '../../../core/errors/failures.dart';
import '../../entities/user.dart';
import '../../repositories/auth_repository.dart';

class VerifyRegistrationOtpUseCase {
  final AuthRepository repository;

  VerifyRegistrationOtpUseCase(this.repository);

  Future<Either<Failure, User>> execute(String userId, String code) async {
    return await repository.verifyRegistrationOtp(userId, code);
  }
}
