# MyAccount BLoC & API Integration Guide

## 📋 Overview

This guide explains how to integrate the MyAccount BLoC with the API endpoints for wallet management, deposits, KYC verification, and account type switching (Real/Demo).

---

## 🏗️ Architecture

```
MyAccount Screen (UI)
      ↓
BlocProvider (wraps screen)
      ↓
MyAccountBloc (state management)
      ↓
MyAccountApiService (HTTP calls with bearer token)
      ↓
API Endpoints (backend)
```

---

## 📁 Files Created

### 1. **Data Models** (`lib/datamodel/myaccount_models.dart`)
- `PaymentMethod` - Payment method details (USDT, UPI, Bank, etc.)
- `WalletData` - User's wallet balance and account type
- `KycStatus` - KYC verification status
- `DemoAccountData` - Demo account details
- `DepositResponse` - Response from deposit creation

### 2. **API Service** (`lib/core/services/myaccount_api_service.dart`)
- Static methods for all API calls
- Automatic bearer token attachment
- Error handling and logging
- All endpoints implemented

### 3. **BLoC** (`lib/views/myAccount/bloc/my_account_bloc.dart`)
- `MyAccountBloc` - Manages all account state
- 10+ event handlers for different operations
- Proper state emission for loading/success/error

### 4. **Events** (`lib/views/myAccount/bloc/my_account_event.dart`)
- `LoadMyAccountData` - Load all data on init
- `FetchWalletBalance` - Get wallet balance
- `FetchKycStatus` - Get KYC status
- `FetchDepositMethods` - Get available deposit methods
- `FetchWithdrawalMethods` - Get available withdrawal methods
- `FetchPaymentMethodByMode` - Get specific payment method
- `CreateDepositRequest` - Create deposit
- `SwitchToDemoAccount` - Switch account type
- `SwitchToRealAccount` - Switch account type
- `FetchDemoAccountData` - Get demo account details

### 5. **States** (`lib/views/myAccount/bloc/my_account_state.dart`)
- `AccountBlocLoading` - Loading state
- `MyAccountDataLoaded` - All data loaded
- `WalletBalanceLoaded` - Wallet loaded
- `DepositCreated` - Deposit successful
- `AccountSwitchedToDemo` / `AccountSwitchedToReal` - Account switched
- `*Error` states for each operation

---

## 🔐 Bearer Token Integration

All API calls automatically include the bearer token:

```dart
final token = await TokenStorageService.getToken();
headers: {
  'Content-Type': 'application/json',
  'Authorization': 'Bearer $token',
}
```

The token is retrieved from `flutter_secure_storage` after login.

---

## 🎨 How to Update MyAccount UI

### Step 1: Wrap Screen with BLoC Provider

```dart
// lib/views/myAccount/screen/my_account_screen.dart

import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/my_account_bloc.dart';

class MyAccount extends StatefulWidget {
  const MyAccount({super.key});

  @override
  State<MyAccount> createState() => _MyAccountState();
}

class _MyAccountState extends State<MyAccount> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => MyAccountBloc()
        ..add(LoadMyAccountData(userId: /* get from auth */)),
      child: const _MyAccountView(),
    );
  }
}

class _MyAccountView extends StatelessWidget {
  const _MyAccountView();

  @override
  Widget build(BuildContext context) {
    return BlocListener<MyAccountBloc, AccountBlocState>(
      listener: (context, state) {
        // Handle errors
        if (state is AccountBlocError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.errorMessage)),
          );
        }
        if (state is DepositCreated) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Deposit created: ${state.depositResponse.message}')),
          );
        }
      },
      child: Scaffold(
        // ... rest of UI
      ),
    );
  }
}
```

### Step 2: Update Balance Card

```dart
class _BalanceCard extends StatelessWidget {
  const _BalanceCard();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MyAccountBloc, AccountBlocState>(
      builder: (context, state) {
        String balanceText = '\$0.00';
        String accountType = 'Real';

        if (state is MyAccountDataLoaded) {
          balanceText = '\$${state.wallet.balance.toStringAsFixed(2)}';
          accountType = state.accountType == 'demo' ? 'Demo' : 'Real';
        } else if (state is WalletBalanceLoaded) {
          balanceText = '\$${state.wallet.balance.toStringAsFixed(2)}';
        }

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF3E8),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Balance',
                    style: TextStyle(color: Colors.black54),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: accountType == 'demo' 
                        ? Colors.blue[100]
                        : Colors.green[100],
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      accountType,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: accountType == 'demo' ? Colors.blue : Colors.green,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                balanceText,
                style: const TextStyle(
                  fontSize: 34,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
```

