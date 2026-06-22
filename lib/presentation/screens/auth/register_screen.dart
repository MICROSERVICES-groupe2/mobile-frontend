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

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  int _currentStep = 0;

  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  void _nextStep() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _currentStep = 1;
      });
    }
  }

  void _previousStep() {
    setState(() {
      _currentStep = 0;
    });
  }

  void _onRegister() {
    if (_formKey.currentState!.validate()) {
      context.read<AuthBloc>().add(
            RegisterRequested(
              firstName: _firstNameController.text.trim(),
              lastName: _lastNameController.text.trim(),
              email: _emailController.text.trim(),
              password: _passwordController.text,
              phone: _phoneController.text.trim(),
            ),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
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
          } else if (state is AuthRegisterSuccess) {
            context.go('/register/otp', extra: {
              'email': state.email,
              'userId': state.userId,
              'otp': state.otp,
            });
          }
        },
        builder: (context, state) {
          return Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: GlassContainer(
                padding: const EdgeInsets.all(28),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const AppLogo(size: 40, textSize: 24),
                      const SizedBox(height: 24),

                      // Step indicator
                      Row(
                        children: [
                          _StepDot(isActive: _currentStep >= 0, label: 'Identity'),
                          Expanded(
                            child: Container(
                              height: 2,
                              color: _currentStep >= 1
                                  ? DesignTokens.teal300
                                  : Colors.white.withValues(alpha: 0.2),
                            ),
                          ),
                          _StepDot(isActive: _currentStep >= 1, label: 'Security'),
                        ],
                      ),
                      const SizedBox(height: 28),

                      // Title
                      Text(
                        _currentStep == 0 ? 'Create Account' : 'Secure Your Account',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),

                      // Step 1 fields
                      if (_currentStep == 0) ...[
                        GlassTextField(
                          controller: _firstNameController,
                          hint: 'First Name',
                          textInputAction: TextInputAction.next,
                          prefixIcon: const Icon(Icons.person_outline, color: DesignTokens.teal300),
                          validator: (value) => value == null || value.isEmpty ? 'Required' : null,
                        ),
                        const SizedBox(height: 14),
                        GlassTextField(
                          controller: _lastNameController,
                          hint: 'Last Name',
                          textInputAction: TextInputAction.next,
                          prefixIcon: const Icon(Icons.person_outline, color: DesignTokens.teal300),
                          validator: (value) => value == null || value.isEmpty ? 'Required' : null,
                        ),
                        const SizedBox(height: 14),
                        GlassTextField(
                          controller: _emailController,
                          hint: 'Email Address',
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          prefixIcon: const Icon(Icons.email_outlined, color: DesignTokens.teal300),
                          validator: (value) {
                            if (value == null || value.isEmpty) return 'Required';
                            if (!value.contains('@')) return 'Invalid email';
                            return null;
                          },
                        ),
                        const SizedBox(height: 14),
                        GlassTextField(
                          controller: _phoneController,
                          hint: 'Phone Number',
                          keyboardType: TextInputType.phone,
                          textInputAction: TextInputAction.done,
                          prefixIcon: const Icon(Icons.phone_outlined, color: DesignTokens.teal300),
                          validator: (value) => value == null || value.isEmpty ? 'Required' : null,
                        ),
                      ],

                      // Step 2 fields
                      if (_currentStep == 1) ...[
                        GlassTextField(
                          controller: _passwordController,
                          hint: 'Password',
                          obscureText: _obscurePassword,
                          textInputAction: TextInputAction.next,
                          prefixIcon: const Icon(Icons.lock_outline, color: DesignTokens.teal300),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                              color: Colors.white.withValues(alpha: 0.6),
                            ),
                            onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) return 'Required';
                            if (value.length < 8) return 'At least 8 characters';
                            return null;
                          },
                        ),
                        const SizedBox(height: 14),
                        GlassTextField(
                          controller: _confirmPasswordController,
                          hint: 'Confirm Password',
                          obscureText: _obscureConfirmPassword,
                          textInputAction: TextInputAction.done,
                          prefixIcon: const Icon(Icons.lock_outline, color: DesignTokens.teal300),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscureConfirmPassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                              color: Colors.white.withValues(alpha: 0.6),
                            ),
                            onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                          ),
                          validator: (value) {
                            if (value != _passwordController.text) return 'Passwords do not match';
                            return null;
                          },
                        ),
                      ],

                      const SizedBox(height: 28),

                      // Buttons
                      if (_currentStep == 0)
                        GlassButton(
                          text: 'Continue',
                          onPressed: _nextStep,
                          isLoading: state is AuthLoading,
                        )
                      else
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            GlassButton(
                              text: 'Create Account',
                              onPressed: _onRegister,
                              isLoading: state is AuthLoading,
                            ),
                            const SizedBox(height: 12),
                            GlassButton(
                              text: 'Back',
                              onPressed: _previousStep,
                              isSecondary: true,
                            ),
                          ],
                        ),

                      const SizedBox(height: 20),

                      // Login link
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Already have an account? ',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.7),
                              fontSize: 14,
                            ),
                          ),
                          GestureDetector(
                            onTap: () => context.go('/login'),
                            child: const Text(
                              'Sign in',
                              style: TextStyle(
                                color: DesignTokens.teal300,
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                                decoration: TextDecoration.underline,
                                decorationColor: DesignTokens.teal300,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _StepDot extends StatelessWidget {
  final bool isActive;
  final String label;

  const _StepDot({required this.isActive, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isActive ? DesignTokens.teal300 : Colors.white.withValues(alpha: 0.2),
            boxShadow: isActive
                ? [
                    BoxShadow(
                      color: DesignTokens.tealGlow.withValues(alpha: 0.5),
                      blurRadius: 8,
                    ),
                  ]
                : null,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: isActive ? DesignTokens.teal300 : Colors.white.withValues(alpha: 0.5),
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
