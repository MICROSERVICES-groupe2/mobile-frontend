import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../design_tokens/design_tokens.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/auth/auth_event.dart';
import '../../blocs/auth/auth_state.dart';
import '../../widgets/common/animated_background.dart';
import '../../widgets/common/app_logo.dart';
import '../../widgets/common/glass_button.dart';
import '../../widgets/common/glass_container.dart';
import '../../widgets/common/glass_text_field.dart';

class RegisterOtpScreen extends StatefulWidget {
  final String userId;
  final String email;
  final String? otp;

  const RegisterOtpScreen({
    super.key,
    required this.userId,
    required this.email,
    this.otp,
  });

  @override
  State<RegisterOtpScreen> createState() => _RegisterOtpScreenState();
}

class _RegisterOtpScreenState extends State<RegisterOtpScreen> {
  final _codeController = TextEditingController();

  void _onVerify() {
    if (_codeController.text.length == 6) {
      context.read<AuthBloc>().add(VerifyOtpRequested(
        userId: widget.userId,
        code: _codeController.text,
      ));
    }
  }

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final extra = GoRouterState.of(context).extra;
    final email = extra is Map<String, dynamic> ? (extra['email'] as String? ?? '') : (extra as String? ?? '');

    return AnimatedBackground(
      child: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: DesignTokens.error,
              ),
            );
          } else if (state is AuthOtpVerified) {
            context.go('/login', extra: 'Account created successfully. Please sign in.');
          }
        },
        builder: (context, state) {
          return Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: GlassContainer(
                padding: const EdgeInsets.all(28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const AppLogo(size: 40, textSize: 24),
                    const SizedBox(height: 28),

                    const Text(
                      'Verify Your Email',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),

                    Text(
                      email.isNotEmpty
                          ? 'Enter the 6-digit code sent to\n$email'
                          : 'Enter the 6-digit code sent to your email',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.7),
                        fontSize: 14,
                        height: 1.4,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    if (widget.otp != null && widget.otp!.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                        decoration: BoxDecoration(
                          color: DesignTokens.teal300.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: DesignTokens.teal300.withValues(alpha: 0.4)),
                        ),
                        child: Column(
                          children: [
                            const Text(
                              'Code OTP de vérification (mode développement)',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 6),
                            SelectableText(
                              widget.otp!,
                              style: const TextStyle(
                                color: DesignTokens.teal300,
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 8,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    const SizedBox(height: 28),

                    GlassTextField(
                      controller: _codeController,
                      hint: '000000',
                      keyboardType: TextInputType.number,
                      maxLength: 6,
                      textAlign: TextAlign.center,
                      textInputAction: TextInputAction.done,
                      style: const TextStyle(
                        fontSize: 26,
                        letterSpacing: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      prefixIcon: const Icon(Icons.pin_outlined, color: DesignTokens.teal300),
                      onChanged: (value) {
                        if (value.length == 6) _onVerify();
                      },
                    ),
                    const SizedBox(height: 28),

                    GlassButton(
                      text: 'Verify',
                      onPressed: _onVerify,
                      isLoading: state is AuthLoading,
                    ),
                    const SizedBox(height: 16),

                    GlassButton(
                      text: 'Back to Sign Up',
                      onPressed: () => context.go('/register'),
                      isSecondary: true,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
