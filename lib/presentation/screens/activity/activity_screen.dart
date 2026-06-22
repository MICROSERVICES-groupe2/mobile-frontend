import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../design_tokens/design_tokens.dart';
import '../../../domain/entities/account.dart';
import '../../../domain/entities/transaction.dart';
import '../../blocs/accounts/account_bloc.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/auth/auth_state.dart';
import '../../blocs/transactions/transaction_bloc.dart';
import '../../widgets/common/animated_background.dart';
import '../../widgets/common/glass_container.dart';

class ActivityScreen extends StatefulWidget {
  const ActivityScreen({super.key});

  @override
  State<ActivityScreen> createState() => _ActivityScreenState();
}

class _ActivityScreenState extends State<ActivityScreen> {
  Account? _selectedAccount;
  List<Account> _accounts = [];

  @override
  void initState() {
    super.initState();
    final authState = context.read<AuthBloc>().state;
    final user = authState is AuthAuthenticated ? authState.user : null;
    final clientId = user?.clientId;
    context.read<AccountBloc>().add(FetchAccounts(clientId: clientId));
  }

  void _onAccountSelected(Account? account) {
    if (account != null) {
      setState(() {
        _selectedAccount = account;
      });
      context.read<TransactionBloc>().add(FetchTransactions(accountId: account.id));
    }
  }

  String _accountLabel(Account account) {
    final typeLabel = _accountTypeLabel(account.type);
    final last4 = account.id.length >= 4 ? account.id.substring(account.id.length - 4) : account.id;
    return '$typeLabel (**** $last4)';
  }

