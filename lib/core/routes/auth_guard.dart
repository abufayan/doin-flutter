part of 'app_router.dart';

/// Route guard to protect authenticated routes
class AuthGuard extends AutoRouteGuard {
  @override
  FutureOr<void> onNavigation(
    NavigationResolver resolver,
    StackRouter router,
  ) async {
    final isAuthenticated = await TokenStorageService.isAuthenticated();
    
    if (isAuthenticated) {
      // User is authenticated, allow navigation
      resolver.next(true);
    } else {
      // User is not authenticated, redirect to login
      resolver.next(false);
      await router.replaceAll([const LoginOrRegisterRoute()]);
    }
  }
}
