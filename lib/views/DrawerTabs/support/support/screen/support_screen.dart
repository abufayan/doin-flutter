import 'package:doin_fx/core/widgets/app_loaders.dart';
import 'package:auto_route/auto_route.dart';
import 'package:doin_fx/core/enums.dart';
import 'package:doin_fx/core/locator.dart';
import 'package:doin_fx/core/routes/app_router.dart';
import 'package:doin_fx/core/utils/nav_utils.dart';
import 'package:doin_fx/core/services/accountServices/my_account_service.dart';
import 'package:doin_fx/views/DrawerTabs/support/Detail/bloc/support_detail_bloc.dart';
import 'package:doin_fx/views/DrawerTabs/support/Detail/screens/ticket_detail_screen.dart';
import 'package:doin_fx/views/DrawerTabs/support/datamodel/ticket.dart';
import 'package:doin_fx/views/DrawerTabs/support/helper.dart';
import 'package:doin_fx/views/DrawerTabs/support/support/bloc/support_bloc.dart';
import 'package:doin_fx/datamodel/contact_response.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

@RoutePage()
class HelpCenterScreen extends StatefulWidget {
  const HelpCenterScreen({super.key});

  @override
  State<HelpCenterScreen> createState() => _HelpCenterScreenState();
}

class _HelpCenterScreenState extends State<HelpCenterScreen> {
  @override
  void initState() {
    super.initState();
    context.read<SupportBloc>().add(LoadSupportOverview());
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SupportBloc, SupportState>(
      builder: (context, state) {
        ContactData? contactData;
        if (state is SupportLoaded) contactData = state.contactData;
        if (state is SupportEmpty) contactData = state.contactData;

        return Scaffold(
          appBar: AppBar(leading: const BackButton(), title: const Text('Help Center')),
          body: RefreshIndicator(
            onRefresh: () async {
              context.read<SupportBloc>().add(LoadSupportOverview());
              await Future.delayed(const Duration(milliseconds: 1500));
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _headerCard(),

                  const SizedBox(height: 24),
                  const Text('Contact Us', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),

                  const SizedBox(height: 12),
                  SizedBox(
                    height: 40,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1E6BFF),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                      ),
                      onPressed: () {
                        context.router.safePush(TicketTypeRoute());
                      },
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.add, size: 16),
                          SizedBox(width: 6),
                          Text('Open a ticket', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF2F2F2), // light grey background
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.shade400, width: 1),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Still Have Questions?',
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Reach out to our support team directly at:',
                          style: TextStyle(fontSize: 12, color: Colors.black87),
                        ),
                        const SizedBox(height: 12),

                        /// WhatsApp row
                        Row(
                          children: [
                            const Icon(Icons.phone, size: 14, color: Colors.black87),
                            const SizedBox(width: 8),
                            Text(
                              '${contactData?.whatsappNumber ?? '+00 1234567890'} (WhatsApp Number)',
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),

                        const SizedBox(height: 8),

                        /// Email row
                        Row(
                          children: [
                            const Icon(Icons.mail_outline, size: 14, color: Colors.black87),
                            const SizedBox(width: 8),
                            Text(
                              '${contactData?.email ?? 'contact@doinfx.com'} (E-mail)',
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),
                  const Text('My Tickets', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),

                  const SizedBox(height: 12),
                  _ticketList(state),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // ---------------- UI PARTS ----------------

  Widget _headerCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.orange.shade50, borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Hello, ${getIt<MyAccountService>().user!.username}. How can we assist you today?',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Your one-stop solution for all support needs. '
            'Find answers, troubleshoot issues, and explore the support options we offer.',
          ),
        ],
      ),
    );
  }

  Widget _ticketList(SupportState state) {
    if (state is SupportLoading) {
      return AppLoaders.loadingIndicator();
    }

    if (state is SupportEmpty) {
      return _emptyTickets();
    }

    if (state is SupportLoaded) {
      return ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: state.tickets.length,
        itemBuilder: (context, index) {
          final ticket = state.tickets[index];
          return _ticketTile(ticket);
        },
      );
    }

    if (state is SupportError) {
      return Text(state.message);
    }

    return const SizedBox();
  }

  Widget _ticketTile(SupportTicket ticket) {
    return GestureDetector(
      onTap: () => _navigateToTicketDetail(ticket),
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '#${ticket.ticketId}',
                  style: TextStyle(color: Colors.grey.shade600, fontWeight: FontWeight.w600, fontSize: 13),
                ),
                _buildStatusChip(ticket.status),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              ticket.subject,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black87),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            Text(formatCreatedAt(ticket.createdAt), style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
          ],
        ),
      ),
    );
  }

  void _navigateToTicketDetail(SupportTicket ticket) {
    context.safeNavigate(() {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (_) => SupportDetailBloc(),
            child: TicketDetailScreen(ticket: ticket),
          ),
        ),
      );
    });
  }

  Widget _buildStatusChip(TicketStatus status) {
    final color = status == TicketStatus.open
        ? Colors.green
        : status == TicketStatus.closed
        ? Colors.red
        : Colors.orange;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        status.value.toUpperCase(),
        style: TextStyle(color: color.shade700, fontWeight: FontWeight.w600, fontSize: 11),
      ),
    );
  }

  Widget _emptyTickets() {
    return Container(
      width: MediaQuery.of(context).size.width,
      padding: const EdgeInsets.symmetric(vertical: 40),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Column(
        children: [
          Icon(Icons.info_outline, size: 32),
          SizedBox(height: 12),
          Text('There is no ticket history', style: TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _card({
    required String title,
    required String subtitle,
    required String buttonText,
    required VoidCallback onPressed,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          Text(subtitle),
          const SizedBox(height: 12),
          ElevatedButton(onPressed: onPressed, child: Text(buttonText)),
        ],
      ),
    );
  }
}