### Step 3: Update Action Buttons

```dart
class _ActionButton extends StatelessWidget {
  final String title;
  final VoidCallback? onPressed;

  const _ActionButton({
    required this.title,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 46,
      child: BlocBuilder<MyAccountBloc, AccountBlocState>(
        builder: (context, state) {
          final isLoading = state is AccountBlocLoading;

          return ElevatedButton(
            onPressed: isLoading ? null : onPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation(Colors.white),
                    ),
                  )
                : Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
          );
        },
      ),
    );
  }
}

// In _ActionButtons:
class _ActionButtons extends StatelessWidget {
  const _ActionButtons();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _ActionButton(
            title: 'Deposit',
            onPressed: () {
              context.read<MyAccountBloc>().add(FetchDepositMethods());
              // Navigate to deposit screen
            },
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _ActionButton(
            title: 'Withdrawal',
            onPressed: () {
              context.read<MyAccountBloc>().add(FetchWithdrawalMethods());
              // Navigate to withdrawal screen
            },
          ),
        ),
      ],
    );
  }
}
```

### Step 4: Update User Info Card (KYC Status)

```dart
class _UserInfoCard extends StatelessWidget {
  const _UserInfoCard();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MyAccountBloc, AccountBlocState>(
      builder: (context, state) {
        String kycStatus = 'Not Started';
        Color statusColor = Colors.grey;

        if (state is MyAccountDataLoaded) {
          kycStatus = state.kycStatus.status.toUpperCase();
          statusColor = _getKycStatusColor(state.kycStatus.status);
        } else if (state is KycStatusLoaded) {
          kycStatus = state.kycStatus.status.toUpperCase();
          statusColor = _getKycStatusColor(state.kycStatus.status);
        }

        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF6EE),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              BlocBuilder<MyAccountBloc, AccountBlocState>(
                builder: (context, state) {
                  String userId = 'Loading...';
                  if (state is MyAccountDataLoaded) {
                    userId = '${state.wallet.userId}';
                  }
                  return Text(
                    'User ID : $userId',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  );
                },
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  children: [
                    const Text(
                      'KYC : ',
                      style: TextStyle(color: Colors.white, fontSize: 12),
                    ),
                    Text(
                      kycStatus,
                      style: TextStyle(
                        color: statusColor,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      Icons.verified,
                      size: 14,
                      color: statusColor,
                    ),
                  ],
                ),
              )
            ],
          ),
        );
      },
    );
  }

  Color _getKycStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'verified':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
```

---

## 🔄 Account Switching (Real ↔ Demo)

### Add Toggle Switch to Home Screen

```dart
// In HomeScreen or Settings

class _AccountTypeToggle extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocListener<MyAccountBloc, AccountBlocState>(
      listener: (context, state) {
        if (state is AccountSwitchedToDemo) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Switched to Demo Account')),
          );
        } else if (state is AccountSwitchedToReal) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Switched to Real Account')),
          );
        } else if (state is AccountSwitchError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: ${state.message}')),
          );
        }
      },
      child: BlocBuilder<MyAccountBloc, AccountBlocState>(
        builder: (context, state) {
          bool isDemo = false;
          if (state is MyAccountDataLoaded) {
            isDemo = state.accountType == 'demo';
          }

          return Row(
            children: [
              const Text('Real Account'),
              Switch(
                value: isDemo,
                onChanged: (value) {
                  if (value) {
                    context.read<MyAccountBloc>().add(
                      SwitchToDemoAccount(userId: /* userId */),
                    );
                  } else {
                    context.read<MyAccountBloc>().add(
                      SwitchToRealAccount(userId: /* userId */),
                    );
                  }
                },
              ),
              const Text('Demo Account'),
            ],
          );
        },
      ),
    );
  }
}
```

---

## 💳 Creating a Deposit (Full Flow Example)

### 1. Show Deposit Methods

```dart
onPressed: () {
  context.read<MyAccountBloc>().add(FetchDepositMethods());
}
```

### 2. Listen for Methods and Display Dialog

```dart
BlocListener<MyAccountBloc, AccountBlocState>(
  listener: (context, state) {
    if (state is DepositMethodsLoaded) {
      _showDepositMethodDialog(context, state.methods);
    }
  },
  child: // ...
)
```

### 3. Handle Payment Method Selection

