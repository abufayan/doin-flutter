# Doin FX - AI Coding Instructions

## Project Overview
**Doin FX** is a Flutter forex trading app combining real-time order management, demo/real account switching, and secure authentication. Multi-platform target (Android/iOS/Web/Desktop).

**Core Stack**: Flutter 3.10+, Bloc 9.2, auto_route 11, Dio 5.9, GetIt 7.6, Socket.IO 3.1, flutter_secure_storage 9.2

---

## Critical Architecture Patterns

### 1. **State Management: BLoC Pattern (Manual Instantiation)**
- **Location**: `lib/views/{feature}/bloc/` with `*_bloc.dart`, `*_event.dart`, `*_state.dart`
- **Key Difference**: BLoCs are manually created in `main.dart` (lines 47-56) in `initState()`, NOT via GetIt locator
- **15 Active BLoCs**: AuthBloc, HomeBloc, TradeBloc, OpenOrdersBloc, PendingOrderBloc, MyAccountBloc, AllPairsBloc, FavouritesBloc, KycBloc, ClosedOrdersBloc, SupportBloc, ChangePasswordBloc, ProfileBloc, DetailPendingBloc
- **Sealed Classes**: Use `sealed class EventName {}` → `final class ConcreteEvent extends EventName {}` for type safety
- **Event Handlers**: Register in constructor with `on<EventType>((event, emit) => _handler())`

### 2. **HTTP + Authentication: Dio + AuthInterceptor**
- **Config**: [setup.dart](lib/setup.dart) creates global `Dio` instance with base URL `http://10.0.2.2:5000/` (Android emulator)
- **Auto-Token Injection**: [interceptor.dart](lib/core/interceptor.dart) automatically adds `Authorization: Bearer {token}` to all requests
- **Session Handling**: On 401 → clears tokens via `TokenStorageService.clearToken()` → redirects to login
- **Logging**: AppLogger captures all requests/responses (see patterns in `onRequest()`, `onResponse()`, `onError()`)
- **Critical**: AuthBloc uses `http.post()` directly for login (before token exists), not Dio

### 3. **Routing: Auto-Route with Auth Guard**
- **Setup**: [app_router.dart](lib/core/routes/app_router.dart) uses `@AutoRouterConfig()` code generation
- **Protected Routes**: `/home`, `/dashboardScreen`, `/ordersScreen` guarded by inline `auth_guard.dart` (part of app_router.dart)
- **Regenerate Command**: `flutter pub run build_runner build --delete-conflicting-outputs` (REQUIRED after router changes)
- **Generated File**: Routes available in auto-generated `app_router.gr.dart` (read-only, do not edit)

### 4. **Global Service: MyAccountService (Singleton)**
- **Purpose**: Holds real-time user state (current user, wallet, usedMargin, accountType)
- **Files**: Abstract in [my_account_service.dart](lib/core/services/accountServices/my_account_service.dart), impl in `my_account_service_implementation.dart`
- **Initialization**: `getIt<MyAccountService>().initialize()` called in `main()` before `runApp()`
- **Access Pattern**: `getIt<MyAccountService>().user`, `.wallet`, `.accountType`, `.usedMargin`
- **Lifecycle**: Persists across screen navigation, survives hot reload

### 5. **Dependency Injection: GetIt (Minimal)**
- **File**: [locator.dart](lib/core/locator.dart) - only registers `MyAccountService` lazy singleton
- **Future Extension**: Add new services via `getIt.registerLazySingleton<ServiceType>(() => ServiceImpl())`
- **Activation**: `setupLocator()` called in `main()` line 21

### 6. **Data Models: Immutable with Serialization**
- **Convention**: `@immutable` + factory `fromJson()`, `toJson()`, `toJsonString()`, `fromJsonString()`
- **Key Models**: [UserModel](lib/datamodel/user_model.dart) (userId, username, email, accountType), [order models](lib/datamodel/order_model.dart)
- **Account Type Handling**: Field mapped from `account_type` or `accountType` JSON, defaults to 'LIVE'

