import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../design_tokens/design_tokens.dart';
import '../../../domain/entities/account.dart';
import '../../blocs/accounts/account_bloc.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/auth/auth_state.dart';
import '../../blocs/transactions/transaction_bloc.dart';
import '../../widgets/common/animated_background.dart';
import '../../widgets/common/glass_button.dart';
import '../../widgets/common/glass_container.dart';
import '../../widgets/common/glass_text_field.dart';

class PaymentsScreen extends StatefulWidget {
  const PaymentsScreen({super.key});

  @override
  State<PaymentsScreen> createState() => _PaymentsScreenState();
}

class _PaymentsScreenState extends State<PaymentsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _referenceController = TextEditingController();
  final _amountController = TextEditingController();

  Account? _selectedAccount;
  List<Account> _accounts = [];
  String? _selectedCategory;

  final List<Map<String, dynamic>> _categories = [
    {'id': 'ELEC', 'label': 'Électricité', 'icon': Icons.bolt, 'color': Colors.amber},
    {'id': 'WATER', 'label': 'Eau / SDE', 'icon': Icons.water_drop, 'color': Colors.blue},
    {'id': 'TELECOM', 'label': 'Télécom / Fibre', 'icon': Icons.wifi, 'color': Colors.purple},
    {'id': 'MOBILE', 'label': 'Mobile Money', 'icon': Icons.phone_android, 'color': Colors.teal},
  ];

  @override
  void initState() {
    super.initState();
    final authState = context.read<AuthBloc>().state;
    final user = authState is AuthAuthenticated ? authState.user : null;
    final clientId = user?.clientId;
    context.read<AccountBloc>().add(FetchAccounts(clientId: clientId));
  }

  @override
  void dispose() {
    _referenceController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  void _onAccountSelected(Account? account) {
    setState(() {
      _selectedAccount = account;
    });
  }

  void _submitPayment() {
    if (_selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez sélectionner un service de paiement'),
          backgroundColor: DesignTokens.error,
        ),
      );
      return;
    }

    if (!_formKey.currentState!.validate() || _selectedAccount == null) {
      return;
    }

    final double amount = double.tryParse(_amountController.text) ?? 0.0;

    context.read<TransactionBloc>().add(
          CreateWithdrawal(
            accountId: _selectedAccount!.id,
            montant: amount,
            devise: _selectedAccount!.devise,
          ),
        );
  }

  String _accountLabel(Account account) {
    final typeLabel = _accountTypeLabel(account.type);
    final last4 = account.id.length >= 4 ? account.id.substring(account.id.length - 4) : account.id;
    // Keep label short to avoid dropdown overflow
    return '$typeLabel ·· $last4  ${account.solde.toStringAsFixed(0)} ${account.devise}';
  }

  String _accountTypeLabel(String type) {
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

  String _formatSolde(Account account) {
    final formatted = account.solde
        .toStringAsFixed(0)
        .replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]} ');
    return '$formatted ${account.devise}';
  }

  IconData _accountIcon(String type) {
    switch (type) {
      case 'EPARGNE':
        return Icons.savings_outlined;
      case 'MOBILE_MONEY':
        return Icons.phone_android;
      default:
        return Icons.account_balance_outlined;
    }
  }

  void _showAccountPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: DesignTokens.navy800,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) {
        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text('Choisir un compte', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700)),
              const SizedBox(height: 16),
              ..._accounts.map((account) {
                final isSelected = _selectedAccount?.id == account.id;
                return GestureDetector(
                  onTap: () {
                    _onAccountSelected(account);
                    Navigator.pop(context);
                  },
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isSelected ? DesignTokens.teal500.withValues(alpha: 0.15) : DesignTokens.navy700.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected ? DesignTokens.teal300 : DesignTokens.glassBorder,
                        width: isSelected ? 1.5 : 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: DesignTokens.teal500.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(_accountIcon(account.type), color: DesignTokens.teal300, size: 22),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(_accountTypeLabel(account.type), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 15)),
                              const SizedBox(height: 3),
                              Text(_accountLabel(account), style: TextStyle(color: DesignTokens.teal300.withValues(alpha: 0.9), fontSize: 13, fontWeight: FontWeight.w600)),
                            ],
                          ),
                        ),
                        if (isSelected)
                          const Icon(Icons.check_circle_rounded, color: DesignTokens.teal300, size: 22),
                      ],
                    ),
                  ),
                );
              }),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<TransactionBloc, TransactionState>(
      listener: (context, state) {
        if (state is TransactionOperationSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: DesignTokens.success,
            ),
          );
          // Refresh accounts list
          final authState = context.read<AuthBloc>().state;
          final user = authState is AuthAuthenticated ? authState.user : null;
          context.read<AccountBloc>().add(FetchAccounts(clientId: user?.clientId));
          // Back to dashboard
          context.go('/dashboard');
        } else if (state is TransactionError) {
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
              // Back button & Title
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => context.go('/dashboard'),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Paiement de factures',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              const Text(
                'Sélectionnez un service',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),

              // Grid categories select
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 14,
                  mainAxisSpacing: 14,
                  childAspectRatio: 1.6,
                ),
                itemCount: _categories.length,
                itemBuilder: (context, index) {
                  final cat = _categories[index];
                  final isSelected = _selectedCategory == cat['id'];
                  final catColor = cat['color'] as Color;

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedCategory = cat['id'] as String;
                      });
                    },
                    child: GlassContainer(
                      padding: const EdgeInsets.all(12),
                      borderRadius: 16,
                      border: BorderSide(
                        color: isSelected ? DesignTokens.teal300 : DesignTokens.glassBorder,
                        width: isSelected ? 2.0 : 1.0,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(cat['icon'] as IconData, color: isSelected ? DesignTokens.teal300 : catColor, size: 28),
                          const SizedBox(height: 8),
                          Text(
                            cat['label'] as String,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 28),

              BlocBuilder<AccountBloc, AccountState>(
                builder: (context, accountState) {
                  if (accountState is AccountLoading) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(32.0),
                        child: CircularProgressIndicator(color: DesignTokens.teal300),
                      ),
                    );
                  }

                  if (accountState is AccountError) {
                    return Center(
                      child: Text(
                        'Erreur de chargement des comptes : ${accountState.message}',
                        style: const TextStyle(color: Colors.white70),
                      ),
                    );
                  }

                  if (accountState is AccountLoaded) {
                    _accounts = accountState.accounts;
                    if (_accounts.isEmpty) {
                      return const Center(
                        child: Text(
                          'Aucun compte disponible pour effectuer un paiement.',
                          style: TextStyle(color: Colors.white70),
                        ),
                      );
                    }

                    // Set initial selected account if null
                    _selectedAccount ??= _accounts.first;

                    return Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Glass Container Form
                          GlassContainer(
                            padding: const EdgeInsets.all(22),
                            borderRadius: 20,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Compte de débit',
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                GestureDetector(
                                  onTap: () => _showAccountPicker(context),
                                  child: Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                    decoration: BoxDecoration(
                                      color: DesignTokens.navy700.withValues(alpha: 0.6),
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(color: DesignTokens.glassBorder),
                                    ),
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 40,
                                          height: 40,
                                          decoration: BoxDecoration(
                                            color: DesignTokens.teal500.withValues(alpha: 0.15),
                                            borderRadius: BorderRadius.circular(12),
                                            border: Border.all(
                                              color: DesignTokens.teal300.withValues(alpha: 0.3),
                                            ),
                                          ),
                                          child: Icon(
                                            _accountIcon(_selectedAccount?.type ?? 'COURANT'),
                                            color: DesignTokens.teal300,
                                            size: 20,
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                _accountTypeLabel(_selectedAccount?.type ?? ''),
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w700,
                                                ),
                                              ),
                                              const SizedBox(height: 2),
                                              Text(
                                                _selectedAccount != null
                                                    ? _formatSolde(_selectedAccount!)
                                                    : '—',
                                                style: TextStyle(
                                                  color: DesignTokens.teal300.withValues(alpha: 0.9),
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const Icon(
                                          Icons.keyboard_arrow_down_rounded,
                                          color: DesignTokens.teal300,
                                          size: 22,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 20),

                                const Text(
                                  'Référence client / Numéro de facture',
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                GlassTextField(
                                  controller: _referenceController,
                                  hint: 'Ex: 10485903-B',
                                  prefixIcon: const Icon(Icons.receipt_outlined),
                                  keyboardType: TextInputType.text,
                                  validator: (value) {
                                    if (value == null || value.trim().isEmpty) {
                                      return 'Veuillez saisir la référence du paiement';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 20),

                                const Text(
                                  'Montant du paiement',
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                GlassTextField(
                                  controller: _amountController,
                                  hint: '0.00',
                                  prefixIcon: const Icon(Icons.monetization_on_outlined),
                                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                  validator: (value) {
                                    if (value == null || value.trim().isEmpty) {
                                      return 'Veuillez saisir un montant';
                                    }
                                    final val = double.tryParse(value);
                                    if (val == null || val <= 0.0) {
                                      return 'Veuillez saisir un montant valide supérieur à 0';
                                    }
                                    if (_selectedAccount != null && val > _selectedAccount!.solde) {
                                      return 'Solde insuffisant';
                                    }
                                    return null;
                                  },
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 32),

                          BlocBuilder<TransactionBloc, TransactionState>(
                            builder: (context, transactionState) {
                              final isLoading = transactionState is TransactionLoading;
                              return GlassButton(
                                text: 'Confirmer le paiement',
                                isLoading: isLoading,
                                onPressed: isLoading ? null : _submitPayment,
                              );
                            },
                          ),
                        ],
                      ),
                    );
                  }

                  return const SizedBox();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
