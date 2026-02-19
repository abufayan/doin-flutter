import 'package:auto_route/auto_route.dart';
import 'dart:async';
import 'package:doin_fx/core/services/token_storage_service.dart';
import 'package:doin_fx/views/auth/screens/reset_password_screen.dart';
import 'package:doin_fx/views/DrawerTabs/changePassword/screen/change_password_screen.dart';
import 'package:doin_fx/views/DrawerTabs/kyc/screens/kyc_upload_screen.dart';
import 'package:doin_fx/views/DrawerTabs/profile/screen/profile_screen.dart';
import 'package:doin_fx/views/DrawerTabs/support/Detail/screens/ticket_detail_screen.dart';
import 'package:doin_fx/views/DrawerTabs/support/datamodel/ticket.dart';
import 'package:doin_fx/views/DrawerTabs/support/support/screen/support_screen.dart';
import 'package:doin_fx/views/DrawerTabs/support/support/screen/ticket_create_screen.dart';
import 'package:doin_fx/views/DrawerTabs/support/support/screen/ticket_type_screen.dart';
import 'package:doin_fx/views/auth/screens/login_or_register_screen.dart';
import 'package:doin_fx/views/auth/screens/login_screen.dart';
import 'package:doin_fx/views/auth/screens/register_screen.dart';
import 'package:doin_fx/views/auth/screens/forgot_password_screen.dart';
import 'package:doin_fx/views/auth/screens/otp_screen.dart';
import 'package:doin_fx/views/auth/screens/number_verification_screen.dart';
import 'package:doin_fx/views/auth/screens/set_password_screen.dart';
import 'package:doin_fx/views/home/screen/home_screen.dart';
import 'package:doin_fx/views/orders/datamodel/trade_order.dart';
import 'package:doin_fx/views/orders/open/screen/open_orders_detail.dart';
import 'package:doin_fx/views/orders/open/screen/open_orders_list.dart';
import 'package:doin_fx/views/orders/orders_screen.dart';
import 'package:doin_fx/views/orders/pending/detail/screen/pending_orders_detail.dart';
import 'package:doin_fx/views/splash/screen/splash_screen.dart';
import 'package:doin_fx/views/trade/ui/trade_page.dart';
import 'package:doin_fx/views/withdraw%20and%20deposit/deposit/datamodel/doposit_model.dart';
import 'package:doin_fx/views/withdraw%20and%20deposit/deposit/screen/deposit_detail_screen.dart';
import 'package:doin_fx/views/withdraw%20and%20deposit/deposit/screen/payment_methods_screen.dart';
import 'package:doin_fx/views/withdraw%20and%20deposit/deposit/history/screen/deposit_history_screen.dart';
import 'package:doin_fx/views/withdraw%20and%20deposit/withdraw/datamodel/withdraw_model.dart';
import 'package:doin_fx/views/withdraw%20and%20deposit/withdraw/screen/withdraw_methods_screen.dart';
import 'package:doin_fx/views/withdraw%20and%20deposit/withdraw/screen/withdraw_screen.dart';
import 'package:doin_fx/views/withdraw%20and%20deposit/withdraw/history/screen/withdrawal_history_screen.dart';
import 'package:flutter/widgets.dart';

// Import the guard
part 'app_router.gr.dart';
part 'auth_guard.dart';

@AutoRouterConfig()
class  AppRouter extends RootStackRouter{

  @override
  List<AutoRoute> get routes => [
        AutoRoute(
          page: SplashRoute.page,
          path: '/splashScreen',
          initial: true
        ),
        AutoRoute(
          page: LoginOrRegisterRoute.page,
          path: '/login-or-register',
          // initial: true
        ),
        AutoRoute(
          page: LoginRoute.page,
          path: '/login',
        ),
        AutoRoute(
          page: RegisterRoute.page,
          path: '/register',
        ),
        AutoRoute(
          page: ForgotPasswordRoute.page,
          path: '/forgotPassword',
        ),
        AutoRoute(
          page: ResetPasswordRoute.page,
          path: '/resetPassword',
        ),
        AutoRoute(
          page: OtpRoute.page,
          path: '/otp',
        ),
        AutoRoute(
          page: SetPasswordRoute.page,
          path: '/setPasswordRoute',
        ),
        AutoRoute(
          page: WhatsAppNumberRoute.page,
          path: '/whatsappVerificationScreen',
        ),

        AutoRoute(
          page: HomeRoute.page,
          path: '/home',
          guards: [AuthGuard()],
        ),
        // AutoRoute(
        //   page: TradeRoute.page,
        //   path: '/trade',
        // ),
        AutoRoute(
          page: ProfileRoute.page,
          path: '/profile',
        ),
        AutoRoute(
          page: OrdersRoute.page,
          path: '/orders',
          guards: [AuthGuard()],
        ),
        AutoRoute(
          page: ChangePasswordRoute.page,
          path: '/changePassword',
        ),
        AutoRoute(
          page: HelpCenterRoute.page,
          path: '/helpCenter',
        ),
        AutoRoute(
          page: TicketTypeRoute.page,
          path: '/ticketType',
        ),
        AutoRoute(
          page: TicketCreateRoute.page,
          path: '/ticketCreate',
        ),
        AutoRoute(
          page: KycRoute.page,
          path: '/kycPage',
        ),
        AutoRoute(
          page: OpenTradeRoute.page,
          path: '/openTradeScreen',
        ),
        AutoRoute(
          page: OpenDetailRoute.page,
          path: '/openOrderDetailScreen',
        ),
        AutoRoute(
          page: PendingDetailRoute.page,
          path: '/pendingOrderDetailScreen',
        ),
      AutoRoute(
        page: DepositMethodsRoute.page,
        path: '/depositMethods',
      ),
      AutoRoute(
        page: DepositDetailRoute.page,
        path: '/depositDetails',
      ),
      AutoRoute(
        page: DepositHistoryRoute.page,
        path: '/depositHistory',
      ),

        AutoRoute(
          page: WithdrawMethodsRoute.page,
          path: '/withdrawMethods',
        ),
        AutoRoute(
          page: WithdrawRoute.page,
          path: '/withdrawtDetails',
        ),
        AutoRoute(
          page: WithdrawalHistoryRoute.page,
          path: '/withdrawalHistory',
        ),
        AutoRoute(
          page: TicketDetailRoute.page,
          path: '/ticketDetail',
        ),
      ];
}
