import 'package:auto_route/auto_route.dart';
import 'package:doin_fx/core/routes/app_router.dart';
import 'package:doin_fx/views/withdraw%20and%20deposit/withdraw/datamodel/withdraw_model.dart';
import 'package:doin_fx/views/withdraw%20and%20deposit/withdraw/methods/bloc/withdraw_methods_bloc.dart';
import 'package:doin_fx/views/withdraw%20and%20deposit/withdraw/screen/withdraw_method_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

@RoutePage()
class WithdrawMethodsScreen extends StatelessWidget {
  const WithdrawMethodsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => WithdrawMethodsBloc()..add(LoadWithdrawMethods()),
      child: const _WithdrawMethodsView(),
    );
  }
}

class _WithdrawMethodsView extends StatelessWidget {
  const _WithdrawMethodsView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Withdraw Methods', 
        style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.3,
              ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              context.router.push(const WithdrawalHistoryRoute());
            },
            child: const Text(
              'Withdrawal History',
              style: TextStyle(
                color: Colors.deepPurple,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
      body: BlocBuilder<WithdrawMethodsBloc, WithdrawMethodsState>(
        builder: (context, state) {
          if (state is WithdrawMethodsLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is WithdrawMethodsError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
                  const SizedBox(height: 16),
                  Text(
                    state.message,
                    style: TextStyle(color: Colors.grey[600]),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => context
                        .read<WithdrawMethodsBloc>()
                        .add(LoadWithdrawMethods()),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (state is WithdrawMethodsEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.payment_outlined, size: 80, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'No withdrawal methods available',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Please try again later',
                    style: TextStyle(color: Colors.grey[500]),
                  ),
                ],
              ),
            );
          }

          if (state is WithdrawMethodsLoaded) {
            return RefreshIndicator(
              onRefresh: () async {
                context.read<WithdrawMethodsBloc>().add(LoadWithdrawMethods());
                await Future.delayed(const Duration(milliseconds: 500));
              },
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: state.methods.length,
                itemBuilder: (context, index) {
                  final apiMethod = state.methods[index];
                  final config = WithdrawMethodConfig.fromApiData(apiMethod);
                  return WithdrawMethodCard(method: config);
                },
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}