  String _accountTypeLabel(String type) {
    switch (type) {
      case 'COURANT':
        return 'Compte Courant';
      case 'EPARGNE':
        return 'Compte Épargne';
      case 'MOBILE_MONEY':
        return 'Mobile Money';
      default:
        return 'Compte';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DesignTokens.navy900,
      body: MultiBlocListener(
        listeners: [
          BlocListener<AccountBloc, AccountState>(
            listener: (context, state) {
              if (state is AccountLoaded && state.accounts.isNotEmpty) {
                _accounts = state.accounts;
                if (_selectedAccount == null) {
                  _selectedAccount = _accounts.first;
                  context.read<TransactionBloc>().add(FetchTransactions(accountId: _selectedAccount!.id));
                }
              }
            },
          ),
        ],
        child: Stack(
          children: [
            const AnimatedBackground(child: SizedBox.shrink()),
            SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    const Text(
                      'Activité & Analyses',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Account selector
                    BlocBuilder<AccountBloc, AccountState>(
                      builder: (context, state) {
                        if (state is AccountLoaded && _accounts.isNotEmpty) {
                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            decoration: BoxDecoration(
                              color: DesignTokens.navy700.withValues(alpha: 0.6),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: DesignTokens.glassBorder),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<Account>(
                                dropdownColor: DesignTokens.navy800,
                                value: _selectedAccount,
                                icon: const Icon(Icons.arrow_drop_down, color: DesignTokens.teal300),
                                isExpanded: true,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                                onChanged: _onAccountSelected,
                                items: _accounts.map((Account account) {
                                  return DropdownMenuItem<Account>(
                                    value: account,
                                    child: Text(_accountLabel(account)),
                                  );
                                }).toList(),
                              ),
                            ),
                          );
                        }
                        return const SizedBox();
                      },
                    ),
                    const SizedBox(height: 24),

                    // Statistics summary
                    BlocBuilder<TransactionBloc, TransactionState>(
                      builder: (context, state) {
                        double totalIncome = 0.0;
                        double totalExpenses = 0.0;
                        List<Transaction> transactions = [];

                        if (state is TransactionsLoaded) {
                          transactions = state.transactions;
                          for (var tx in transactions) {
                            if (tx.type == 'DEPOSIT' || tx.type == 'TRANSFER_IN') {
                              totalIncome += tx.montant.abs();
                            } else {
                              totalExpenses += tx.montant.abs();
                            }
                          }
                        }

                        final double netSavings = totalIncome - totalExpenses;
                        final String currency = _selectedAccount?.devise ?? '€';

                        if (state is TransactionLoading) {
                          return const Center(
                            child: Padding(
                              padding: EdgeInsets.all(48.0),
                              child: CircularProgressIndicator(color: DesignTokens.teal300),
                            ),
                          );
                        }

                        return Column(
                          children: [
                            // Income/Expenses Cards
                            Row(
                              children: [
                                Expanded(
                                  child: _StatCard(
                                    title: 'Revenus',
                                    amount: totalIncome,
                                    currency: currency,
                                    color: DesignTokens.success,
                                    icon: Icons.arrow_downward,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: _StatCard(
                                    title: 'Dépenses',
                                    amount: totalExpenses,
                                    currency: currency,
                                    color: DesignTokens.error,
                                    icon: Icons.arrow_upward,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),

                            // Mini Chart Representation
                            GlassContainer(
                              padding: const EdgeInsets.all(20),
                              borderRadius: 20,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Ratio mensuel',
                                    style: TextStyle(
                                      color: Colors.white70,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Économies nettes :',
                                        style: TextStyle(
                                          color: Colors.white.withValues(alpha: 0.7),
                                          fontSize: 13,
                                        ),
                                      ),
                                      Text(
                                        '${netSavings >= 0 ? '+' : ''}${netSavings.toStringAsFixed(2)} $currency',
                                        style: TextStyle(
                                          color: netSavings >= 0 ? DesignTokens.success : DesignTokens.error,
                                          fontWeight: FontWeight.w700,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  // Visual balance bar
                                  _ProgressBarChart(
                                    income: totalIncome,
                                    expenses: totalExpenses,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 24),

                            // List of transactions filtered
                            GlassContainer(
                              padding: const EdgeInsets.all(20),
                              borderRadius: 20,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Historique de la période',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 14),
                                  if (transactions.isEmpty)
                                    const Center(
                                      child: Padding(
                                        padding: EdgeInsets.symmetric(vertical: 24.0),
                                        child: Text(
                                          'Aucune transaction sur ce compte',
                                          style: TextStyle(color: Colors.white60, fontSize: 13),
                                        ),
                                      ),
                                    )
                                  else
                                    ListView.separated(
                                      shrinkWrap: true,
                                      physics: const NeverScrollableScrollPhysics(),
                                      itemCount: transactions.length,
                                      separatorBuilder: (_, __) => Divider(color: Colors.white.withValues(alpha: 0.08)),
                                      itemBuilder: (context, index) {
                                        final tx = transactions[index];
                                        final isIncome = tx.type == 'DEPOSIT' || tx.type == 'TRANSFER_IN';

                                        return ListTile(
                                          contentPadding: EdgeInsets.zero,
                                          leading: CircleAvatar(
                                            backgroundColor: (isIncome ? DesignTokens.success : DesignTokens.error).withValues(alpha: 0.15),
                                            child: Icon(
                                              isIncome ? Icons.arrow_downward : Icons.arrow_upward,
                                              color: isIncome ? DesignTokens.success : DesignTokens.error,
                                              size: 18,
                                            ),
                                          ),
                                          title: Text(
                                            _transactionLabel(tx.type),
                                            style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600),
                                          ),
                                          subtitle: Text(
                                            _formatDate(tx.timestamp),
                                            style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 12),
                                          ),
                                          trailing: Text(
                                            '${isIncome ? '+' : '-'} ${tx.montant.abs().toStringAsFixed(2)} ${tx.devise}',
                                            style: TextStyle(
                                              color: isIncome ? DesignTokens.success : DesignTokens.error,
                                              fontWeight: FontWeight.w700,
                                              fontSize: 14,
                                            ),
                                          ),
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
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 2, // Activité
        type: BottomNavigationBarType.fixed,
        backgroundColor: DesignTokens.navy800.withValues(alpha: 0.95),
        selectedItemColor: DesignTokens.teal300,
        unselectedItemColor: Colors.white.withValues(alpha: 0.5),
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
        unselectedLabelStyle: const TextStyle(fontSize: 11),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Accueil'),
          BottomNavigationBarItem(icon: Icon(Icons.swap_horiz), label: 'Transactions'),
          BottomNavigationBarItem(icon: Icon(Icons.show_chart), label: 'Activité'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Profil'),
        ],
        onTap: (index) {
          if (index == 0) context.go('/dashboard');
          if (index == 1) context.go('/transactions');
          if (index == 2) context.go('/activity');
          if (index == 3) context.go('/profile');
        },
      ),
    );
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
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final double amount;
  final String currency;
  final Color color;
  final IconData icon;

  const _StatCard({
    required this.title,
    required this.amount,
    required this.currency,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      padding: const EdgeInsets.all(16),
      borderRadius: 16,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 14,
                backgroundColor: color.withValues(alpha: 0.15),
                child: Icon(icon, color: color, size: 14),
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            '${amount.toStringAsFixed(2)} $currency',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProgressBarChart extends StatelessWidget {
  final double income;
  final double expenses;

  const _ProgressBarChart({
    required this.income,
    required this.expenses,
  });

  @override
  Widget build(BuildContext context) {
    final total = income + expenses;
    final double incomePercent = total > 0 ? income / total : 0.5;
    final double expensesPercent = total > 0 ? expenses / total : 0.5;

    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: SizedBox(
            height: 10,
            child: Row(
              children: [
                if (incomePercent > 0)
                  Expanded(
                    flex: (incomePercent * 100).round(),
                    child: Container(color: DesignTokens.success),
                  ),
                if (expensesPercent > 0)
                  Expanded(
                    flex: (expensesPercent * 100).round(),
                    child: Container(color: DesignTokens.error),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Revenus (${(incomePercent * 100).toStringAsFixed(0)}%)',
              style: const TextStyle(color: DesignTokens.success, fontSize: 11, fontWeight: FontWeight.w600),
            ),
            Text(
              'Dépenses (${(expensesPercent * 100).toStringAsFixed(0)}%)',
              style: const TextStyle(color: DesignTokens.error, fontSize: 11, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ],
    );
  }
}
