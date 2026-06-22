import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/accounts/account_bloc.dart';

class AccountListScreen extends StatelessWidget {
  const AccountListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mes Comptes')),
      body: BlocBuilder<AccountBloc, AccountState>(
        builder: (context, state) {
          if (state is AccountLoading) return const Center(child: CircularProgressIndicator());
          if (state is AccountLoaded) {
            return ListView.builder(
              itemCount: state.accounts.length,
              itemBuilder: (context, index) {
                final account = state.accounts[index];
                return ListTile(
                  title: Text(account.type),
                  subtitle: Text('Solde: ${account.solde}'),
                );
              },
            );
          }
          if (state is AccountError) return Center(child: Text(state.message));
          return const SizedBox();
        },
      ),
    );
  }
}
