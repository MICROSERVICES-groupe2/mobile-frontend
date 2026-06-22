import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../design_tokens/design_tokens.dart';
import '../../blocs/accounts/account_bloc.dart';
import '../../widgets/account_card.dart';


class AccountListScreen extends StatelessWidget {
  const AccountListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DesignTokens.navy900,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Mes Comptes',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
      ),
      body: BlocBuilder<AccountBloc, AccountState>(
        builder: (context, state) {
          if (state is AccountLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is AccountLoaded) {
            if (state.accounts.isEmpty) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.account_balance,
                        size: 64,
                        color: Colors.white.withValues(alpha: 0.3)),
                    const SizedBox(height: 16),
                    Text(
                      'Aucun compte',
                      style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.6),
                          fontSize: 16),
                    ),
                  ],
                ),
              );
            }
            return RefreshIndicator(
              onRefresh: () async {
                context.read<AccountBloc>().add(const FetchAccounts());
              },
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: state.accounts.length,
                itemBuilder: (context, index) {
                  final account = state.accounts[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: AccountCard(
                      account: account,
                      onTap: () => context.push('/accounts/${account.id}', extra: account),
                    ),
                  );
                },
              ),
            );
          }
          if (state is AccountError) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(state.message,
                      style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.7))),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: () =>
                        context.read<AccountBloc>().add(const FetchAccounts()),
                    child: const Text('Réessayer'),
                  ),
                ],
              ),
            );
          }
          return const SizedBox();
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.go('/accounts/create'),
        backgroundColor: DesignTokens.teal500,
        foregroundColor: DesignTokens.navy900,
        icon: const Icon(Icons.add),
        label: const Text(
          'Créer un compte',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