---

## Core Data Flows

### **Authentication Flow (AuthBloc)**
1. **Register**: Email → verify OTP (backend) → set password → WhatsApp number → auto-login
2. **Login**: POST `/api/auth/login` → response contains token → store via `TokenStorageService.saveToken()` → redirect to home
3. **Session Restore**: App startup checks `TokenStorageService.getToken()` → if valid, user stays logged in
4. **Logout**: `LogoutRequested` event → clear token → reset user model → redirect to splash
5. **Token Lifecycle**: Stored in platform-specific encrypted storage (iOS Keychain, Android Keystore via `flutter_secure_storage`)

### **Account Switching (Real ↔ Demo)**
- **Current State**: Stored in `MyAccountService.accountType` (enum: `LIVE` or `DEMO`)
- **UI Indicator**: Account type badge displayed in [home_screen.dart](lib/views/home/screen/home_screen.dart)
- **Switch APIs**: 
  - To Demo: `POST /api/demoaccount/demo/account-type/{userId}` 
  - To Real: `POST /api/wallet/{userId}`
- **Event**: `AccountSwitched` in HomeBloc triggers wallet refresh
- **Persistence**: Included in UserModel, survives logout

### **Trading Order Management**
- **Place Order**: TradeBloc emits Loading → API call → emit Success/Error
- **View Open Orders**: OpenOrdersBloc fetches from backend, calculates P&L via [pnl_calculator.dart](lib/core/utils/pnl_calculator.dart)
- **Close Position**: Updates order status → Home/OpenOrders BLoCs rebuild
- **Symbol Icons**: [tradingview_symbol_mapper.dart](lib/core/utils/tradingview_symbol_mapper.dart) maps trading pairs to asset icons
- **Real-time Updates**: Socket.IO listener (planned integration, currently HTTP polling)

---

## Developer Workflows

### **Route Generation (CRITICAL)**
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```
- **When**: After any change to `app_router.dart` (adding routes, modifying guards)
- **Effect**: Regenerates `app_router.gr.dart` with new route definitions
- **Gotcha**: Routes won't be found until regenerated; hot reload won't pick up route changes

### **Run App**
```bash
flutter run -v  # Verbose output for debugging
flutter run -d <device-id>  # Specific device
```

### **Build APK**
```bash
flutter build apk --debug  # Debug APK
flutter build apk --release  # Production APK
```

### **Static Analysis**
```bash
flutter analyze  # Check for warnings/errors
dart format lib/  # Format code
```

### **Testing Network Locally**
- Base URL in [setup.dart](lib/setup.dart) is `http://10.0.2.2:5000/` (Android emulator localhost alias)
- For physical device: Update to actual backend IP (e.g., `http://192.168.x.x:5000/`)
- For release: Use production server URL

---

## Project-Specific Patterns & Conventions

### **BLoC Creation Pattern**
```dart
// lib/views/{feature}/bloc/{feature}_bloc.dart
sealed class MyEvent {}
final class MyEventOccurred extends MyEvent {
  final String data;
  MyEventOccurred(this.data);
}

sealed class MyState {}
final class MyLoading extends MyState {}
final class MySuccess extends MyState {
  final String result;
  MySuccess(this.result);
}
final class MyError extends MyState {
  final String message;
  MyError(this.message);
}

class MyFeatureBloc extends Bloc<MyEvent, MyState> {
  MyFeatureBloc() : super(MyLoading()) {
    on<MyEventOccurred>(_onEventOccurred);
  }

  FutureOr<void> _onEventOccurred(
    MyEventOccurred event,
    Emitter<MyState> emit,
  ) async {
    emit(MyLoading());
    try {
      // Call API via global 'dio' from setup.dart
      final response = await dio.post(myEndpoint);
      emit(MySuccess(response.data['result']));
    } catch (e) {
      emit(MyError(e.toString()));
    }
  }
}
```

