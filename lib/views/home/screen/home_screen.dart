import 'package:auto_route/auto_route.dart';
import 'package:doin_fx/core/widgets/app_dialogs.dart';
import 'package:doin_fx/core/enums.dart';
import 'package:doin_fx/core/locator.dart';
import 'package:doin_fx/core/routes/app_router.dart';
import 'package:doin_fx/core/services/accountServices/my_account_service.dart';
import 'package:doin_fx/views/auth/bloc/auth_bloc.dart';
import 'package:doin_fx/views/orders/closed/list/bloc/closed_orders_bloc.dart';
import 'package:doin_fx/views/orders/open/bloc/open_orders_bloc.dart';
import 'package:doin_fx/views/orders/orders_screen.dart';
import 'package:doin_fx/views/orders/pending/list/bloc/pending_order_bloc.dart';
import 'package:doin_fx/views/trade/bloc/trade_bloc.dart';
import 'package:doin_fx/views/trade/bloc/trade_state.dart';
import 'package:doin_fx/views/watch/FavouritePairs/bloc/favourites_bloc.dart';
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
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        // Listen for logout or session expiration
        if (state is AuthInitial || state is LoggedOut) {
          // Redirect to login
          context.router.replaceAll([const LoginOrRegisterRoute()]);
        }
      },
      child: BlocConsumer<HomeBloc, HomeState>(
        listener: (BuildContext context, HomeState state) async {
          // Show snackbar on account switch
          if (state is AccountSwitched) {
            if (state.errorMessage != null) {
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
                  content: Text(state.errorMessage!),
                  backgroundColor: Colors.red,
                  duration: const Duration(seconds: 3),
                ),
              );
            } else if (!state.isLoading) {

              // Reload all relevant BLoCs to reflect the new account environment immediately
              context.read<MyAccountBloc>().add(LoadMyAccount());

              // await Future.delayed(const Duration(milliseconds: 500));


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

            }
          }
        },
        builder: (context, state) {
          final index = state.index;

          final pages = <Widget>[
            const MyAccount(),
            const WatchListScreen(),
            const OrdersScreen(),
            TradePage(symbol: state.selectedSymbol ?? 'XAUUSD'),
            const ProfilePage(),
          ];

          return BlocListener<TradeBloc, TradeState>(
            listener: (context, state) {
              if (state is TradeBuySuccess) {
                // Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      state.order.message ?? 'Buy order placed successfully',
                    ),
                    backgroundColor: Colors.green,
                    duration: const Duration(seconds: 2),
                  ),
                );
              }

              if (state is TradeSellSuccess) {
                // Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      state.order.message ?? 'Sell order placed successfully',
                    ),
                    backgroundColor: Colors.green,
                    duration: const Duration(seconds: 2),
                  ),
                );
              }

              if (state is TradeFailure) {
                // Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.message),
                    backgroundColor: Colors.red,
                    duration: const Duration(seconds: 2),
                  ),
                );
              }
            },
            child: SafeArea(
              child: Scaffold(
                backgroundColor: Colors.white,
                drawer: Drawer(
                  child: BlocProvider(
                    create: (_) => DoinSettingsBloc(),
                    child: _DoinSettingsDrawerWithLogout(),
                  ),
                ),
                appBar: AppBar(
                  backgroundColor: Colors.white,
                  elevation: 0,
                  title: DoinFxLogo(fontSize: 100),
                  automaticallyImplyLeading: false,
                  bottom: PreferredSize(
                    preferredSize: const Size.fromHeight(2),
                    child: Container(
                      height: 4,
                      color: const Color(0xFFFFE3C6), //your yellow/orange
                    ),
                  ),
                  actions: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: GestureDetector(
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
                            horizontal: 20,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: state.accountType == AccountType.live
                                ? Colors.green.shade100
                                : Colors.blue.shade100,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            state.accountType == AccountType.live
                                ? 'Real'
                                : 'Demo',
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
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: Builder(
                        builder: (drawerContext) => IconButton(
                          icon: const Icon(Icons.settings_outlined),
                          onPressed: () {
                            Scaffold.of(drawerContext).openEndDrawer();
                          },
                        ),
                      ),
                    ),
                  ],
                ),
                endDrawer: Drawer(
                  child: BlocProvider(
                    create: (_) => DoinSettingsBloc(),
                    child: _DoinSettingsDrawerWithLogout(),
                  ),
                ),
                body: IndexedStack(index: index, children: pages),
                bottomNavigationBar: _PremiumBottomNavBar(
                  currentIndex: index,
                  onTap: (i) {
                    context.read<HomeBloc>().add(SelectTab(i));

                    // Reload when Orders tab becomes active
                    if (i == 2) {
                      context.read<OpenOrdersBloc>().add(LoadOpenOrders());
                      context.read<PendingOrderBloc>().add(LoadPendingOrders());
                      context.read<ClosedOrdersBloc>().add(LoadClosedOrders());
                    }

                    if (i == 1) {
                      context.read<FavouritesBloc>().add(LoadFavouritesEvent());
                    }

                    if (i == 0) {
                      context.read<MyAccountBloc>().add(LoadMyAccount());
                    }
                  },
                ),
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
}

