import 'package:auto_route/auto_route.dart';
import 'package:doin_fx/core/routes/app_router.dart';
import 'package:doin_fx/views/withdraw%20and%20deposit/deposit/datamodel/doposit_model.dart';
import 'package:doin_fx/views/withdraw%20and%20deposit/deposit/methods/bloc/deposit_methods_bloc.dart';
import 'package:doin_fx/views/withdraw%20and%20deposit/deposit/screen/deposit_method_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

@RoutePage()
class DepositMethodsScreen extends StatelessWidget {
  const DepositMethodsScreen({super.key});

  @override
  Widget build(BuildContext context) { 
    return BlocProvider(
      create: (_) => DepositMethodsBloc()..add(LoadDepositMethods()),
      child: const _DepositMethodsView(),
    ); 
  }
}

class _DepositMethodsView extends StatelessWidget {
  const _DepositMethodsView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Deposit Methods'),
        actions: [
          TextButton(
            onPressed: () {
              context.router.push(const DepositHistoryRoute());
            },
            child: const Text(
              'Deposit History',
              style: TextStyle(color: Colors.deepPurple, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
      body: BlocBuilder<DepositMethodsBloc, DepositMethodsState>(
        builder: (context, state) {
          if (state is DepositMethodsLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is DepositMethodsError) {
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
                    onPressed: () => context.read<DepositMethodsBloc>().add(LoadDepositMethods()),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (state is DepositMethodsEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.payment_outlined, size: 80, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'No deposit methods available',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 8),
                  Text('Please try again later', style: TextStyle(color: Colors.grey[500])),
                ],
              ),
            );
          }

          if (state is DepositMethodsLoaded) {
            return RefreshIndicator(
              onRefresh: () async {
                context.read<DepositMethodsBloc>().add(LoadDepositMethods());
                await Future.delayed(const Duration(milliseconds: 500));
              },
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: state.methods.length,
                itemBuilder: (context, index) {
                  final apiMethod = state.methods[index];
                  final config = DepositMethodConfig.fromApiData(apiMethod);
                  return PaymentMethodCard(method: config);
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
