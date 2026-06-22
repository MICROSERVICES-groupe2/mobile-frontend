import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/errors/failures.dart';
import '../../../domain/usecases/auth/login_usecase.dart';
import '../../../domain/usecases/auth/logout_usecase.dart';
import '../../../domain/usecases/auth/register_usecase.dart';
import '../../../domain/usecases/auth/update_profile_picture_usecase.dart';
import '../../../domain/usecases/auth/verify_2fa_usecase.dart';
import '../../../domain/usecases/auth/verify_registration_otp_usecase.dart';
import '../../../domain/usecases/auth/login_with_biometrics_usecase.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginUseCase loginUseCase;
  final RegisterUseCase registerUseCase;
  final VerifyRegistrationOtpUseCase verifyRegistrationOtpUseCase;
  final UpdateProfilePictureUseCase updateProfilePictureUseCase;
  final LogoutUseCase logoutUseCase;
  final Verify2FAUseCase verify2faUseCase;
  final LoginWithBiometricsUseCase loginWithBiometricsUseCase;

  // Stocke temporairement les identifiants en cas de challenge 2FA
  String? _pendingEmail;
  String? _pendingPassword;

  AuthBloc({
    required this.loginUseCase,
    required this.registerUseCase,
    required this.verifyRegistrationOtpUseCase,
    required this.updateProfilePictureUseCase,
    required this.logoutUseCase,
    required this.verify2faUseCase,
    required this.loginWithBiometricsUseCase,
  }) : super(AuthInitial()) {
    on<LoginRequested>(_onLoginRequested);
    on<RegisterRequested>(_onRegisterRequested);
    on<VerifyOtpRequested>(_onVerifyOtpRequested);
    on<UpdateProfilePictureRequested>(_onUpdateProfilePictureRequested);
    on<TwoFAVerified>(_onTwoFAVerified);
    on<LoginWithBiometricsRequested>(_onLoginWithBiometricsRequested);
    on<LogoutRequested>(_onLogoutRequested);
    on<AuthCheckRequested>(_onAuthCheckRequested);
  }

  Future<void> _onLoginRequested(LoginRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    final result = await loginUseCase.execute(
      event.email,
      event.password,
      totpCode: event.totpCode,
    );
    
    result.fold(
      (failure) {
        if (failure is TwoFARequiredFailure) {
          _pendingEmail = event.email;
          _pendingPassword = event.password;
          emit(AuthRequires2FA(failure.email));
        } else {
          emit(AuthError(failure.message));
        }
      },
      (user) => emit(AuthAuthenticated(user)),
    );
  }

  Future<void> _onRegisterRequested(RegisterRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    final result = await registerUseCase.execute(
      event.firstName,
      event.lastName,
      event.email,
      event.password,
      event.phone,
    );

    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (result) => emit(AuthRegisterSuccess(
        result.user.email,
        result.user.id,
        otp: result.otp,
      )),
    );
  }

  Future<void> _onVerifyOtpRequested(VerifyOtpRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    final result = await verifyRegistrationOtpUseCase.execute(event.userId, event.code);
    
    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (_) => emit(const AuthOtpVerified()),
    );
  }

  Future<void> _onUpdateProfilePictureRequested(
    UpdateProfilePictureRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    final result = await updateProfilePictureUseCase.execute(event.imagePath);

    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (user) => emit(AuthProfileUpdated(user)),
    );
  }

  Future<void> _onTwoFAVerified(TwoFAVerified event, Emitter<AuthState> emit) async {
    if (_pendingEmail == null || _pendingPassword == null) {
      emit(const AuthError('Session de vérification 2FA invalide.'));
      return;
    }
    emit(AuthLoading());
    final result = await loginUseCase.execute(
      _pendingEmail!,
      _pendingPassword!,
      totpCode: event.code,
    );
    
    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (user) {
        _pendingEmail = null;
        _pendingPassword = null;
        emit(AuthAuthenticated(user));
      },
    );
  }

  Future<void> _onLoginWithBiometricsRequested(LoginWithBiometricsRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    final result = await loginWithBiometricsUseCase.execute();
    
    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (user) => emit(AuthAuthenticated(user)),
    );
  }

  Future<void> _onLogoutRequested(LogoutRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    await logoutUseCase.execute();
    emit(AuthUnauthenticated());
  }

  Future<void> _onAuthCheckRequested(AuthCheckRequested event, Emitter<AuthState> emit) async {
    // Basic check, should be expanded to fetch user details if token exists
    emit(AuthUnauthenticated());
  }
}