void _showSwitchAccountDialog(
  BuildContext context, {
  required AccountType currentType,
  required HomeBloc homeBloc,
}) {
  final isReal = currentType == AccountType.live;

  showDialog(
    context: context,
    barrierColor: Colors.black.withOpacity(0.4),
    builder: (context) {
      return Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        elevation: 0,
        backgroundColor: Colors.white,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              /// Header
              Row(
                children: [
                  const Icon(
                    Icons.swap_horiz_rounded,
                    color: Colors.orange,
                    size: 24,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Switch Account',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              /// Real Account Option
              _buildEnhancedAccountOption(
                title: 'Real Account',
                subtitle: 'Trade with real money',
                isSelected: isReal,
                color: _getAccountColor(AccountType.live),
                onTap: () {
                  if (!isReal) {
                    Navigator.pop(context);
                    homeBloc.add(SwitchAccount(accountType: AccountType.live));
                  }
                },
              ),

              const SizedBox(height: 14),

              /// Demo Account Option
              _buildEnhancedAccountOption(
                title: 'Demo Account',
                subtitle: 'Practice without risk',
                isSelected: !isReal,
                color: _getAccountColor(AccountType.demo),
                onTap: () {
                  if (isReal) {
                    Navigator.pop(context);
                    homeBloc.add(SwitchAccount(accountType: AccountType.demo));
                  }
                },
              ),
            ],
          ),
        ),
      );
    },
  );
}

Color _getAccountColor(AccountType type) {
  switch (type) {
    case AccountType.live:
      return Colors.green;
    case AccountType.demo:
      return Colors.blue;
  }
}

Widget _buildEnhancedAccountOption({
  required String title,
  required String subtitle,
  required bool isSelected,
  required Color color,
  required VoidCallback onTap,
}) {
  return Material(
    color: Colors.transparent,
    child: InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.08) : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? color : Colors.grey.shade300,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            /// Indicator
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? color : Colors.transparent,
                border: Border.all(
                  color: isSelected ? color : Colors.grey.shade400,
                  width: 1.5,
                ),
              ),
            ),

            const SizedBox(width: 14),

            /// Texts
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                      color: isSelected ? color : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(fontSize: 13, color: Colors.black54),
                  ),
                ],
              ),
            ),

            /// Check Icon
            // if (isSelected)
            //   Icon(Icons.check_circle_rounded, color: color, size: 20),
          ],
        ),
      ),
    ),
  );
}

/* ================= PREMIUM BOTTOM NAV BAR ================= */

class _NavItemData {
  final String assetPath;
  final String label;

  const _NavItemData({required this.assetPath, required this.label});
}

const _kNavItems = [
  _NavItemData(
    assetPath: 'assets/images/bottomTabs/akar-icons_dashboard.png',
    label: 'Dashboard',
  ),
  _NavItemData(
    assetPath: 'assets/images/bottomTabs/solar_bookmark-line-duotone.png',
    label: 'Watch',
  ),
  _NavItemData(
    assetPath: 'assets/images/bottomTabs/proicons_note.png',
    label: 'Orders',
  ),
  _NavItemData(
    assetPath: 'assets/images/bottomTabs/solar_chart-outline.png',
    label: 'Trade',
  ),
  _NavItemData(
    assetPath: 'assets/images/bottomTabs/gg_profile.png',
    label: 'Profile',
  ),
];

class _PremiumBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const _PremiumBottomNavBar({required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 20,
            spreadRadius: 0,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Top accent line ──
          // Container(
          //   height: 2.5,
          //   decoration: const BoxDecoration(
          //     gradient: LinearGradient(
          //       colors: [
          //         Color(0x00FF8C00),
          //         Color(0xFFFF8C00),
          //         Color(0xFFFFA040),
          //         Color(0xFFFF8C00),
          //         Color(0x00FF8C00),
          //       ],
          //     ),
          //   ),
          // ),

          // ── Navigation items ──
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.only(top: 6, bottom: 6),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final itemWidth = constraints.maxWidth / _kNavItems.length;

                  return Stack(
                    children: [
                      // ── Animated pill indicator ──
                      // AnimatedPositioned(
                      //   duration: const Duration(milliseconds: 300),
                      //   curve: Curves.easeOutCubic,
                      //   left: itemWidth * currentIndex + (itemWidth - 48) / 2,
                      //   top: 0,
                      //   child: AnimatedContainer(
                      //     duration: const Duration(milliseconds: 300),
                      //     curve: Curves.easeOutCubic,
                      //     width: 48,
                      //     height: 48,
                      //     decoration: BoxDecoration(
                      //       color: const Color(
                      //         0xFFFF8C00,
                      //       ).withValues(alpha: 0.10),
                      //       borderRadius: BorderRadius.circular(14),
                      //     ),
                      //   ),
                      // ),

                      // ── Tab items ──
                      Row(
                        children: List.generate(_kNavItems.length, (i) {
                          final isActive = i == currentIndex;
                          final item = _kNavItems[i];

                          return Expanded(
                            child: GestureDetector(
                              behavior: HitTestBehavior.opaque,
                              onTap: () => onTap(i),
                              child: SizedBox(
                                height: 56,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    // Icon with scale animation
                                    AnimatedScale(
                                      duration: const Duration(
                                        milliseconds: 250,
                                      ),
                                      scale: isActive ? 1.15 : 1.0,
                                      child: Image.asset(
                                        item.assetPath,
                                        width: 22,
                                        height: 22,
                                        color: isActive
                                            ? const Color(0xFFFF8C00)
                                            : Colors.black87,
                                      ),
                                    ),
                                    const SizedBox(height: 4),

                                    // Label with opacity + color animation
                                    AnimatedDefaultTextStyle(
                                      duration: const Duration(
                                        milliseconds: 250,
                                      ),
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                        color: isActive
                                            ? const Color(0xFFFF8C00)
                                            : Colors.black54,
                                        letterSpacing: isActive ? 0.3 : 0,
                                        fontFamily: 'Poppins',
                                      ),
                                      child: Text(item.label),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
