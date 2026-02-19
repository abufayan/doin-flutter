// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouterGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

part of 'app_router.dart';

/// generated route for
/// [ChangePasswordScreen]
class ChangePasswordRoute extends PageRouteInfo<void> {
  const ChangePasswordRoute({List<PageRouteInfo>? children})
    : super(ChangePasswordRoute.name, initialChildren: children);

  static const String name = 'ChangePasswordRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const ChangePasswordScreen();
    },
  );
}

/// generated route for
/// [DepositDetailScreen]
class DepositDetailRoute extends PageRouteInfo<DepositDetailRouteArgs> {
  DepositDetailRoute({
    Key? key,
    required DepositMethodConfig config,
    List<PageRouteInfo>? children,
  }) : super(
         DepositDetailRoute.name,
         args: DepositDetailRouteArgs(key: key, config: config),
         initialChildren: children,
       );

  static const String name = 'DepositDetailRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<DepositDetailRouteArgs>();
      return DepositDetailScreen(key: args.key, config: args.config);
    },
  );
}

class DepositDetailRouteArgs {
  const DepositDetailRouteArgs({this.key, required this.config});

  final Key? key;

  final DepositMethodConfig config;

  @override
  String toString() {
    return 'DepositDetailRouteArgs{key: $key, config: $config}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! DepositDetailRouteArgs) return false;
    return key == other.key && config == other.config;
  }

  @override
  int get hashCode => key.hashCode ^ config.hashCode;
}

/// generated route for
/// [DepositHistoryScreen]
class DepositHistoryRoute extends PageRouteInfo<void> {
  const DepositHistoryRoute({List<PageRouteInfo>? children})
    : super(DepositHistoryRoute.name, initialChildren: children);

  static const String name = 'DepositHistoryRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const DepositHistoryScreen();
    },
  );
}

/// generated route for
/// [DepositMethodsScreen]
class DepositMethodsRoute extends PageRouteInfo<void> {
  const DepositMethodsRoute({List<PageRouteInfo>? children})
    : super(DepositMethodsRoute.name, initialChildren: children);

  static const String name = 'DepositMethodsRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const DepositMethodsScreen();
    },
  );
}

/// generated route for
/// [ForgotPasswordScreen]
class ForgotPasswordRoute extends PageRouteInfo<void> {
  const ForgotPasswordRoute({List<PageRouteInfo>? children})
    : super(ForgotPasswordRoute.name, initialChildren: children);

  static const String name = 'ForgotPasswordRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const ForgotPasswordScreen();
    },
  );
}

/// generated route for
/// [HelpCenterScreen]
class HelpCenterRoute extends PageRouteInfo<void> {
  const HelpCenterRoute({List<PageRouteInfo>? children})
    : super(HelpCenterRoute.name, initialChildren: children);

  static const String name = 'HelpCenterRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const HelpCenterScreen();
    },
  );
}

/// generated route for
/// [HomePage]
class HomeRoute extends PageRouteInfo<void> {
  const HomeRoute({List<PageRouteInfo>? children})
    : super(HomeRoute.name, initialChildren: children);

  static const String name = 'HomeRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const HomePage();
    },
  );
}

/// generated route for
/// [KycScreen]
class KycRoute extends PageRouteInfo<void> {
  const KycRoute({List<PageRouteInfo>? children})
    : super(KycRoute.name, initialChildren: children);

  static const String name = 'KycRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const KycScreen();
    },
  );
}

/// generated route for
/// [LoginOrRegisterScreen]
class LoginOrRegisterRoute extends PageRouteInfo<void> {
  const LoginOrRegisterRoute({List<PageRouteInfo>? children})
    : super(LoginOrRegisterRoute.name, initialChildren: children);

  static const String name = 'LoginOrRegisterRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const LoginOrRegisterScreen();
    },
  );
}

/// generated route for
/// [LoginScreen]
class LoginRoute extends PageRouteInfo<LoginRouteArgs> {
  LoginRoute({Key? key, String? message, List<PageRouteInfo>? children})
    : super(
        LoginRoute.name,
        args: LoginRouteArgs(key: key, message: message),
        initialChildren: children,
      );

