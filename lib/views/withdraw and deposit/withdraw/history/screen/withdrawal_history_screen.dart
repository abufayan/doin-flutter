import 'package:auto_route/auto_route.dart';
import 'package:doin_fx/views/withdraw%20and%20deposit/withdraw/datamodel/withdrawal_history_model.dart';
import 'package:doin_fx/views/withdraw%20and%20deposit/withdraw/history/bloc/withdrawal_history_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

@RoutePage()
class WithdrawalHistoryScreen extends StatelessWidget {
  const WithdrawalHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => WithdrawalHistoryBloc()..add(LoadWithdrawalHistory()),
      child: const _WithdrawalHistoryView(),
    );
  }
}

class _WithdrawalHistoryView extends StatelessWidget {
  const _WithdrawalHistoryView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black87),
          onPressed: () => context.router.maybePop(),
        ),
        title: const Text(
          'Withdrawal History',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        centerTitle: false,
      ),
      body: BlocBuilder<WithdrawalHistoryBloc, WithdrawalHistoryState>(
        builder: (context, state) {
          if (state is WithdrawalHistoryLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is WithdrawalHistoryError) {
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
                        .read<WithdrawalHistoryBloc>()
                        .add(LoadWithdrawalHistory()),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (state is WithdrawalHistoryEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.receipt_long_outlined,
                      size: 80, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'No withdrawals yet',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Your withdrawal history will appear here',
                    style: TextStyle(color: Colors.grey[500]),
                  ),
                ],
              ),
            );
          }

          if (state is WithdrawalHistoryLoaded) {
            return Column(
              children: [
                const _WithdrawalFilterBar(),
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: () async {
                      context.read<WithdrawalHistoryBloc>().add(
                          LoadWithdrawalHistory(showLoading: false));
                      await Future.delayed(const Duration(milliseconds: 500));
                    },
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: state.filteredWithdrawals.length,
                      itemBuilder: (context, index) {
                        return _WithdrawalHistoryCard(
                          withdrawal: state.filteredWithdrawals[index],
                        );
                      },
                    ),
                  ),
                ),
              ],
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}

class _WithdrawalHistoryCard extends StatelessWidget {
  final WithdrawalHistoryItem withdrawal;

  const _WithdrawalHistoryCard({required this.withdrawal});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top row: W.ID and Amount
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.blue[50],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.upload_rounded,
                        color: Colors.blue[700],
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'W.ID: ${withdrawal.withdrawalId}',
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _formatDate(withdrawal.withdrawalRequestAt),
                          style: TextStyle(
                            color: Colors.grey[500],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Text(
                  '${withdrawal.transferAmountUsd.toStringAsFixed(2)} USD',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Bottom row: Method and Status
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    _buildMethodIcon(withdrawal.paymentMethod),
                    const SizedBox(width: 6),
                    Text(
                      'Method: ${withdrawal.paymentMethodDisplay}',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
                _buildStatusBadge(withdrawal.withdrawalStatus),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMethodIcon(String method) {
    String asset;
    Color color;

    switch (method.toLowerCase()) {
      case 'upi':
        asset = 'assets/images/deposit/upi_transaction.png';
        color = Colors.purple;
        break;
      case 'usdt':
      case 'usdt_bep20':
      case 'usdt_trc20':
      case 'usdt_erc20':
        asset = 'assets/images/deposit/usdt.png';
        color = Colors.green;
        break;
      case 'bank':
        asset = 'assets/images/deposit/bank.png';
        color = Colors.brown;
        break;
      default:
        asset = 'assets/images/deposit/upi_transaction.png';
        color = Colors.grey;
    }

    return Image.asset('$asset', width: 24, height: 24,);
  }


  Widget _buildStatusBadge(String status) {
    Color bgColor;
    Color textColor;
    String displayStatus;

    switch (status.toLowerCase()) {
      case 'completed':
      case 'approved':
        bgColor = Colors.green[50]!;
        textColor = Colors.green[700]!;
        displayStatus = 'Completed';
        break;
      case 'rejected':
        bgColor = Colors.red[50]!;
        textColor = Colors.red[700]!;
        displayStatus = 'Rejected';
        break;
      case 'pending':
      default:
        bgColor = Colors.orange[50]!;
        textColor = Colors.orange[700]!;
        displayStatus = 'Pending';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: textColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            displayStatus,
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.w500,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return DateFormat('dd-MM-yyyy, hh:mm a').format(date);
  }
}

class _WithdrawalFilterBar extends StatefulWidget {
  const _WithdrawalFilterBar();

  @override
  State<_WithdrawalFilterBar> createState() =>
      _WithdrawalFilterBarState();
}

class _WithdrawalFilterBarState
    extends State<_WithdrawalFilterBar> {
  DateTimeRange? _selectedRange;
  final TextEditingController _searchCtrl =
  TextEditingController();

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<WithdrawalHistoryBloc>();

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          /// DATE RANGE
          Expanded(
            flex: 2,
            child: GestureDetector(
              onTap: () async {
                final range = await showDateRangePicker(
                  context: context,
                  firstDate: DateTime(2020),
                  lastDate: DateTime.now(),
                );

                if (range != null) {
                  setState(() => _selectedRange = range);

                  bloc.add(FilterWithdrawalHistory(
                    searchQuery: _searchCtrl.text,
                    dateRange: range,
                  ));
                }
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.orange),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        _selectedRange == null
                            ? 'Select Date'
                            : '${DateFormat('dd-MM-yyyy').format(_selectedRange!.start)}'
                            '  to  '
                            '${DateFormat('dd-MM-yyyy').format(_selectedRange!.end)}',
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 13),
                      ),
                    ),
                    const Icon(Icons.calendar_today,
                        size: 18, color: Colors.orange),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(width: 12),

          /// SEARCH
          Expanded(
            child: Container(
              padding:
              const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.orange),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.search,
                      color: Colors.orange),
                  Expanded(
                    child: TextField(
                      controller: _searchCtrl,
                      decoration: const InputDecoration(
                        hintText: 'Search',
                        border: InputBorder.none,
                      ),
                      onChanged: (value) {
                        bloc.add(FilterWithdrawalHistory(
                          searchQuery: value,
                          dateRange: _selectedRange,
                        ));
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