```dart
void _showDepositMethodDialog(
  BuildContext context,
  List<PaymentMethod> methods,
) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Select Payment Method'),
      content: SizedBox(
        height: 300,
        child: ListView.builder(
          itemCount: methods.length,
          itemBuilder: (context, index) {
            final method = methods[index];
            return ListTile(
              title: Text(method.displayName),
              onTap: () {
                Navigator.pop(context);
                _showDepositForm(context, method);
              },
            );
          },
        ),
      ),
    ),
  );
}
```

### 4. Create Deposit

```dart
void _submitDeposit(BuildContext context, String paymentMethod) {
  final bloc = context.read<MyAccountBloc>();
  
  bloc.add(CreateDepositRequest(
    userId: userId,
    username: username,
    email: email,
    paymentMethod: paymentMethod, // 'usdt', 'upi', etc.
    transactionId: 'TXN_${DateTime.now().millisecondsSinceEpoch}',
    amount: 100.0,
    // Add other fields based on payment method
    upiId: paymentMethod == 'upi' ? '9876543210@upi' : null,
    usdtAddress: paymentMethod == 'usdt' ? 'TMHj...' : null,
  ));
}
```

---

## 🚀 How to Use: Step-by-Step

### Step 1: Get User ID

```dart
// From auth context or user model
final user = await TokenStorageService.getUser();
final userId = user?.userId ?? 0;
```

### Step 2: Create BLoC in Screen

```dart
BlocProvider(
  create: (context) => MyAccountBloc()
    ..add(LoadMyAccountData(userId: userId)),
  child: const _MyAccountView(),
)
```

### Step 3: Listen for State Changes

```dart
BlocListener<MyAccountBloc, AccountBlocState>(
  listener: (context, state) {
    if (state is DepositCreated) {
      // Show success
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(state.depositResponse.message)),
      );
    }
    if (state is AccountBlocError) {
      // Show error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(state.errorMessage)),
      );
    }
  },
  child: // ...
)
```

### Step 4: Emit Events on User Action

```dart
// Deposit button
context.read<MyAccountBloc>().add(FetchDepositMethods());

// Account switch
context.read<MyAccountBloc>().add(
  SwitchToDemoAccount(userId: userId),
);

// Refresh balance
context.read<MyAccountBloc>().add(
  FetchWalletBalance(userId: userId),
);
```

---

## 📝 API Endpoint Reference

| Endpoint | Method | Purpose | Params/Body |
|----------|--------|---------|-------------|
| `/api/payment/getactive?type=deposit` | GET | Get active payment methods | `type` |
| `/api/payment/get?payment_mode=usdt` | GET | Get specific payment method | `payment_mode` |
| `/api/wallet/{user_id}` | GET | Get wallet balance | `user_id` |
| `/api/kyc/status/{id}` | GET | Get KYC status | `id` |
| `/api/deposit/create` | POST | Create deposit | `user_id`, `amount`, etc. |
| `/api/demoaccount/demo/account-type/{user_id}` | POST | Switch to demo | `user_id` |
| `/api/wallet/{user_id}` | POST | Switch to real | `user_id` |
| `/api/demoaccount/demo-account/{user_id}` | GET | Get demo account data | `user_id` |

---

## 🔐 Bearer Token Handling

The `MyAccountApiService` automatically:
1. Retrieves token from `TokenStorageService`
2. Adds it to headers: `Authorization: Bearer {token}`
3. Handles 401 errors (token expired)
4. Logs all requests/responses

**Token is obtained from**: `flutter_secure_storage` after successful login.

---

## ✅ Testing Checklist

- [ ] Load wallet balance on screen init
- [ ] Display KYC status with proper colors
- [ ] Fetch and show deposit/withdrawal methods
- [ ] Create deposit request with different payment methods
- [ ] Switch between demo and real accounts
- [ ] Error messages display correctly
- [ ] Loading state shows spinner
- [ ] Success messages show snackbar
- [ ] Token is included in all requests

---

## 🐛 Debugging

Enable logging in API service to see all requests:

```dart
print('GET $url → ${response.statusCode}');
print('Response: ${response.body}');
```

Check token existence:

```dart
final token = await TokenStorageService.getToken();
print('Token: $token');
```

---

## 📚 Next Steps

1. Update `my_account_screen.dart` with BLoC provider
2. Create deposit dialog/flow screen
3. Create account switching UI in settings
4. Add withdrawal flow (similar to deposit)
5. Test all API calls with real backend

---

**Ready to integrate!** Let me know if you need clarification on any part. 🚀
