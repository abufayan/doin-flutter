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
/// [KycUploadScreen]
class KycUploadRoute extends PageRouteInfo<void> {
  const KycUploadRoute({List<PageRouteInfo>? children})
    : super(KycUploadRoute.name, initialChildren: children);

  static const String name = 'KycUploadRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const KycUploadScreen();
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
  OtpRoute({Key? key, required String email, List<PageRouteInfo>? children})
    : super(
        OtpRoute.name,
        args: OtpRouteArgs(key: key, email: email),
        initialChildren: children,
      );

  static const String name = 'OtpRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<OtpRouteArgs>();
      return OtpPage(key: args.key, email: args.email);
    },
  );
}

class OtpRouteArgs {
  const OtpRouteArgs({this.key, required this.email});

  final Key? key;

  final String email;

  @override
  String toString() {
    return 'OtpRouteArgs{key: $key, email: $email}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! OtpRouteArgs) return false;
    return key == other.key && email == other.email;
  }

  @override
  int get hashCode => key.hashCode ^ email.hashCode;
}

/// generated route for
/// [ProfileScreen]
class ProfileRoute extends PageRouteInfo<ProfileRouteArgs> {
  ProfileRoute({Key? key, List<PageRouteInfo>? children})
    : super(
        ProfileRoute.name,
        args: ProfileRouteArgs(key: key),
        initialChildren: children,
      );

  static const String name = 'ProfileRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<ProfileRouteArgs>(
        orElse: () => const ProfileRouteArgs(),
      );
      return ProfileScreen(key: args.key);
    },
  );
}

class ProfileRouteArgs {
  const ProfileRouteArgs({this.key});

  final Key? key;

  @override
  String toString() {
    return 'ProfileRouteArgs{key: $key}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! ProfileRouteArgs) return false;
    return key == other.key;
  }

  @override
  int get hashCode => key.hashCode;
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
/// [TicketCreateScreen]
class TicketCreateRoute extends PageRouteInfo<void> {
  const TicketCreateRoute({List<PageRouteInfo>? children})
    : super(TicketCreateRoute.name, initialChildren: children);

  static const String name = 'TicketCreateRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const TicketCreateScreen();
    },
  );
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
  TradeRoute({
    Key? key,
    String? symbol,
    double? cmp,
    List<PageRouteInfo>? children,
  }) : super(
         TradeRoute.name,
         args: TradeRouteArgs(key: key, symbol: symbol, cmp: cmp),
         initialChildren: children,
       );

  static const String name = 'TradeRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<TradeRouteArgs>(
        orElse: () => const TradeRouteArgs(),
      );
      return TradePage(key: args.key, symbol: args.symbol, cmp: args.cmp);
    },
  );
}

class TradeRouteArgs {
  const TradeRouteArgs({this.key, this.symbol, this.cmp});

  final Key? key;

  final String? symbol;

  final double? cmp;

  @override
  String toString() {
    return 'TradeRouteArgs{key: $key, symbol: $symbol, cmp: $cmp}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! TradeRouteArgs) return false;
    return key == other.key && symbol == other.symbol && cmp == other.cmp;
  }

  @override
  int get hashCode => key.hashCode ^ symbol.hashCode ^ cmp.hashCode;
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
