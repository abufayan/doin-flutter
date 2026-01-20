import 'package:doin_fx/core/locator.dart';
import 'package:doin_fx/core/services/accountServices/my_account_service.dart';
import 'package:doin_fx/views/myAccount/bloc/my_account_bloc.dart';
import 'package:doin_fx/views/myAccount/bloc/my_account_event.dart';
import 'package:doin_fx/views/myAccount/bloc/my_account_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MyAccount extends StatefulWidget {
  const MyAccount({super.key});

  @override
  State<MyAccount> createState() => _MyAccountState();
}

class _MyAccountState extends State<MyAccount> {

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    context.read<MyAccountBloc>().add(LoadMyAccount());
  }
  @override
  Widget build(BuildContext context) {

    return BlocConsumer<MyAccountBloc, AccountBlocState>(
      listenWhen: (previous, current) => current is AuthBlocActionState,
      buildWhen: (previous, current) => current is MyAccountDataLoaded,

      listener: (context, state) {},
      builder: (context, state) {
        if (state is AccountBlocLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is MyAccountDataLoaded) {
          return Scaffold(
            backgroundColor: Colors.white,
            body: SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                     _TopHeader(),
                    const SizedBox(height: 12),
                     _UserInfoCard(kycVerified: state.kycVerified),
                    const SizedBox(height: 12),
                     _BalanceCard(balance: state.walletBalance),
                    const SizedBox(height: 16),
                    const _ActionButtons(),
                    const SizedBox(height: 16),
                    _PromoBanner(
                      bannerImgage: state.bannerImage ?? '',
                    ),
                    const SizedBox(height: 16),
                    const _ReferEarnSection(),
                  ],
                ),
              ),
            ),
          );
        }

    // fallback (initial / failure)
    return const SizedBox.shrink();
  },
    );
  }
}

/* ================= TOP HEADER ================= */

class _TopHeader extends StatelessWidget {
  const _TopHeader();

  @override
  Widget build(BuildContext context) {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween);
  }
}

/* ================= USER INFO ================= */

class _UserInfoCard extends StatelessWidget {
  final bool kycVerified;
   _UserInfoCard({required this.kycVerified});

  @override
  Widget build(BuildContext context) {

    var myAccount = getIt<MyAccountService>();

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF6EE),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
           Text(
            'Account ID : ${myAccount.user?.userId}',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              children: [
                const Text(
                  'KYC : ',
                  style: TextStyle(color: Colors.white, fontSize: 12),
                ),
                Text(
                  kycVerified ? 'Verified' : 'Not Verified',
                  style: const TextStyle(
                    color: Colors.orange,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(Icons.verified, size: 14, color: Colors.orange),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/* ================= BALANCE ================= */

class _BalanceCard extends StatelessWidget {
  final String balance;
  const _BalanceCard({required this.balance});
 

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF3E8),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          const Text('Balance', style: TextStyle(color: Colors.black54)),
          const SizedBox(height: 8),
          Text(
            balance,
            style: const TextStyle(fontSize: 34, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}

/* ================= ACTION BUTTONS ================= */

class _ActionButtons extends StatelessWidget {
  const _ActionButtons();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: const [
        Expanded(child: _ActionButton(title: 'Deposit')),
        SizedBox(width: 12),
        Expanded(child: _ActionButton(title: 'Withdrawal')),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String title;
  const _ActionButton({required this.title});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 46,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.orange,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        onPressed: () {},
        child: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

/* ================= PROMO IMAGE ================= */

class _PromoBanner extends StatelessWidget {
  final String bannerImgage;
  const _PromoBanner({required this.bannerImgage});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Image.network(
        bannerImgage, 
        height: 180,
        width: double.infinity,
        fit: BoxFit.contain,

        // 🔹 SHOW LOADER WHILE IMAGE LOADS
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;

          return Container(
            height: 180,
            color: const Color(0xFFFFF3E8),
            alignment: Alignment.center,
            child: const CircularProgressIndicator(
              strokeWidth: 2,
              color: Colors.orange,
            ),
          );
        },

        // 🔹 SHOW FALLBACK IF IMAGE FAILS
        errorBuilder: (context, error, stackTrace) {
          return Container(
            height: 180,
            color: const Color(0xFFFFF3E8),
            alignment: Alignment.center,
            child: const Icon(
              Icons.image_not_supported_outlined,
              color: Colors.grey,
              size: 40,
            ),
          );
        },
      ),
    );
  }
}

/* ================= REFER & EARN ================= */

class _ReferEarnSection extends StatelessWidget {
  const _ReferEarnSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Refer & Earn',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 6),
        const Text('Earn 50% Revenue Sharing Instantly!'),
        const SizedBox(height: 14),
        const _InfoTile(title: 'Referral Bonus', value: '0 Users'),
        const _InfoTile(title: 'Referral Code', value: 'IB 202409'),
        const SizedBox(height: 12),
        Center(
          child: OutlinedButton(
            onPressed: () {},
            child: const Text('IB Panel'),
          ),
        ),
      ],
    );
  }
}

class _InfoTile extends StatelessWidget {
  final String title;
  final String value;

  const _InfoTile({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8F2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
