import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/biometric/biometric_service.dart';
import '../../../core/storage/secure_storage.dart';
import '../../../design_tokens/design_tokens.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/auth/auth_event.dart';
import '../../blocs/auth/auth_state.dart';
import '../../widgets/common/app_logo.dart';
import '../../../injection_container.dart' as di;

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final BiometricService _biometricService = BiometricService();

  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    await Future.delayed(const Duration(seconds: 1));
    if (!mounted) return;

    final storage = di.sl<SecureStorage>();
    final token = await storage.getToken();
    final refreshToken = await storage.getRefreshToken();
    final biometricEnabled = await storage.isBiometricEnabled();

    if (!mounted) return;

    if (token != null && token.isNotEmpty && biometricEnabled && refreshToken != null) {
      final bioAvailable = await _biometricService.isAvailable();
      if (bioAvailable) {
        final authenticated = await _biometricService.authenticate();
        if (authenticated && mounted) {
          context.read<AuthBloc>().add(LoginWithBiometricsRequested());
          return;
        }
      }
    }

    if (mounted) {
      if (token != null && token.isNotEmpty) {
        context.go('/dashboard');
      } else {
        context.go('/login');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated) {
          context.go('/dashboard');
        } else if (state is AuthError) {
          context.go('/login');
        } else if (state is AuthUnauthenticated) {
          context.go('/login');
        }
      },
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: DesignTokens.backgroundGradient,
          ),
          child: const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AppLogo(size: 72, textSize: 36),
                SizedBox(height: 48),
                SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    valueColor:
                        AlwaysStoppedAnimation<Color>(DesignTokens.teal300),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
