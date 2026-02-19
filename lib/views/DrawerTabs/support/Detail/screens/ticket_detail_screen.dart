import 'package:doin_fx/core/widgets/app_loaders.dart';
import 'package:auto_route/annotations.dart';
import 'package:doin_fx/core/enums.dart';
import 'package:doin_fx/views/DrawerTabs/support/Detail/bloc/support_detail_bloc.dart';
import 'package:doin_fx/views/DrawerTabs/support/datamodel/ticket.dart';
import 'package:doin_fx/views/DrawerTabs/support/helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

@RoutePage()
class TicketDetailScreen extends StatefulWidget {
  const TicketDetailScreen({super.key, required this.ticket});

  final SupportTicket ticket;

  @override
  State<TicketDetailScreen> createState() => _TicketDetailScreenState();
}

class _TicketDetailScreenState extends State<TicketDetailScreen> {
  Future<void> loadTicket(BuildContext context) async {
    context.read<SupportDetailBloc>().add(
      GetTicketDetails(ticketId: widget.ticket.ticketId.toString()),
    );
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SupportDetailBloc>().add(
        GetTicketDetails(ticketId: widget.ticket.ticketId.toString()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SupportDetailBloc, SupportDetailState>(
      listener: (context, state) {},
      builder: (context, state) {
        if (state is SupportDetailLoading) {
          return Scaffold(
            appBar: _buildAppBar(context),
            body: AppLoaders.loadingIndicator(),
          );
        }

        if (state is TicketLoaded) {
          final ticket = state.ticket;
          final statusColor = _getStatusColor(widget.ticket.status);

          return Scaffold(
            backgroundColor: Colors.grey.shade50,
            appBar: _buildAppBar(context),
            // floatingActionButton: FloatingActionButton(
            //   elevation: 4,
            //   backgroundColor: Colors.orange,
            //   onPressed: () {
            //     // Future: Open live support chat or quick reply
            //   },
            //   child: const Icon(Icons.reply_all_rounded, color: Colors.white),
            // ),
            body: Column(
              children: [
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    children: [
                      const SizedBox(height: 20),

                      // Ticket Info Header
                      _buildTicketHeader(context, widget.ticket, statusColor),

                      const SizedBox(height: 24),

                      // Timeline / Conversation
                      _buildChatTile(
                        context: context,
                        isSupport: false,
                        message: ticket.message ?? '',
                        time: formatCreatedAt(widget.ticket.createdAt),
                        subject: widget.ticket.subject,
                      ),

                      if (ticket.repliedMessage != null &&
                          ticket.repliedMessage!.isNotEmpty)
                        _buildChatTile(
                          context: context,
                          isSupport: true,
                          message: ticket.repliedMessage!,
                          time:
                              'Support Team Reply', // Typically there'd be a reply time
                          subject: 'Re: ${widget.ticket.subject}',
                        )
                      else
                        _buildNoReplyPlaceholder(),

                      const SizedBox(height: 40),
                    ],
                  ),
                ),
                _buildBottomActions(context),
              ],
            ),
          );
        }

        return Scaffold(
          appBar: _buildAppBar(context),
          body: const Center(child: Text('Failed to load ticket details.')),
        );
      },
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      title: const Text(
        'Ticket Details',
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
      ),
      centerTitle: true,
      backgroundColor: Colors.white,
      foregroundColor: Colors.black,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
        onPressed: () => Navigator.pop(context),
      ),
    );
  }

  Widget _buildTicketHeader(
    BuildContext context,
    SupportTicket ticket,
    Color statusColor,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '#${widget.ticket.ticketId}',
                  style: const TextStyle(
                    color: Colors.orange,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),
              _buildStatusBadge(widget.ticket.status, statusColor),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            widget.ticket.subject,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(
                Icons.calendar_today_outlined,
                size: 14,
                color: Colors.grey.shade500,
              ),
              const SizedBox(width: 6),
              Text(
                formatCreatedAt(widget.ticket.createdAt),
                style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(TicketStatus status, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.2), width: 1),
      ),
      child: Text(
        status.value.toUpperCase(),
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildChatTile({
    required BuildContext context,
    required bool isSupport,
    required String message,
    required String time,
    required String subject,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: isSupport
            ? MainAxisAlignment.start
            : MainAxisAlignment.end,
        children: [
          if (isSupport) ...[
            CircleAvatar(
              radius: 18,
              backgroundColor: Colors.orange.withOpacity(0.2),
              child: const Icon(
                Icons.support_agent_rounded,
                color: Colors.orange,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment: isSupport
                  ? CrossAxisAlignment.start
                  : CrossAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isSupport ? Colors.white : Colors.orange,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(16),
                      topRight: const Radius.circular(16),
                      bottomLeft: Radius.circular(isSupport ? 4 : 16),
                      bottomRight: Radius.circular(isSupport ? 16 : 4),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.02),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (isSupport)
                        const Padding(
                          padding: EdgeInsets.only(bottom: 8),
                          child: Row(
                            children: [
                              Icon(
                                Icons.verified,
                                color: Colors.orange,
                                size: 14,
                              ),
                              SizedBox(width: 4),
                              Text(
                                'Support Response',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.orange,
                                ),
                              ),
                            ],
                          ),
                        ),
                      Text(
                        message,
                        style: TextStyle(
                          color: isSupport ? Colors.black87 : Colors.white,
                          fontSize: 14,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  time,
                  style: TextStyle(color: Colors.grey.shade500, fontSize: 11),
                ),
              ],
            ),
          ),
          if (!isSupport) ...[
            const SizedBox(width: 12),
            CircleAvatar(
              radius: 18,
              backgroundColor: Colors.blue.withOpacity(0.1),
              child: Icon(
                Icons.person_rounded,
                color: Colors.blue.shade400,
                size: 20,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildNoReplyPlaceholder() {
    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Icon(
            Icons.hourglass_empty_rounded,
            color: Colors.grey.shade400,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Awaiting support team response...',
              style: TextStyle(
                color: Colors.grey.shade500,
                fontStyle: FontStyle.italic,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomActions(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade100)),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          width: double.infinity,
          height: 54,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Back to Support',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(TicketStatus status) {
    switch (status) {
      case TicketStatus.open:
        return Colors.green;
      case TicketStatus.closed:
        return Colors.red;
    }
  }
}
