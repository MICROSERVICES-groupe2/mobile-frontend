import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dartz/dartz.dart';
import 'package:bank_platform_mobile/core/errors/failures.dart';
import 'package:bank_platform_mobile/domain/entities/user.dart';
import 'package:bank_platform_mobile/domain/repositories/auth_repository.dart';
import 'package:bank_platform_mobile/domain/usecases/auth/login_usecase.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late LoginUseCase usecase;
  late MockAuthRepository mockAuthRepository;

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    usecase = LoginUseCase(mockAuthRepository);
  });

  const tEmail = 'test@example.com';
  const tPassword = 'password123';
  const tUser = User(
    id: '1',
    email: tEmail,
    role: 'CLIENT',
    nom: 'Doe',
    prenom: 'John',
    twoFaEnabled: false,
  );

  test('should get user from the repository when login is successful', () async {
    // Arrange
    when(() => mockAuthRepository.login(tEmail, tPassword, totpCode: any(named: 'totpCode')))
        .thenAnswer((_) async => const Right(tUser));

    // Act
    final result = await usecase.execute(tEmail, tPassword);

    // Assert
    expect(result, const Right(tUser));
    verify(() => mockAuthRepository.login(tEmail, tPassword, totpCode: null)).called(1);
    verifyNoMoreInteractions(mockAuthRepository);
  });

  test('should return a ServerFailure when repository login fails', () async {
    // Arrange
    const tFailure = ServerFailure('Server error');
    when(() => mockAuthRepository.login(tEmail, tPassword, totpCode: any(named: 'totpCode')))
        .thenAnswer((_) async => const Left(tFailure));

    // Act
    final result = await usecase.execute(tEmail, tPassword);

    // Assert
    expect(result, const Left(tFailure));
    verify(() => mockAuthRepository.login(tEmail, tPassword, totpCode: null)).called(1);
    verifyNoMoreInteractions(mockAuthRepository);
  });
}