  static const String name = 'LoginRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<LoginRouteArgs>(
        orElse: () => const LoginRouteArgs(),
      );
      return LoginScreen(key: args.key, message: args.message);
    },
  );
}

class LoginRouteArgs {
  const LoginRouteArgs({this.key, this.message});

  final Key? key;

  final String? message;

  @override
  String toString() {
    return 'LoginRouteArgs{key: $key, message: $message}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! LoginRouteArgs) return false;
    return key == other.key && message == other.message;
  }

  @override
  int get hashCode => key.hashCode ^ message.hashCode;
}

/// generated route for
/// [OpenDetailScreen]
class OpenDetailRoute extends PageRouteInfo<OpenDetailRouteArgs> {
  OpenDetailRoute({
    Key? key,
    required TradeOrder order,
    List<PageRouteInfo>? children,
  }) : super(
         OpenDetailRoute.name,
         args: OpenDetailRouteArgs(key: key, order: order),
         initialChildren: children,
       );

  static const String name = 'OpenDetailRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<OpenDetailRouteArgs>();
      return WrappedRoute(
        child: OpenDetailScreen(key: args.key, order: args.order),
      );
    },
  );
}

class OpenDetailRouteArgs {
  const OpenDetailRouteArgs({this.key, required this.order});

  final Key? key;

  final TradeOrder order;

  @override
  String toString() {
    return 'OpenDetailRouteArgs{key: $key, order: $order}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! OpenDetailRouteArgs) return false;
    return key == other.key && order == other.order;
  }

  @override
  int get hashCode => key.hashCode ^ order.hashCode;
}

/// generated route for
/// [OpenTradeScreen]
class OpenTradeRoute extends PageRouteInfo<void> {
  const OpenTradeRoute({List<PageRouteInfo>? children})
    : super(OpenTradeRoute.name, initialChildren: children);

  static const String name = 'OpenTradeRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const OpenTradeScreen();
    },
  );
}

/// generated route for
/// [OrdersScreen]
class OrdersRoute extends PageRouteInfo<void> {
  const OrdersRoute({List<PageRouteInfo>? children})
    : super(OrdersRoute.name, initialChildren: children);

  static const String name = 'OrdersRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const OrdersScreen();
    },
  );
}

/// generated route for
/// [OtpPage]
class OtpRoute extends PageRouteInfo<OtpRouteArgs> {
  OtpRoute({
    Key? key,
    required String email,
    required String name,
    List<PageRouteInfo>? children,
  }) : super(
         OtpRoute.name,
         args: OtpRouteArgs(key: key, email: email, name: name),
         initialChildren: children,
       );

  static const String name = 'OtpRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<OtpRouteArgs>();
      return OtpPage(key: args.key, email: args.email, name: args.name);
    },
  );
}

class OtpRouteArgs {
  const OtpRouteArgs({this.key, required this.email, required this.name});

  final Key? key;

  final String email;

  final String name;

  @override
  String toString() {
    return 'OtpRouteArgs{key: $key, email: $email, name: $name}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! OtpRouteArgs) return false;
    return key == other.key && email == other.email && name == other.name;
  }

  @override
  int get hashCode => key.hashCode ^ email.hashCode ^ name.hashCode;
}

/// generated route for
/// [PendingDetailScreen]
class PendingDetailRoute extends PageRouteInfo<PendingDetailRouteArgs> {
  PendingDetailRoute({
    Key? key,
    required TradeOrder order,
    List<PageRouteInfo>? children,
  }) : super(
         PendingDetailRoute.name,
         args: PendingDetailRouteArgs(key: key, order: order),
         initialChildren: children,
       );

  static const String name = 'PendingDetailRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<PendingDetailRouteArgs>();
      return PendingDetailScreen(key: args.key, order: args.order);
    },
  );
}

class PendingDetailRouteArgs {
  const PendingDetailRouteArgs({this.key, required this.order});

