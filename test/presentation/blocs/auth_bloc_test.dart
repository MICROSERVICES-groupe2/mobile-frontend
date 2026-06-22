import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dartz/dartz.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:bank_platform_mobile/core/errors/failures.dart';
import 'package:bank_platform_mobile/domain/entities/register_result.dart';
import 'package:bank_platform_mobile/domain/entities/user.dart';
import 'package:bank_platform_mobile/domain/usecases/auth/login_usecase.dart';
import 'package:bank_platform_mobile/domain/usecases/auth/logout_usecase.dart';
import 'package:bank_platform_mobile/domain/usecases/auth/register_usecase.dart';
import 'package:bank_platform_mobile/domain/usecases/auth/update_profile_picture_usecase.dart';
import 'package:bank_platform_mobile/domain/usecases/auth/verify_2fa_usecase.dart';
import 'package:bank_platform_mobile/domain/usecases/auth/login_with_biometrics_usecase.dart';
import 'package:bank_platform_mobile/domain/usecases/auth/verify_registration_otp_usecase.dart';
import 'package:bank_platform_mobile/presentation/blocs/auth/auth_bloc.dart';
import 'package:bank_platform_mobile/presentation/blocs/auth/auth_event.dart';
import 'package:bank_platform_mobile/presentation/blocs/auth/auth_state.dart';

class MockLoginUseCase extends Mock implements LoginUseCase {}
class MockLogoutUseCase extends Mock implements LogoutUseCase {}
class MockRegisterUseCase extends Mock implements RegisterUseCase {}
class MockUpdateProfilePictureUseCase extends Mock implements UpdateProfilePictureUseCase {}
class MockVerify2FAUseCase extends Mock implements Verify2FAUseCase {}
class MockLoginWithBiometricsUseCase extends Mock implements LoginWithBiometricsUseCase {}
class MockVerifyRegistrationOtpUseCase extends Mock implements VerifyRegistrationOtpUseCase {}

void main() {
  late AuthBloc authBloc;
  late MockLoginUseCase mockLoginUseCase;
  late MockLogoutUseCase mockLogoutUseCase;
  late MockRegisterUseCase mockRegisterUseCase;
  late MockUpdateProfilePictureUseCase mockUpdateProfilePictureUseCase;
  late MockVerify2FAUseCase mockVerify2FAUseCase;
  late MockLoginWithBiometricsUseCase mockLoginWithBiometricsUseCase;
  late MockVerifyRegistrationOtpUseCase mockVerifyRegistrationOtpUseCase;

  setUp(() {
    mockLoginUseCase = MockLoginUseCase();
    mockLogoutUseCase = MockLogoutUseCase();
    mockRegisterUseCase = MockRegisterUseCase();
    mockUpdateProfilePictureUseCase = MockUpdateProfilePictureUseCase();
    mockVerify2FAUseCase = MockVerify2FAUseCase();
    mockLoginWithBiometricsUseCase = MockLoginWithBiometricsUseCase();
    mockVerifyRegistrationOtpUseCase = MockVerifyRegistrationOtpUseCase();
    authBloc = AuthBloc(
      loginUseCase: mockLoginUseCase,
      registerUseCase: mockRegisterUseCase,
      verifyRegistrationOtpUseCase: mockVerifyRegistrationOtpUseCase,
      updateProfilePictureUseCase: mockUpdateProfilePictureUseCase,
      logoutUseCase: mockLogoutUseCase,
      verify2faUseCase: mockVerify2FAUseCase,
      loginWithBiometricsUseCase: mockLoginWithBiometricsUseCase,
    );
  });

  tearDown(() {
    authBloc.close();
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
  const tRegisterResult = RegisterResult(
    user: tUser,
    otp: '123456',
  );

  test('initial state should be AuthInitial', () {
    expect(authBloc.state, equals(AuthInitial()));
  });

  blocTest<AuthBloc, AuthState>(
    'emits [AuthLoading, AuthRegisterSuccess] when register is successful',
    build: () {
      when(() => mockRegisterUseCase.execute(
            any(),
            any(),
            any(),
            any(),
            any(),
          )).thenAnswer((_) async => const Right(tRegisterResult));
      return authBloc;
    },
    act: (bloc) => bloc.add(const RegisterRequested(
      firstName: 'John',
      lastName: 'Doe',
      email: tEmail,
      password: tPassword,
      phone: '1234567890',
    )),
    expect: () => [
      AuthLoading(),
      AuthRegisterSuccess(tEmail, tUser.id, otp: '123456'),
    ],
  );

  blocTest<AuthBloc, AuthState>(
    'emits [AuthLoading, AuthAuthenticated] when login is successful without 2FA',
    build: () {
      when(() => mockLoginUseCase.execute(tEmail, tPassword, totpCode: any(named: 'totpCode')))
          .thenAnswer((_) async => const Right(tUser));
      return authBloc;
    },
    act: (bloc) => bloc.add(const LoginRequested(email: tEmail, password: tPassword)),
    expect: () => [
      AuthLoading(),
      const AuthAuthenticated(tUser),
    ],
  );

  blocTest<AuthBloc, AuthState>(
    'emits [AuthLoading, AuthRequires2FA] when 2FA is required',
    build: () {
      when(() => mockLoginUseCase.execute(tEmail, tPassword, totpCode: any(named: 'totpCode')))
          .thenAnswer((_) async => const Left(TwoFARequiredFailure(tEmail)));
      return authBloc;
    },
    act: (bloc) => bloc.add(const LoginRequested(email: tEmail, password: tPassword)),
    expect: () => [
      AuthLoading(),
      const AuthRequires2FA(tEmail),
    ],
  );

  blocTest<AuthBloc, AuthState>(
    'emits [AuthLoading, AuthError] when login fails',
    build: () {
      when(() => mockLoginUseCase.execute(tEmail, tPassword, totpCode: any(named: 'totpCode')))
          .thenAnswer((_) async => const Left(ServerFailure('Connection error')));
      return authBloc;
    },
    act: (bloc) => bloc.add(const LoginRequested(email: tEmail, password: tPassword)),
    expect: () => [
      AuthLoading(),
      const AuthError('Connection error'),
    ],
  );
}
