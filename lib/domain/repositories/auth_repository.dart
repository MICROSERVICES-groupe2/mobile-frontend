import 'package:dartz/dartz.dart';
import '../../../core/errors/failures.dart';
import '../entities/register_result.dart';
import '../entities/user.dart';

abstract class AuthRepository {
  Future<Either<Failure, User>> login(
    String email,
    String password, {
    String? totpCode,
  });
  Future<Either<Failure, RegisterResult>> register(
    String firstName,
    String lastName,
    String email,
    String password,
    String phone,
  );
  Future<Either<Failure, User>> verifyRegistrationOtp(String userId, String code);
  Future<Either<Failure, User>> verify2FA(String code);
  Future<Either<Failure, User>> loginWithBiometrics();
  Future<Either<Failure, User>> updateProfilePicture(String imagePath);
  Future<Either<Failure, void>> logout();
  Future<Either<Failure, bool>> isAuthenticated();
  Future<Either<Failure, void>> sendFcmToken(String token);
}
