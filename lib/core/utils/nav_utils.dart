import 'package:auto_route/auto_route.dart';
import 'package:flutter/widgets.dart';

/// A utility to prevent rapid-fire navigation (double-taps).
class NavigationDebouncer {
  static DateTime? _lastNavTime;
  static const Duration _cooldown = Duration(milliseconds: 500);

  /// Returns true if navigation is allowed (cooldown has passed).
  static bool shouldAllow() {
    final now = DateTime.now();
    if (_lastNavTime == null || now.difference(_lastNavTime!) > _cooldown) {
      _lastNavTime = now;
      return true;
    }
    return false;
  }
}

/// Extensions for the AutoRoute package to support debounced navigation.
extension SafeNavigation on StackRouter {
  /// Pushes a route only if the debouncer allows it.
  Future<T?> safePush<T extends Object?>(
    PageRouteInfo route, {
    OnNavigationFailure? onFailure,
  }) {
    if (NavigationDebouncer.shouldAllow()) {
      return push<T>(route, onFailure: onFailure);
    }
    return Future.value(null);
  }

  /// Replaces the current route only if the debouncer allows it.
  Future<T?> safeReplace<T extends Object?>(
    PageRouteInfo route, {
    OnNavigationFailure? onFailure,
  }) {
    if (NavigationDebouncer.shouldAllow()) {
      return replace<T>(route, onFailure: onFailure);
    }
    return Future.value(null);
  }
}

/// Extensions for standard Flutter navigation to support debounced navigation.
extension SafeBuildContextNavigation on BuildContext {
  /// Provides access to the debouncer for custom logic (like popups).
  bool get canNavigate => NavigationDebouncer.shouldAllow();

  /// A helper to execute a navigation action (e.g., showDialog) with debouncing.
  void safeNavigate(VoidCallback action) {
    if (NavigationDebouncer.shouldAllow()) {
      action();
    }
  }
}
