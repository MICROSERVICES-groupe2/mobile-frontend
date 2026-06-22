import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../blocs/accounts/account_bloc.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/auth/auth_state.dart';
import '../../blocs/loan/loan_bloc.dart';
import '../../blocs/loan/loan_event.dart';
import '../../blocs/loan/loan_state.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../core/theme/app_theme.dart';
import '../../../injection_container.dart' as di;

class LoansScreen extends StatefulWidget {
  const LoansScreen({super.key});

  @override
  State<LoansScreen> createState() => _LoansScreenState();
}

class _LoansScreenState extends State<LoansScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late final AccountBloc _accountBloc;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _accountBloc = di.sl<AccountBloc>();
    final authState = context.read<AuthBloc>().state;
    final clientId = authState is AuthAuthenticated ? authState.user.clientId : null;
    _accountBloc.add(FetchAccounts(clientId: clientId));
    context.read<LoanBloc>().add(LoadLoans());
  }

  @override
  void dispose() {
    _tabController.dispose();
    _accountBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BlocProvider<AccountBloc>.value(
      value: _accountBloc,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Prêts'),
          bottom: TabBar(
            controller: _tabController,
            tabs: const [
              Tab(text: 'Mes Prêts'),
              Tab(text: 'Simuler'),
            ],
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildLoansList(isDark),
            _buildSimulator(isDark),
          ],
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: 2,
          type: BottomNavigationBarType.fixed,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Accueil'),
            BottomNavigationBarItem(icon: Icon(Icons.list), label: 'Transactions'),
            BottomNavigationBarItem(icon: Icon(Icons.account_balance), label: 'Prêts'),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
          ],
          onTap: (index) {
            if (index == 0) context.go('/dashboard');
            if (index == 1) context.go('/transactions');
            if (index == 2) context.go('/loans');
            if (index == 3) context.go('/profile');
          },
        ),
      ),
    );
  }

  String? _getFirstAccountId(BuildContext context) {
    final state = context.read<AccountBloc>().state;
    if (state is AccountLoaded && state.accounts.isNotEmpty) {
      return state.accounts.first.id;
    }
    return null;
  }

  Widget _buildLoansList(bool isDark) {
    return BlocBuilder<LoanBloc, LoanState>(
      builder: (context, state) {
        if (state is LoanLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state is LoanError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 48, color: AppTheme.errorColor),
                const SizedBox(height: 16),
                Text(
                  state.message,
                  style: TextStyle(color: isDark ? AppTheme.darkTextPrimary : Colors.black87),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => context.read<LoanBloc>().add(LoadLoans()),
                  child: const Text('Réessayer'),
                ),
              ],
            ),
          );
        }
        if (state is LoansLoaded) {
          if (state.loans.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.account_balance,
                    size: 64,
                    color: isDark ? AppTheme.darkTextSecondary : Colors.grey.shade400,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Aucun prêt en cours',
                    style: TextStyle(
                      fontSize: 18,
                      color: isDark ? AppTheme.darkTextSecondary : Colors.grey,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            );
          }
          return RefreshIndicator(
            onRefresh: () async => context.read<LoanBloc>().add(LoadLoans()),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: state.loans.length,
              itemBuilder: (context, index) {
                final loan = state.loans[index];
                final progress = 1 - (loan.resteAPayer / loan.montantInitial);
                final isApproved = loan.statut == 'APPROVED';
                final badgeColor = isApproved ? AppTheme.secondaryColor : Colors.orange;

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              CurrencyFormatter.format(loan.montantInitial),
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: isDark ? AppTheme.darkTextPrimary : Colors.black87,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: badgeColor.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: badgeColor.withValues(alpha: 0.2)),
                              ),
                              child: Text(
                                loan.statut,
                                style: TextStyle(
                                  color: badgeColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: progress.clamp(0.0, 1.0),
                            backgroundColor: isDark ? AppTheme.darkBorder : Colors.grey.shade200,
                            valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.secondaryColor),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Reste: ${CurrencyFormatter.format(loan.resteAPayer)}',
                              style: TextStyle(color: isDark ? AppTheme.darkTextSecondary : Colors.grey),
                            ),
                            Text(
                              '${(progress * 100).toStringAsFixed(0)}%',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: isDark ? AppTheme.darkTextPrimary : Colors.black87,
                              ),
                            ),
                          ],
                        ),
                        const Divider(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _loanDetail(
                              'Mensualité',
                              CurrencyFormatter.format(loan.montantMensualite),
                              isDark,
                            ),
                            _loanDetail('Taux', '${loan.tauxInteret}%', isDark),
                            _loanDetail('Durée', '${loan.dureeMois} mois', isDark),
                          ],
                        ),
                        if (loan.dateProchainPaiement != null) ...[
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Icon(
                                Icons.calendar_today,
                                size: 14,
                                color: isDark ? AppTheme.darkTextSecondary : Colors.grey,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Prochain paiement : ${DateFormatter.formatShort(loan.dateProchainPaiement!)}',
                                style: TextStyle(
                                  color: isDark ? AppTheme.darkTextSecondary : Colors.grey,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _loanDetail(String label, String value, bool isDark) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            color: isDark ? AppTheme.darkTextSecondary : Colors.grey,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isDark ? AppTheme.darkTextPrimary : Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildSimulator(bool isDark) {
    final montantController = TextEditingController();
    final dureeController = TextEditingController();

    return BlocConsumer<LoanBloc, LoanState>(
      listener: (context, state) {
        if (state is LoanRequestSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Demande de prêt envoyée avec succès !'),
              backgroundColor: AppTheme.secondaryColor,
            ),
          );
          _tabController.animateTo(0);
          context.read<LoanBloc>().add(LoadLoans());
        }
        if (state is LoanError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppTheme.errorColor,
            ),
          );
        }
      },
      builder: (context, state) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Simuler un prêt',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: isDark ? AppTheme.darkTextPrimary : Colors.black87,
                ),
              ),
              const SizedBox(height: 24),
              TextField(
                controller: montantController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Montant (XAF)',
                  prefixIcon: Icon(Icons.monetization_on),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: dureeController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Durée (mois)',
                  prefixIcon: Icon(Icons.calendar_month),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: state is LoanLoading
                    ? null
                    : () {
                        final montant = double.tryParse(montantController.text);
                        final duree = int.tryParse(dureeController.text);
                        if (montant != null && duree != null) {
                          context.read<LoanBloc>().add(SimulateLoanRequested(montant: montant, dureeMois: duree));
                        }
                      },
                child: state is LoanLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Text('Simuler'),
              ),
              if (state is LoanSimulated) ...[
                const SizedBox(height: 32),
                Card(
                  color: isDark ? AppTheme.darkSurfaceLight : AppTheme.primaryColor.withValues(alpha: 0.05),
                  margin: EdgeInsets.zero,
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Résultat de la simulation',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: isDark ? AppTheme.darkTextPrimary : Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _simulationRow('Montant', CurrencyFormatter.format(state.simulation.montantInitial), isDark),
                        _simulationRow('Mensualité', CurrencyFormatter.format(state.simulation.montantMensualite), isDark),
                        _simulationRow('Taux d\'intérêt', '${state.simulation.tauxInteret}%', isDark),
                        _simulationRow('Durée', '${state.simulation.dureeMois} mois', isDark),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: () {
                            final accountId = _getFirstAccountId(context);
                            if (accountId == null || accountId.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Aucun compte disponible pour la demande.'),
                                  backgroundColor: AppTheme.errorColor,
                                ),
                              );
                              return;
                            }
                            context.read<LoanBloc>().add(RequestLoanSubmitted(
                              montant: state.simulation.montantInitial,
                              dureeMois: state.simulation.dureeMois,
                              accountId: accountId,
                            ));
                          },
                          style: ElevatedButton.styleFrom(backgroundColor: AppTheme.secondaryColor),
                          child: const Text('Faire la demande'),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _simulationRow(String label, String value, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: isDark ? AppTheme.darkTextSecondary : Colors.grey)),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isDark ? AppTheme.darkTextPrimary : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}
