import 'package:auto_route/auto_route.dart';
import 'package:doin_fx/core/routes/app_router.dart';
import 'package:doin_fx/widgets/settings/bloc/doin_settings_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DoinSettingsDrawer extends StatelessWidget {
  const DoinSettingsDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: BlocConsumer<DoinSettingsBloc, DoinSettingsState>(
        listenWhen: (p, c) => c is DoinSettingsActionState,
        listener: (context, state) {
          if (state is LoggedOutSuccessfully) {
            context.router.replaceAll([LoginRoute()]);
          }
        },
        builder: (context, state) {
          final isLoading = state is DoinSettingsLoading;
          return Scaffold(
            backgroundColor: const Color(0xFFF9F9F9),

            appBar: AppBar(
              elevation: 0,
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
              title: const Text(
                'Settings',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),

            body: Stack(
              children: [
                SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      /// Preferences header
                      const Text(
                        'Preferences',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey,
                        ),
                      ),

                      const SizedBox(height: 12),

                      /// Settings options
                      _SettingsCard(
                        children: [
                          _SettingsTile(
                            icon: Icons.person_outline,
                            title: 'Profile',
                            onTap: () {
                              context.router.push(ProfileRoute());
                            },
                          ),
                          _SettingsTile(
                            icon: Icons.handshake_outlined,
                            title: 'Earn With Us',
                            onTap: () {},
                          ),
                          _SettingsTile(
                            icon: Icons.verified_user_outlined,
                            title: 'KYC',
                            onTap: () {
                              context.router.push(KycUploadRoute());
                            },
                          ),
                          _SettingsTile(
                            icon: Icons.lock_outline,
                            title: 'Change Password',
                            onTap: () {
                              context.router.push(ChangePasswordRoute());
                            },
                          ),
                          _SettingsTile(
                            icon: Icons.support_agent_outlined,
                            title: 'Support',
                            onTap: () {
                              context.router.push(HelpCenterRoute());
                            },
                          ),
                          _SettingsTile(
                            icon: Icons.logout,
                            title: 'Logout',
                            onTap: isLoading
                                ? null
                                : () {
                                    final bloc = context.read<DoinSettingsBloc>();

                                    showDialog(
                                      context: context,
                                      builder: (dialogContext) => AlertDialog(
                                        title: const Text('Logout'),
                                        content: const Text(
                                          'Are you sure you want to logout?',
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () => Navigator.of(
                                              dialogContext,
                                            ).pop(),
                                            child: const Text('Cancel'),
                                          ),
                                          TextButton(
                                            onPressed: () {
                                              Navigator.of(dialogContext).pop();
                                              bloc.add(LogoutEvent());
                                            },
                                            child: const Text('Logout'),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      /// Dark mode toggle
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: const [
                                Icon(Icons.dark_mode_outlined),
                                SizedBox(width: 12),
                                Text(
                                  'Dark Mode',
                                  style: TextStyle(fontSize: 16),
                                ),
                              ],
                            ),
                            Switch(value: false, onChanged: (value) {}),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      /// Account details
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF3E6),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Account Details',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Icon(Icons.chevron_right),
                              ],
                            ),
                            SizedBox(height: 12),
                            _AccountRow(label: 'Account', value: 'SPEARD'),
                            _AccountRow(label: 'SWAP', value: 'ZERO'),
                            SizedBox(height: 8),
                            _AccountRow(label: 'Commission', value: 'ZERO'),
                            _AccountRow(label: 'Leverage', value: '1:100'),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      /// Invite friends
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE9F7EF),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.greenAccent),
                        ),
                        child: Row(
                          children: const [
                            Icon(Icons.group_outlined, color: Colors.green),
                            SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Invite your friends and earn more money',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                /// Loading overlay
                if (isLoading)
                  Container(
                    color: Colors.black.withOpacity(0.3),
                    child: const Center(child: CircularProgressIndicator()),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// Reusable settings card
class _SettingsCard extends StatelessWidget {
  final List<Widget> children;

  const _SettingsCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(children: children),
    );
  }
}

/// Reusable settings tile
class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback? onTap;

  const _SettingsTile({required this.icon, required this.title, this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
      enabled: onTap != null,
    );
  }
}

/// Account info row
class _AccountRow extends StatelessWidget {
  final String label;
  final String value;

  const _AccountRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey)),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
      ],
    );
  }
}
