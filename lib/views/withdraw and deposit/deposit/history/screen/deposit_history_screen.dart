import 'package:auto_route/auto_route.dart';
import 'package:doin_fx/views/withdraw%20and%20deposit/deposit/datamodel/deposit_history_model.dart';
import 'package:doin_fx/views/withdraw%20and%20deposit/deposit/history/bloc/deposit_history_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

@RoutePage()
class DepositHistoryScreen extends StatelessWidget {
  const DepositHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => DepositHistoryBloc()..add(LoadDepositHistory()),
      child: const _DepositHistoryView(),
    );
  }
}

class _DepositHistoryView extends StatelessWidget {
  const _DepositHistoryView();

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
          'Deposit History',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        centerTitle: false,
      ),
      body: BlocBuilder<DepositHistoryBloc, DepositHistoryState>(
        builder: (context, state) {
          if (state is DepositHistoryLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is DepositHistoryError) {
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
                    onPressed: () => context.read<DepositHistoryBloc>().add(
                      LoadDepositHistory(),
                    ),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (state is DepositHistoryEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.receipt_long_outlined,
                    size: 80,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No deposits yet',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Your deposit history will appear here',
                    style: TextStyle(color: Colors.grey[500]),
                  ),
                ],
              ),
            );
          }

          if (state is DepositHistoryLoaded) {
            return Column(
              children: [
                const _DepositFilterBar(),
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: () async {
                      context.read<DepositHistoryBloc>().add(
                        LoadDepositHistory(showLoading: false),
                      );
                      await Future.delayed(const Duration(milliseconds: 500));
                    },
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: state.filteredDeposits.length,
                      itemBuilder: (context, index) {
                        return _DepositHistoryCard(
                          deposit: state.filteredDeposits[index],
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

class _DepositHistoryCard extends StatelessWidget {
  final DepositHistoryItem deposit;

  const _DepositHistoryCard({required this.deposit});

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
            // Top row: D.ID and Amount
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.orange[50],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.download_rounded,
                        color: Colors.orange[700],
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'D.ID: ${deposit.depositId}',
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _formatDate(deposit.depositRequestAt),
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
                  '${deposit.transferAmountUsd.toStringAsFixed(2)} USD',
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
                    _buildMethodIcon(deposit.paymentMethod),
                    const SizedBox(width: 6),
                    Text(
                      'Method: ${deposit.paymentMethodDisplay}',
                      style: TextStyle(color: Colors.grey[600], fontSize: 13),
                    ),
                  ],
                ),
                _buildStatusBadge(deposit.depositStatus),
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
            decoration: BoxDecoration(color: textColor, shape: BoxShape.circle),
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

class _DepositFilterBar extends StatefulWidget {
  const _DepositFilterBar();

  @override
  State<_DepositFilterBar> createState() => _DepositFilterBarState();
}

class _DepositFilterBarState extends State<_DepositFilterBar> {
  DateTimeRange? _selectedRange;
  final TextEditingController _searchCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<DepositHistoryBloc>();

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          /// 📅 DATE RANGE
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

                  bloc.add(FilterDepositHistory(
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
                        style: const TextStyle(fontSize: 13),
                        overflow: TextOverflow.ellipsis,
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

          /// 🔎 SEARCH
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.orange),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.search, color: Colors.orange),
                  Expanded(
                    child: TextField(
                      controller: _searchCtrl,
                      decoration: const InputDecoration(
                        hintText: 'Search',
                        border: InputBorder.none,
                      ),
                      onChanged: (value) {
                        bloc.add(FilterDepositHistory(
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