  final Key? key;

  final TradeOrder order;

  @override
  String toString() {
    return 'PendingDetailRouteArgs{key: $key, order: $order}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! PendingDetailRouteArgs) return false;
    return key == other.key && order == other.order;
  }

  @override
  int get hashCode => key.hashCode ^ order.hashCode;
}

/// generated route for
/// [ProfileScreen]
class ProfileRoute extends PageRouteInfo<void> {
  const ProfileRoute({List<PageRouteInfo>? children})
    : super(ProfileRoute.name, initialChildren: children);

  static const String name = 'ProfileRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const ProfileScreen();
    },
  );
}

/// generated route for
/// [RegisterPage]
class RegisterRoute extends PageRouteInfo<void> {
  const RegisterRoute({List<PageRouteInfo>? children})
    : super(RegisterRoute.name, initialChildren: children);

  static const String name = 'RegisterRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const RegisterPage();
    },
  );
}

/// generated route for
/// [ResetPasswordScreen]
class ResetPasswordRoute extends PageRouteInfo<ResetPasswordRouteArgs> {
  ResetPasswordRoute({
    Key? key,
    required String email,
    List<PageRouteInfo>? children,
  }) : super(
         ResetPasswordRoute.name,
         args: ResetPasswordRouteArgs(key: key, email: email),
         initialChildren: children,
       );

  static const String name = 'ResetPasswordRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<ResetPasswordRouteArgs>();
      return ResetPasswordScreen(key: args.key, email: args.email);
    },
  );
}

class ResetPasswordRouteArgs {
  const ResetPasswordRouteArgs({this.key, required this.email});

  final Key? key;

  final String email;

  @override
  String toString() {
    return 'ResetPasswordRouteArgs{key: $key, email: $email}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! ResetPasswordRouteArgs) return false;
    return key == other.key && email == other.email;
  }

  @override
  int get hashCode => key.hashCode ^ email.hashCode;
}

/// generated route for
/// [SetPasswordScreen]
class SetPasswordRoute extends PageRouteInfo<void> {
  const SetPasswordRoute({List<PageRouteInfo>? children})
    : super(SetPasswordRoute.name, initialChildren: children);

  static const String name = 'SetPasswordRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const SetPasswordScreen();
    },
  );
}

/// generated route for
/// [SplashScreen]
class SplashRoute extends PageRouteInfo<void> {
  const SplashRoute({List<PageRouteInfo>? children})
    : super(SplashRoute.name, initialChildren: children);

  static const String name = 'SplashRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const SplashScreen();
    },
  );
}

/// generated route for
/// [TicketCreateScreen]
class TicketCreateRoute extends PageRouteInfo<TicketCreateRouteArgs> {
  TicketCreateRoute({
    Key? key,
    required String ticketType,
    List<PageRouteInfo>? children,
  }) : super(
         TicketCreateRoute.name,
         args: TicketCreateRouteArgs(key: key, ticketType: ticketType),
         initialChildren: children,
       );

  static const String name = 'TicketCreateRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<TicketCreateRouteArgs>();
      return TicketCreateScreen(key: args.key, ticketType: args.ticketType);
    },
  );
}

class TicketCreateRouteArgs {
  const TicketCreateRouteArgs({this.key, required this.ticketType});

  final Key? key;

  final String ticketType;

  @override
  String toString() {
    return 'TicketCreateRouteArgs{key: $key, ticketType: $ticketType}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! TicketCreateRouteArgs) return false;
    return key == other.key && ticketType == other.ticketType;
  }

  @override
  int get hashCode => key.hashCode ^ ticketType.hashCode;
}

/// generated route for
/// [TicketDetailScreen]
class TicketDetailRoute extends PageRouteInfo<TicketDetailRouteArgs> {
  TicketDetailRoute({
    Key? key,
    required SupportTicket ticket,
    List<PageRouteInfo>? children,
  }) : super(
         TicketDetailRoute.name,
         args: TicketDetailRouteArgs(key: key, ticket: ticket),
         initialChildren: children,
       );

