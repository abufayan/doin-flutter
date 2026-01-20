import 'package:auto_route/auto_route.dart';
import 'package:doin_fx/core/enums.dart';
import 'package:doin_fx/core/locator.dart';
import 'package:doin_fx/core/routes/app_router.dart';
import 'package:doin_fx/core/services/accountServices/my_account_service.dart';
import 'package:doin_fx/views/auth/bloc/auth_bloc.dart';
import 'package:doin_fx/views/orders/orders_screen.dart';
import 'package:doin_fx/widgets/account_type_widget.dart';
import 'package:doin_fx/widgets/doin_title_widget.dart';
import 'package:doin_fx/widgets/settings/bloc/doin_settings_bloc.dart';
import 'package:doin_fx/widgets/settings/screens/doin_settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:doin_fx/views/home/bloc/home_bloc.dart';
import 'package:doin_fx/views/home/bloc/home_event.dart';
import 'package:doin_fx/views/home/bloc/home_state.dart';
import 'package:doin_fx/views/myAccount/bloc/my_account_bloc.dart';
import 'package:doin_fx/views/myAccount/bloc/my_account_event.dart';
import 'package:doin_fx/views/myAccount/screen/my_account_screen.dart';
import 'package:doin_fx/views/watch/watch_list_screen.dart';
import 'package:doin_fx/views/trade/ui/trade_page.dart';
import 'package:doin_fx/views/profile/profile_page.dart';

@RoutePage()
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(create: (_) => HomeBloc(), child: _HomeView());
  }
}

class _HomeView extends StatefulWidget {
  _HomeView();

  var myAccount = getIt<MyAccountService>();

  @override
  State<_HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<_HomeView> {
  @override
  Widget build(BuildContext context) {
    final pages = <Widget>[
      const MyAccount(),
      const WatchListScreen(),
      const OrdersScreen(),
      const TradePage(),
      const ProfilePage(),
    ];

    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        // Listen for logout or session expiration
        if (state is AuthInitial || state is LoggedOut) {
          // Redirect to login
          context.router.replaceAll([const LoginOrRegisterRoute()]);
        }
      },
      child: BlocConsumer<HomeBloc, HomeState>(
        listener: (BuildContext context, HomeState state) {
          // Show snackbar on account switch
          if (state is AccountSwitched) {
            if (state.errorMessage != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(behavior: SnackBarBehavior.floating,
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  content: Text(state.errorMessage!),
                  backgroundColor: Colors.red,
                  duration: const Duration(seconds: 3),
                ),
              );
            } else if (!state.isLoading) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  behavior: SnackBarBehavior.floating,
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  backgroundColor: Colors.green.shade600,
                  duration: const Duration(seconds: 2),
                  content: Row(
                    children: [
                      const Icon(Icons.swap_horiz_rounded, color: Colors.white),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Switched to ${state.accountType == AccountType.live ? 'Real' : 'Demo'} account',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
              // Reload MyAccount data to reflect the new account balance
              context.read<MyAccountBloc>().add(LoadMyAccount());
            }
          }
        },
        builder: (context, state) {
          final index = state.index;

          return SafeArea(
            child: Scaffold(
              endDrawer: Drawer(
                child: BlocProvider(
                  create: (_) => DoinSettingsBloc(),
                  child: _DoinSettingsDrawerWithLogout(),
                ),
              ),
              appBar: AppBar(
                title: DoinFxLogo(),
                automaticallyImplyLeading: false,
                actions: [
                  GestureDetector(
                    onTap: () {
                      final bloc = context.read<HomeBloc>();
                      _showSwitchAccountDialog(
                        context,
                        currentType: state.accountType,
                        homeBloc: bloc,
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: state.accountType == AccountType.live
                            ? Colors.green.shade100
                            : Colors.blue.shade100,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        state.accountType == AccountType.live ? 'Real' : 'Demo',
                        style: TextStyle(
                          color: state.accountType == AccountType.live
                              ? Colors.green.shade700
                              : Colors.blue.shade700,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                  Builder(
                    builder: (context) {
                      return IconButton(
                        icon: const Icon(Icons.settings),
                        onPressed: () {
                          Scaffold.of(context).openEndDrawer();
                        },
                      );
                    },
                  ),
                ],
              ),
              body: pages[index],
              bottomNavigationBar: BottomNavigationBar(
                type: BottomNavigationBarType.fixed,
                backgroundColor: const Color(0xFFEFEFEF),
                elevation: 0,
                currentIndex: index,
                onTap: (i) => context.read<HomeBloc>().add(SelectTab(i)),
                selectedItemColor: const Color(0xFFFF8C00),
                unselectedItemColor: Colors.black54,
                selectedLabelStyle: const TextStyle(
                  fontWeight: FontWeight.w600,
                ),
                unselectedLabelStyle: const TextStyle(
                  fontWeight: FontWeight.w500,
                ),
                items: const [
                  BottomNavigationBarItem(
                    icon: Icon(Icons.account_box),
                    activeIcon: Icon(Icons.account_box),
                    label: 'My Account',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.receipt_long_outlined),
                    activeIcon: Icon(Icons.receipt_long),
                    label: 'Watch',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.dashboard_outlined),
                    activeIcon: Icon(Icons.dashboard),
                    label: 'Orders',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.swap_horiz),
                    label: 'Trade',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.person_outline),
                    activeIcon: Icon(Icons.person),
                    label: 'Profile',
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Custom Settings Drawer with Logout functionality
class _DoinSettingsDrawerWithLogout extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: BlocProvider(
                create: (_) => DoinSettingsBloc(),
                child: const DoinSettingsDrawer(),
              ),
            ),
            // Logout button at bottom
            // Padding(
            //   padding: const EdgeInsets.all(16),
            //   child: SizedBox(
            //     width: double.infinity,
            //     child: ElevatedButton.icon(
            //       onPressed: () {
            //         _showLogoutConfirmation(context);
            //       },
            //       icon: const Icon(Icons.logout),
            //       label: const Text('Logout'),
            //       style: ElevatedButton.styleFrom(
            //         backgroundColor: Colors.red,
            //         foregroundColor: Colors.white,
            //         padding: const EdgeInsets.symmetric(vertical: 12),
            //       ),
            //     ),
            //   ),
            // ),
          ],
        ),
      ),
    );
  }

  void _showLogoutConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // Trigger logout
              context.read<AuthBloc>().add(LogoutRequested());
            },
            child: const Text('Logout', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

void _showSwitchAccountDialog(
  BuildContext context, {
  required AccountType currentType,
  required HomeBloc homeBloc,
}) {
  final isReal = currentType == AccountType.live;

  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Switch Account',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AccountOption(
              title: 'Real',
              subtitle: 'Trade with real money',
              isSelected: isReal,
              color: Colors.green,
              onTap: () {
                if (!isReal) {
                  Navigator.pop(context);
                  homeBloc.add(SwitchAccount(accountType: AccountType.live));
                }
              },
            ),
            const SizedBox(height: 12),
            AccountOption(
              title: 'Demo',
              subtitle: 'Practice without risk',
              isSelected: !isReal,
              color: Colors.orange,
              onTap: () {
                if (isReal) {
                  Navigator.pop(context);
                  homeBloc.add(SwitchAccount(accountType: AccountType.demo));
                }
              },
            ),
          ],
        ),
      );
    },
  );
}
