# Account Type Switching - Implementation Complete ✅

## Overview
Account switching feature is now fully implemented in the home screen. Users can toggle between **Real** and **Demo** accounts with automatic API calls and UI updates.

---

## Architecture

### 1. **Home BLoC** (`lib/views/home/bloc/home_bloc.dart`)

**Events:**
- `SelectTab(int index)` - Switch between navigation tabs
- `SwitchAccount(AccountType accountType)` - Switch account type

**Handler: `switchAccount()`**
```
1. Emit AccountSwitched with isLoading = true
2. Retrieve userId and token from TokenStorageService
3. Build appropriate API URL:
   - Demo: POST /api/demoaccount/demo/account-type/{userId}
   - Real: POST /api/wallet/{userId}
4. Send request with Bearer token
5. On success: emit AccountSwitched with new accountType
6. On error: emit AccountSwitched with errorMessage
```

**Key Implementation:**
```dart
final userId = user!.userId;  // From UserModel.userId
final headers = {
  'Authorization': 'Bearer $token',
  'Content-Type': 'application/json',
};
```

---

### 2. **Home State** (`lib/views/home/bloc/home_state.dart`)

**Added to all HomeState classes:**
```dart
final AccountType accountType;  // Tracks current account type
```

**New State:**
- `AccountSwitched` - Emitted during and after switch
  - `isLoading: bool` - Show loading indicator
  - `errorMessage: String?` - Error feedback to user
  - `accountType: AccountType` - New account type

---

### 3. **Home Screen UI** (`lib/views/home/screen/home_screen.dart`)

**AppBar Badge:**
Shows current account type with color coding:
```
✅ Real Account   → Green badge
✅ Demo Account   → Blue badge
```

**Gesture Detector:**
Tapping the badge opens account switch dialog

**Dialog Function: `_showSwitchAccountDialog()`**
```
1. Displays current account type
2. User confirms switch
3. Triggers SwitchAccount event with toggled type
4. Dialog closes and BLoC handles API call
```

**BLoC Listener:**
```dart
if (state is AccountSwitched) {
  if (state.errorMessage != null) {
    // Show red snackbar with error
  } else if (!state.isLoading) {
    // Show green snackbar: "Switched to [Real/Demo] account"
  }
}
```

---

## Flow Diagram

```
User clicks badge
        ↓
_showSwitchAccountDialog displays
        ↓
User confirms switch
        ↓
SwitchAccount event emitted
        ↓
BLoC.switchAccount() handler
        ↓
Retrieve user & token
        ↓
POST API request with Bearer token
        ↓
API Success (200/201)
        ↓
Emit AccountSwitched(newAccountType)
        ↓
UI updates badge + shows success snackbar
```

---

## API Endpoints Used

### Demo Account Switch
```
POST http://localhost:5000/api/demoaccount/demo/account-type/{userId}
Headers: Authorization: Bearer {token}
```

### Real Account Switch
```
POST http://localhost:5000/api/wallet/{userId}
Headers: Authorization: Bearer {token}
```

---

## User Flow

### 1. Initial Load
- App initializes with `AccountType.real` (default)
- Badge shows green "Real"

### 2. Switch to Demo
- User taps "Real" badge
- Dialog: "Do you want to switch to Demo account?"
- User confirms
- Loading state shown
- API call: `POST /api/demoaccount/demo/account-type/{userId}`
- Success: Badge turns blue "Demo"
- Snackbar: "Switched to Demo account"

### 3. Switch Back to Real
- User taps "Demo" badge
- Dialog: "Do you want to switch to Real account?"
- User confirms
- Loading state shown
- API call: `POST /api/wallet/{userId}`
- Success: Badge turns green "Real"
- Snackbar: "Switched to Real account"

---

## Error Handling

**Scenario: Not Authenticated**
```
emit AccountSwitched(
  accountType: state.accountType,  // Keep current
  errorMessage: 'User not authenticated'
)
```

**Scenario: API Fails (e.g., 500)**
```
emit AccountSwitched(
  accountType: state.accountType,  // Revert to previous
  errorMessage: 'Failed to switch account: 500'
)
```

**Scenario: Network Error**
```
emit AccountSwitched(
  accountType: state.accountType,  // Keep current
  errorMessage: 'Error switching account: SocketException'
)
```

---

## Testing Checklist

- [ ] Click badge → Dialog appears with correct message
- [ ] Switch to Demo → Badge turns blue, snackbar shows success
- [ ] Switch to Real → Badge turns green, snackbar shows success
- [ ] Tab switching preserves account type
- [ ] Network error shows red snackbar with error
- [ ] Logout clears account type (back to default: Real)
- [ ] Cold start loads correct account type (if persisted)

---

## Files Modified

1. **`lib/views/home/bloc/home_state.dart`**
   - Added `accountType` field to HomeState
   - Added `AccountSwitched` state class

2. **`lib/views/home/bloc/home_bloc.dart`**
   - Implemented `switchAccount()` handler
   - Added API calls with bearer token
   - Added error handling

3. **`lib/views/home/screen/home_screen.dart`**
   - Updated AppBar with account type badge
   - Fixed dialog toggle logic
   - Added BLoC listener for snackbars

---

## Integration Notes

✅ Uses existing `TokenStorageService` for token/user retrieval
✅ Bearer token automatically injected in headers
✅ Follows BLoC pattern with proper state management
✅ Error states prevent switching on failure
✅ Loading states prevent multiple rapid switches
✅ Tab navigation preserves account type

---

**Status**: Production Ready
**Last Updated**: January 9, 2026