  static const String name = 'TicketDetailRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<TicketDetailRouteArgs>();
      return TicketDetailScreen(key: args.key, ticket: args.ticket);
    },
  );
}

class TicketDetailRouteArgs {
  const TicketDetailRouteArgs({this.key, required this.ticket});

  final Key? key;

  final SupportTicket ticket;

  @override
  String toString() {
    return 'TicketDetailRouteArgs{key: $key, ticket: $ticket}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! TicketDetailRouteArgs) return false;
    return key == other.key && ticket == other.ticket;
  }

  @override
  int get hashCode => key.hashCode ^ ticket.hashCode;
}

/// generated route for
/// [TicketTypeScreen]
class TicketTypeRoute extends PageRouteInfo<void> {
  const TicketTypeRoute({List<PageRouteInfo>? children})
    : super(TicketTypeRoute.name, initialChildren: children);

  static const String name = 'TicketTypeRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const TicketTypeScreen();
    },
  );
}

/// generated route for
/// [TradePage]
class TradeRoute extends PageRouteInfo<TradeRouteArgs> {
  TradeRoute({Key? key, required String symbol, List<PageRouteInfo>? children})
    : super(
        TradeRoute.name,
        args: TradeRouteArgs(key: key, symbol: symbol),
        initialChildren: children,
      );

  static const String name = 'TradeRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<TradeRouteArgs>();
      return TradePage(key: args.key, symbol: args.symbol);
    },
  );
}

class TradeRouteArgs {
  const TradeRouteArgs({this.key, required this.symbol});

  final Key? key;

  final String symbol;

  @override
  String toString() {
    return 'TradeRouteArgs{key: $key, symbol: $symbol}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! TradeRouteArgs) return false;
    return key == other.key && symbol == other.symbol;
  }

  @override
  int get hashCode => key.hashCode ^ symbol.hashCode;
}

/// generated route for
/// [WhatsAppNumberScreen]
class WhatsAppNumberRoute extends PageRouteInfo<void> {
  const WhatsAppNumberRoute({List<PageRouteInfo>? children})
    : super(WhatsAppNumberRoute.name, initialChildren: children);

  static const String name = 'WhatsAppNumberRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const WhatsAppNumberScreen();
    },
  );
}

/// generated route for
/// [WithdrawMethodsScreen]
class WithdrawMethodsRoute extends PageRouteInfo<void> {
  const WithdrawMethodsRoute({List<PageRouteInfo>? children})
    : super(WithdrawMethodsRoute.name, initialChildren: children);

  static const String name = 'WithdrawMethodsRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const WithdrawMethodsScreen();
    },
  );
}

/// generated route for
/// [WithdrawScreen]
class WithdrawRoute extends PageRouteInfo<WithdrawRouteArgs> {
  WithdrawRoute({
    Key? key,
    required WithdrawMethodConfig config,
    List<PageRouteInfo>? children,
  }) : super(
         WithdrawRoute.name,
         args: WithdrawRouteArgs(key: key, config: config),
         initialChildren: children,
       );

  static const String name = 'WithdrawRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<WithdrawRouteArgs>();
      return WithdrawScreen(key: args.key, config: args.config);
    },
  );
}

class WithdrawRouteArgs {
  const WithdrawRouteArgs({this.key, required this.config});

  final Key? key;

  final WithdrawMethodConfig config;

  @override
  String toString() {
    return 'WithdrawRouteArgs{key: $key, config: $config}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! WithdrawRouteArgs) return false;
    return key == other.key && config == other.config;
  }

  @override
  int get hashCode => key.hashCode ^ config.hashCode;
}

/// generated route for
/// [WithdrawalHistoryScreen]
class WithdrawalHistoryRoute extends PageRouteInfo<void> {
  const WithdrawalHistoryRoute({List<PageRouteInfo>? children})
    : super(WithdrawalHistoryRoute.name, initialChildren: children);

  static const String name = 'WithdrawalHistoryRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const WithdrawalHistoryScreen();
    },
  );
}
