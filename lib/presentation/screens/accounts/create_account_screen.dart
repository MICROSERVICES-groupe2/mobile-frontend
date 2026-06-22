import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../design_tokens/design_tokens.dart';
import '../../blocs/accounts/account_bloc.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/auth/auth_state.dart';
import '../../widgets/common/animated_background.dart';
import '../../widgets/common/glass_button.dart';
import '../../widgets/common/glass_container.dart';
import '../../widgets/common/glass_text_field.dart';

class CreateAccountScreen extends StatefulWidget {
  const CreateAccountScreen({super.key});

  @override
  State<CreateAccountScreen> createState() => _CreateAccountScreenState();
}

class _CreateAccountScreenState extends State<CreateAccountScreen> {
  final _formKey = GlobalKey<FormState>();
  String _selectedType = 'COURANT';
  String _selectedDevise = 'XAF';
  final _soldeController = TextEditingController();

  static const _types = ['COURANT', 'EPARGNE', 'MOBILE_MONEY'];
  static const _devises = ['XAF', 'EUR', 'USD'];
  static const _typeDescriptions = [
    'Compte courant quotidien',
    'Compte épargne rémunéré',
    'Compte Mobile Money',
  ];

  @override
  void dispose() {
    _soldeController.dispose();
    super.dispose();
  }

  String _getClientId() {
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      return authState.user.clientId ?? authState.user.id;
    }
    return '';
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final clientId = _getClientId();
    if (clientId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Utilisateur non connecté')),
      );
      return;
    }

    final solde = double.tryParse(_soldeController.text) ?? 0;

    context.read<AccountBloc>().add(CreateAccount(
          clientId: clientId,
          type: _selectedType,
          solde: solde,
          devise: _selectedDevise,
        ));
  }

  String _typeLabel(String type) {
    switch (type) {
      case 'COURANT':
        return 'Compte Principal';
      case 'EPARGNE':
        return 'Compte Épargne';
      case 'MOBILE_MONEY':
        return 'Mobile Money';
      default:
        return 'Compte';
    }
  }

  String _deviseLabel(String devise) {
    switch (devise) {
      case 'XAF':
        return 'Franc CFA';
      case 'EUR':
        return 'Euro';
      case 'USD':
        return 'Dollar US';
      default:
        return '';
    }
  }

  IconData _typeIcon(String type) {
    switch (type) {
      case 'EPARGNE':
        return Icons.savings_outlined;
      case 'MOBILE_MONEY':
        return Icons.phone_android;
      default:
        return Icons.account_balance_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AccountBloc, AccountState>(
      listener: (context, state) {
        if (state is AccountOperationSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: DesignTokens.success,
            ),
          );
          context.go('/dashboard');
        }
        if (state is AccountOperationError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: DesignTokens.error,
            ),
          );
        }
      },
      child: AnimatedBackground(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => context.go('/dashboard'),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Nouveau compte',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              Form(
                key: _formKey,
                child: GlassContainer(
                  padding: const EdgeInsets.all(22),
                  borderRadius: 20,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Type de compte',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 10),
                      ...List.generate(_types.length, (i) {
                        final isSelected = _selectedType == _types[i];
                        return GestureDetector(
                          onTap: () =>
                              setState(() => _selectedType = _types[i]),
                          child: Container(
                            width: double.infinity,
                            margin: const EdgeInsets.only(bottom: 10),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 14),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? DesignTokens.teal500.withValues(alpha: 0.15)
                                  : DesignTokens.navy700.withValues(alpha: 0.6),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: isSelected
                                    ? DesignTokens.teal300
                                    : DesignTokens.glassBorder,
                                width: isSelected ? 1.5 : 1,
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? DesignTokens.teal500
                                            .withValues(alpha: 0.15)
                                        : DesignTokens.navy600,
                                    borderRadius: BorderRadius.circular(12),
                                    border: isSelected
                                        ? Border.all(
                                            color: DesignTokens.teal300
                                                .withValues(alpha: 0.3),
                                          )
                                        : null,
                                  ),
                                  child: Icon(
                                    _typeIcon(_types[i]),
                                    color: isSelected
                                        ? DesignTokens.teal300
                                        : Colors.white.withValues(alpha: 0.6),
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        _typeLabel(_types[i]),
                                        style: TextStyle(
                                          color: isSelected
                                              ? Colors.white
                                              : Colors.white
                                                  .withValues(alpha: 0.8),
                                          fontSize: 14,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        _typeDescriptions[i],
                                        style: TextStyle(
                                          color: isSelected
                                              ? DesignTokens.teal300
                                                  .withValues(alpha: 0.9)
                                              : Colors.white
                                                  .withValues(alpha: 0.5),
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                if (isSelected)
                                  const Icon(
                                    Icons.check_circle_rounded,
                                    color: DesignTokens.teal300,
                                    size: 22,
                                  ),
                              ],
                            ),
                          ),
                        );
                      }),
                      const SizedBox(height: 24),

                      const Text(
                        'Devise',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: _devises.map((devise) {
                          final isSelected = _selectedDevise == devise;
                          return Expanded(
                            child: GestureDetector(
                              onTap: () =>
                                  setState(() => _selectedDevise = devise),
                              child: Container(
                                margin: EdgeInsets.only(
                                  right: devise == _devises.last ? 0 : 8,
                                ),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 14),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? DesignTokens.teal500
                                          .withValues(alpha: 0.15)
                                      : DesignTokens.navy700
                                          .withValues(alpha: 0.6),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: isSelected
                                        ? DesignTokens.teal300
                                        : DesignTokens.glassBorder,
                                    width: isSelected ? 1.5 : 1,
                                  ),
                                ),
                                child: Column(
                                  children: [
                                    Text(
                                      devise,
                                      style: TextStyle(
                                        color: isSelected
                                            ? DesignTokens.teal300
                                            : Colors.white
                                                .withValues(alpha: 0.6),
                                        fontSize: 18,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      _deviseLabel(devise),
                                      style: TextStyle(
                                        color: isSelected
                                            ? DesignTokens.teal300
                                                .withValues(alpha: 0.8)
                                            : Colors.white
                                                .withValues(alpha: 0.4),
                                        fontSize: 10,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 24),

                      const Text(
                        'Solde initial',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      GlassTextField(
                        controller: _soldeController,
                        hint: '0.00',
                        prefixIcon: const Icon(Icons.monetization_on_outlined),
                        keyboardType:
                            const TextInputType.numberWithOptions(decimal: true),
                        validator: (value) {
                          if (value == null || value.isEmpty) return null;
                          final solde = double.tryParse(value);
                          if (solde == null) return 'Montant invalide';
                          if (solde < 0) {
                            return 'Le solde ne peut pas être négatif';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),

              BlocBuilder<AccountBloc, AccountState>(
                builder: (context, state) {
                  final isLoading = state is AccountOperationLoading;
                  return GlassButton(
                    text: 'Créer le compte',
                    isLoading: isLoading,
                    onPressed: isLoading ? null : _submit,
                  );
                },
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
