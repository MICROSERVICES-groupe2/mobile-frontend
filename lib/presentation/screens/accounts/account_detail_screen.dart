import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../design_tokens/design_tokens.dart';
import '../../../domain/entities/account.dart';
import '../../blocs/accounts/account_bloc.dart';
import '../../blocs/transactions/transaction_bloc.dart';
import '../../widgets/common/glass_container.dart';

class AccountDetailScreen extends StatefulWidget {
  final String accountId;
  final Account? account;

  const AccountDetailScreen({
    super.key,
    required this.accountId,
    this.account,
  });

  @override
  State<AccountDetailScreen> createState() => _AccountDetailScreenState();
}

class _AccountDetailScreenState extends State<AccountDetailScreen> {
  @override
  void initState() {
    super.initState();
    context.read<TransactionBloc>().add(
      FetchTransactions(accountId: widget.accountId, limit: 20),
    );
  }

  String _maskAccountNumber(String accountId) {
    final last4 = accountId.length >= 4 ? accountId.substring(accountId.length - 4) : accountId;
    return '**** $last4';
  }

  String _accountTypeLabel(String type) {
    switch (type) {
      case 'COURANT':
        return 'Compte courant';
      case 'EPARGNE':
        return 'Compte épargne';
      case 'MOBILE_MONEY':
        return 'Mobile Money';
      default:
        return 'Compte';
    }
  }

  IconData _transactionIcon(String type) {
    switch (type) {
      case 'DEPOSIT':
        return Icons.arrow_downward;
      case 'WITHDRAW':
      case 'TRANSFER_OUT':
        return Icons.arrow_upward;
      case 'TRANSFER_IN':
        return Icons.swap_horiz;
      default:
        return Icons.payments;
    }
  }

  Color _transactionColor(String type) {
    switch (type) {
      case 'DEPOSIT':
      case 'TRANSFER_IN':
        return DesignTokens.success;
      case 'WITHDRAW':
      case 'TRANSFER_OUT':
        return DesignTokens.error;
      default:
        return DesignTokens.teal300;
    }
  }

  String _transactionLabel(String type) {
    switch (type) {
      case 'DEPOSIT':
        return 'Dépôt';
      case 'WITHDRAW':
        return 'Retrait';
      case 'TRANSFER_IN':
        return 'Virement reçu';
      case 'TRANSFER_OUT':
        return 'Virement envoyé';
      default:
        return 'Transaction';
    }
  }

  String _formatDate(DateTime date) {
    return DateFormat('dd MMM yyyy').format(date);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DesignTokens.navy900,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          widget.account != null
              ? _accountTypeLabel(widget.account!.type)
              : 'Détail du compte',
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            BlocBuilder<AccountBloc, AccountState>(
              builder: (context, state) {
                Account? account = widget.account;
                if (state is AccountLoaded) {
                  account = state.accounts.where((a) => a.id == widget.accountId).firstOrNull ?? account;
                }

                if (account == null) {
                  return const Center(child: CircularProgressIndicator());
                }

                return Column(
                  children: [
                    GlassContainer(
                      padding: const EdgeInsets.all(24),
                      borderRadius: 20,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                _accountTypeLabel(account.type),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: DesignTokens.teal300.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  account.statut,
                                  style: const TextStyle(
                                    color: DesignTokens.teal300,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          Text(
                            'Solde disponible',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.7),
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${account.devise} ${account.solde.toStringAsFixed(2)}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 36,
                              fontWeight: FontWeight.w700,
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Icon(Icons.credit_card, color: Colors.white.withValues(alpha: 0.5), size: 16),
                              const SizedBox(width: 8),
                              Text(
                                account.numero ?? _maskAccountNumber(account.id),
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.7),
                                  fontSize: 14,
                                  letterSpacing: 1,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: _ActionButton(
                            icon: Icons.add_circle_outline,
                            label: 'Dépôt',
                            onTap: () => context.go('/deposit'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _ActionButton(
                            icon: Icons.swap_horiz,
                            label: 'Transfert',
                            onTap: () => context.go('/transfer'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    GlassContainer(
                      padding: const EdgeInsets.all(20),
                      borderRadius: 20,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Transactions',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              GestureDetector(
                                onTap: () => context.go('/transactions'),
                                child: const Text(
                                  'Voir tout',
                                  style: TextStyle(
                                    color: DesignTokens.teal300,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          BlocBuilder<TransactionBloc, TransactionState>(
                            builder: (context, state) {
                              if (state is TransactionLoading) {
                                return const Center(child: CircularProgressIndicator());
                              }
                              if (state is TransactionError) {
                                return Text(
                                  'Erreur: ${state.message}',
                                  style: TextStyle(color: Colors.white.withValues(alpha: 0.7)),
                                );
                              }
                              if (state is TransactionsLoaded) {
                                final accountTxs = state.transactions
                                    .where((t) => t.accountId == widget.accountId)
                                    .toList();
                                if (accountTxs.isEmpty) {
                                  return Text(
                                    'Aucune transaction',
                                    style: TextStyle(color: Colors.white.withValues(alpha: 0.7)),
                                  );
                                }
                                return Column(
                                  children: accountTxs.map((tx) {
                                    final isPositive = tx.type == 'DEPOSIT' || tx.type == 'TRANSFER_IN';
                                    final amountText = '${isPositive ? '+' : '-'} ${tx.devise} ${tx.montant.abs().toStringAsFixed(2)}';
                                    final amountColor = isPositive ? DesignTokens.success : DesignTokens.error;

                                    return Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 8),
                                      child: GestureDetector(
                                        onTap: () => context.push('/transactions/${tx.id}', extra: tx),
                                        child: Row(
                                          children: [
                                            Container(
                                              width: 38,
                                              height: 38,
                                              decoration: BoxDecoration(
                                                color: _transactionColor(tx.type).withValues(alpha: 0.15),
                                                shape: BoxShape.circle,
                                              ),
                                              child: Icon(
                                                _transactionIcon(tx.type),
                                                color: _transactionColor(tx.type),
                                                size: 18,
                                              ),
                                            ),
                                            const SizedBox(width: 14),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    _transactionLabel(tx.type),
                                                    style: const TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 14,
                                                      fontWeight: FontWeight.w600,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 2),
                                                  Text(
                                                    _formatDate(tx.timestamp),
                                                    style: TextStyle(
                                                      color: Colors.white.withValues(alpha: 0.55),
                                                      fontSize: 12,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Text(
                                              amountText,
                                              style: TextStyle(
                                                color: amountColor,
                                                fontSize: 14,
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                );
                              }
                              return Text(
                                'Chargement...',
                                style: TextStyle(color: Colors.white.withValues(alpha: 0.7)),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: GlassContainer(
        padding: const EdgeInsets.symmetric(vertical: 16),
        borderRadius: 16,
        child: Column(
          children: [
            Icon(icon, color: DesignTokens.teal300, size: 28),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
