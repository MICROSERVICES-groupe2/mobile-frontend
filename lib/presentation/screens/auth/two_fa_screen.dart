import '../../../design_tokens/design_tokens.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/auth/auth_event.dart';
import '../../blocs/auth/auth_state.dart';
import '../../widgets/common/app_button.dart';
import '../../widgets/common/app_text_field.dart';
import '../../../core/theme/app_theme.dart';

class TwoFAScreen extends StatefulWidget {
  const TwoFAScreen({super.key});

  @override
  State<TwoFAScreen> createState() => _TwoFAScreenState();
}

class _TwoFAScreenState extends State<TwoFAScreen> {
  final _codeController = TextEditingController();

  void _onVerify() {
    if (_codeController.text.length == 6) {
      context.read<AuthBloc>().add(TwoFAVerified(code: _codeController.text));
    }
  }

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Vérification 2FA'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            context.go('/login');
          },
        ),
      ),
      body: Container(
        decoration: isDark
            ? const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    DesignTokens.backgroundDark,
                    AppTheme.darkBackground,
                  ],
                ),
              )
            : null,
        child: SafeArea(
          child: BlocConsumer<AuthBloc, AuthState>(
            listener: (context, state) {
              if (state is AuthError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.message),
                    backgroundColor: AppTheme.errorColor,
                  ),
                );
              } else if (state is AuthAuthenticated) {
                context.go('/dashboard');
              }
            },
            builder: (context, state) {
              return Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(28.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // ── Icon ──
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isDark
                              ? AppTheme.secondaryColor.withValues(alpha: 0.1)
                              : AppTheme.primaryColor.withValues(alpha: 0.1),
                          border: Border.all(
                            color: isDark
                                ? AppTheme.secondaryColor.withValues(alpha: 0.3)
                                : AppTheme.primaryColor.withValues(alpha: 0.3),
                            width: 2,
                          ),
                        ),
                        child: Icon(
                          Icons.security,
                          size: 40,
                          color: isDark ? AppTheme.secondaryColor : AppTheme.primaryColor,
                        ),
                      ),
                      const SizedBox(height: 32),

                      // ── Header ──
                      Text(
                        'Double Facteur',
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                          color: isDark ? AppTheme.darkTextPrimary : Colors.black87,
                          letterSpacing: 0.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Entrez le code de sécurité à 6 chiffres généré par votre application d\'authentification (Google Authenticator, Duo, etc.).',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          height: 1.4,
                          color: isDark ? AppTheme.darkTextSecondary : Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 36),

                      // ── Code Input ──
                      AppTextField(
                        controller: _codeController,
                        label: 'Code de sécurité',
                        hint: '000000',
                        keyboardType: TextInputType.number,
                        maxLength: 6,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 26,
                          letterSpacing: 12,
                          fontWeight: FontWeight.bold,
                          color: isDark ? AppTheme.darkTextPrimary : Colors.black87,
                        ),
                        prefixIcon: const Icon(Icons.pin_outlined),
                      ),
                      const SizedBox(height: 24),

                      // ── Action Button ──
                      AppButton(
                        text: 'Vérifier le code',
                        onPressed: _onVerify,
                        isLoading: state is AuthLoading,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
