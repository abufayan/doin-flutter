import 'package:auto_route/auto_route.dart';
import 'dart:async';
import 'package:doin_fx/core/services/token_storage_service.dart';
import 'package:doin_fx/views/DrawerTabs/changePassword/screen/change_password_screen.dart';
import 'package:doin_fx/views/DrawerTabs/kyc/screens/kyc_upload_screen.dart';
import 'package:doin_fx/views/DrawerTabs/profile/screen/profile_screen.dart';
import 'package:doin_fx/views/DrawerTabs/support/screen/support_screen.dart';
import 'package:doin_fx/views/DrawerTabs/support/screen/ticket_create_screen.dart';
import 'package:doin_fx/views/DrawerTabs/support/screen/ticket_type_screen.dart';
import 'package:doin_fx/views/auth/screens/login_or_register_screen.dart';
import 'package:doin_fx/views/auth/screens/login_screen.dart';
import 'package:doin_fx/views/auth/screens/register_screen.dart';
import 'package:doin_fx/views/auth/screens/forgot_password_screen.dart';
import 'package:doin_fx/views/auth/screens/otp_screen.dart';
import 'package:doin_fx/views/auth/screens/number_verification_screen.dart';
import 'package:doin_fx/views/auth/screens/set_password_screen.dart';
import 'package:doin_fx/views/home/screen/home_screen.dart';
import 'package:doin_fx/views/orders/orders_screen.dart';
import 'package:doin_fx/views/trade/ui/trade_page.dart';
import 'package:flutter/widgets.dart'; 

// Import the guard
part 'app_router.gr.dart';
part 'auth_guard.dart';

@AutoRouterConfig()
class  AppRouter extends RootStackRouter{
  
  @override
  List<AutoRoute> get routes => [
        AutoRoute(
          page: LoginOrRegisterRoute.page,
          path: '/login-or-register',
          initial: true
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
          path: '/forgot-password',
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
          page: OrdersRoute.page,
          path: '/dashboardScreen',
          guards: [AuthGuard()],
        ),
        AutoRoute(
          page: HomeRoute.page,
          path: '/home',
          guards: [AuthGuard()],
        ),
        AutoRoute(
          page: TradeRoute.page,
          path: '/trade',
        ),
        AutoRoute(
          page: ProfileRoute.page,
          path: '/profile',
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
          page: KycUploadRoute.page,
          path: '/kycPage',
        ),
      ];
}