### **Error Handling in BLoCs**
- Always emit `Loading` state before async operations
- Catch exceptions and emit `Error` state with user-readable message
- Use try-catch; DioException auto-handled by interceptor (logs + redirects on 401)
- Example: `emit(MyError('Failed to load data. Please try again.'))`

### **API Endpoint Pattern**
```dart
// In lib/core/apis.dart
final String myEndpoint = 'api/feature/action';

// In BLoC - use global 'dio'
final response = await dio.get('$myEndpoint/$id');  // Full URL built automatically
```

### **Token Management**
- Tokens stored by `TokenStorageService.saveToken(token)` (auto-encrypted)
- Automatically injected in all requests by `AuthInterceptor`
- Cleared on logout: `TokenStorageService.clearToken()`
- On 401: Interceptor clears + redirects to login (AppRouter.pushNamed('/login'))

### **UI Widget Organization**
- Screens in `lib/views/{feature}/screen/{feature}_screen.dart`
- Reusable widgets in `lib/widgets/` (buttons, cards, dialogs)
- BLoC access: `context.read<MyBloc>()` or `BlocBuilder<MyBloc, MyState>()`
- Always use `BlocListener` for side-effects (navigation, snackbars)

---

## Integration Workflows

### **Add New Feature with BLoC**
1. **Create BLoC structure**:
   ```
   lib/views/{feature}/
   ├── bloc/
   │   ├── {feature}_bloc.dart
   │   ├── {feature}_event.dart
   │   └── {feature}_state.dart
   └── screen/
       └── {feature}_screen.dart
   ```
2. Define event/state sealed classes, register handlers in constructor
3. Create screen using `BlocBuilder` + `BlocListener`
4. Provide BLoC manually in `main.dart` `_DoinFxState.initState()`
5. Add route to `app_router.dart`, then run `flutter pub run build_runner build --delete-conflicting-outputs`

### **Add API Endpoint**
1. Add constant to [apis.dart](lib/core/apis.dart): `final String myEndpoint = 'api/path/action';`
2. In BLoC, use global `dio`: `final response = await dio.get(myEndpoint);`
3. Token auto-injected; 401 errors auto-handled by interceptor
4. Emit appropriate state: `emit(MyLoading())` → `emit(MySuccess(data))` or `emit(MyError(msg))`

### **Extend MyAccountService**
1. Add property to [my_account_service.dart](lib/core/services/accountServices/my_account_service.dart) (abstract)
2. Implement in [my_account_service_implementation.dart](lib/core/services/accountServices/my_account_service_implementation.dart)
3. Call `initialize()` in `main()` before `runApp()` if state is async-loaded

### **Add Singleton Service**
1. Create service class with abstract interface
2. Register in [locator.dart](lib/core/locator.dart): `getIt.registerLazySingleton<MyService>(() => MyServiceImpl())`
3. Access via `getIt<MyService>()`

---

## Common Pitfalls to Avoid

- ❌ Don't manually instantiate Dio (use global `dio` from [setup.dart](lib/setup.dart))
- ❌ Don't forget to regenerate routes after modifying `app_router.dart`
- ❌ Don't emit states without first checking `state is X` in BLoC handlers
- ❌ Don't store sensitive data in plain SharedPreferences (use `flutter_secure_storage`)
- ❌ Don't create BLoCs outside the locator unless they manage local UI state

---

## Debugging Tips

1. **Token Issues**: Check `TokenStorageService.getToken()` returns non-null value
2. **404 Errors**: Verify endpoint in [apis.dart](lib/core/apis.dart) matches backend
3. **State Not Updating**: Ensure BLoC is provided to widget tree via `BlocProvider`
4. **Route Navigation Fails**: Regenerate routes if `*Route.page` not found
5. **Network Logs**: AuthInterceptor prints all requests/responses to console

---

## References
- [Account Switch Implementation](ACCOUNT_SWITCH_IMPLEMENTATION.md)
- [Auth Flow Improvements](AUTH_FLOW_IMPROVEMENTS.md)
- [MyAccount Integration Guide](MYACCOUNT_INTEGRATION_GUIDE.md)
