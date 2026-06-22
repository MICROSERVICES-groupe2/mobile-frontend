import 'dart:typed_data';
import 'package:dartz/dartz.dart';
import '../../../core/errors/exceptions.dart';
import '../../../core/errors/failures.dart';
import '../../../core/storage/secure_storage.dart';
import '../../domain/entities/register_result.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';
import '../models/user_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final SecureStorage secureStorage;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.secureStorage,
  });

  @override
  Future<Either<Failure, User>> login(
    String email,
    String password, {
    String? totpCode,
  }) async {
    try {
      final response = await remoteDataSource.login(email, password, totpCode: totpCode);
      
      if (response['accessToken'] != null) {
        await secureStorage.saveToken(response['accessToken']);
        if (response['refreshToken'] != null) {
          await secureStorage.saveRefreshToken(response['refreshToken']);
        }
      }

      final user = UserModel.fromJson(response['user'] ?? {});
      return Right(user);
    } on UnauthorizedException {
      return const Left(UnauthorizedFailure('Identifiants incorrects.'));
    } on TwoFARequiredException catch (e) {
      return Left(TwoFARequiredFailure(e.email));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return const Left(ServerFailure('Erreur inattendue.'));
    }
  }

  @override
  Future<Either<Failure, RegisterResult>> register(
    String firstName,
    String lastName,
    String email,
    String password,
    String phone,
  ) async {
    try {
      final response = await remoteDataSource.register(
        firstName,
        lastName,
        email,
        password,
        phone,
      );

      final user = UserModel.fromJson(response['user'] ?? {});
      final otp = response['otp']?.toString();
      return Right(RegisterResult(user: user, otp: otp));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return const Left(ServerFailure('Erreur inattendue lors de l\'inscription.'));
    }
  }

  @override
  Future<Either<Failure, User>> verifyRegistrationOtp(String userId, String code) async {
    try {
      final response = await remoteDataSource.verifyRegistrationOtp(userId, code);
      final user = UserModel.fromJson(response['user'] ?? {});
      return Right(user);
    } on UnauthorizedException {
      return const Left(UnauthorizedFailure('Code OTP invalide.'));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return const Left(ServerFailure('Erreur inattendue.'));
    }
  }

  @override
  Future<Either<Failure, User>> verify2FA(String code) async {
    try {
      final response = await remoteDataSource.verify2FA(code);
      
      if (response['accessToken'] != null) {
        await secureStorage.saveToken(response['accessToken']);
      }

      final user = UserModel.fromJson(response['user'] ?? {});
      return Right(user);
    } on UnauthorizedException {
      return const Left(UnauthorizedFailure('Code 2FA invalide.'));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return const Left(ServerFailure('Erreur inattendue.'));
    }
  }

  @override
  Future<Either<Failure, User>> loginWithBiometrics() async {
    try {
      final refreshToken = await secureStorage.getRefreshToken();
      if (refreshToken == null || refreshToken.isEmpty) {
        return const Left(UnauthorizedFailure('Aucune session enregistrée pour la biométrie.'));
      }
      final response = await remoteDataSource.loginWithBiometrics(refreshToken);
      
      if (response['accessToken'] != null) {
        await secureStorage.saveToken(response['accessToken']);
        if (response['refreshToken'] != null) {
          await secureStorage.saveRefreshToken(response['refreshToken']);
        }
      }

      final user = UserModel.fromJson(response['user'] ?? {});
      return Right(user);
    } on UnauthorizedException {
      return const Left(UnauthorizedFailure('Biométrie non reconnue.'));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return const Left(ServerFailure('Erreur inattendue.'));
    }
  }

  @override
  Future<Either<Failure, User>> updateProfilePicture(Uint8List bytes, String mimeType) async {
    try {
      final response = await remoteDataSource.updateProfilePicture(bytes, mimeType);
      final user = UserModel.fromJson(response['user'] ?? {});
      return Right(user);
    } on UnauthorizedException {
      return const Left(UnauthorizedFailure('Non autorisé.'));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return const Left(ServerFailure('Erreur lors de la mise à jour de l\'avatar.'));
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      await secureStorage.clearAll();
      return const Right(null);
    } catch (e) {
      return const Left(CacheFailure('Impossible de se déconnecter.'));
    }
  }

  @override
  Future<Either<Failure, bool>> isAuthenticated() async {
    try {
      final token = await secureStorage.getToken();
      return Right(token != null && token.isNotEmpty);
    } catch (e) {
      return const Left(CacheFailure('Erreur de lecture du token.'));
    }
  }

  @override
  Future<Either<Failure, void>> sendFcmToken(String token) async {
    try {
      await remoteDataSource.sendFcmToken(token);
      return const Right(null);
    } on UnauthorizedException {
      return const Left(UnauthorizedFailure('Non autorisé.'));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return const Left(ServerFailure('Erreur inattendue.'));
    }
  }
}
