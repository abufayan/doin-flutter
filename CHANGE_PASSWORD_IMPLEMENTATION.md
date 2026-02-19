# Change Password Feature Implementation

## Overview
Complete implementation of the Change Password feature with API integration, BLoC pattern, and form validation.

## Files Created/Modified

### 1. **API Endpoint** - `lib/core/apis.dart`
```dart
final String changePassword = 'api/auth/change-password';
```
- Endpoint: `POST http://10.0.2.2:5000/api/auth/change-password`
- Body: `{ user_id, oldPassword, newPassword, confirmPassword }`

### 2. **Response Model** - `lib/datamodel/change_password_response.dart` (NEW)
```dart
@immutable
class ChangePasswordResponse {
  final String status;      // "success" or "error"
  final String message;     // Response message
  
  bool get isSuccess => status.toLowerCase() == 'success';
}
```

### 3. **BLoC Events** - `lib/views/DrawerTabs/changePassword/bloc/change_password_event.dart`
```dart
final class ChangePasswordSubmitted extends ChangePasswordEvent {
  final String oldPassword;
  final String newPassword;
  final String confirmPassword;
}
```

### 4. **BLoC States** - `lib/views/DrawerTabs/changePassword/bloc/change_password_state.dart`
```dart
final class ChangePasswordLoading extends ChangePasswordState {}
final class ChangePasswordSuccess extends ChangePasswordState {
  final String message;
}
final class ChangePasswordError extends ChangePasswordState {
  final String message;
}
final class PasswordMismatchError extends ChangePasswordState {
  final String message;  // "New password and confirm password do not match"
}
```

### 5. **BLoC Logic** - `lib/views/DrawerTabs/changePassword/bloc/change_password_bloc.dart`
**Handles**:
- ✅ Client-side validation: Checks if newPassword === confirmPassword
- ✅ Shows `PasswordMismatchError` immediately if passwords don't match
- ✅ API call with user_id from MyAccountService
- ✅ Parses response and emits appropriate state
- ✅ Handles DioException with error message extraction

### 6. **Screen** - `lib/views/DrawerTabs/changePassword/screen/change_password_screen.dart`
**Features**:
- ✅ Three password fields: Old, New, Confirm
- ✅ Toggle visibility icons for each field
- ✅ Password rules display (8-15 chars, upper/lower, numbers)
- ✅ Error message container with red styling:
  - Red border
  - Light red background
  - Error icon + message text
- ✅ Submit button with loading state
- ✅ Success message via SnackBar (green)
- ✅ Auto-redirect to previous screen after 2 seconds on success
- ✅ Clear fields on success

## Data Flow

```
User fills form → Clicks "Next" 
  ↓
BLoC receives ChangePasswordSubmitted event
  ↓
Check: newPassword === confirmPassword?
  ├─ NO  → Emit PasswordMismatchError → Display error on page
  └─ YES → Emit ChangePasswordLoading
           ↓
           API POST with user_id + credentials
           ↓
           Response received
           ├─ Success → Emit ChangePasswordSuccess
           │            Show green SnackBar
           │            Clear fields
           │            Redirect after 2s
           └─ Error → Emit ChangePasswordError (from API)
                      Display error on page
```

## Validation Logic

### Client-Side (Before API Call)
- Check: `newPassword !== confirmPassword`
- Error shown: "New password and confirm password do not match"
- No API call made

### Server-Side (API Response)
- Missing fields: `"All fields are required"`
- Old password incorrect: `"Old Password is incorrect"`
- Passwords don't match (shouldn't happen but handled): `"New password and confirm password is not matching"`
- Success: `"Password changed successfully, Redirect to Login."`

## Error Display Style

```
┌─────────────────────────────────────────┐
│ 🔴 Error message text goes here          │
│    with proper formatting and           │
│    red border and background            │
└─────────────────────────────────────────┘
```
- Background: Red (50% opacity)
- Border: Red (300% opacity)
- Icon: Error icon in red
- Text: Red with size 13px, bold
- Displayed when any error occurs

## Successful Flow

1. User fills all three fields
2. Clicks "Next" button
3. BLoC validates locally
4. If valid, API call made
5. Button shows loading spinner
6. On success:
   - Green SnackBar shows: "Password changed successfully, Redirect to Login."
   - Fields cleared
   - Auto-redirects after 2 seconds

## Testing Checklist

- [ ] Old password field works
- [ ] New password field works with visibility toggle
- [ ] Confirm password field works with visibility toggle
- [ ] Error message displays when passwords don't match
- [ ] Loading spinner shows during API call
- [ ] Success message shows on successful change
- [ ] Fields clear after success
- [ ] Auto-redirect works
- [ ] Old password incorrect error handled
- [ ] All API response messages display correctly

## Technical Details

- **Pattern**: BLoC + Form Validation
- **HTTP Client**: Dio with AuthInterceptor
- **State Management**: flutter_bloc
- **User ID Source**: `MyAccountService.user?.userId`
- **Base URL**: Uses emulator URL from setup.dart
- **Token**: Auto-injected by AuthInterceptor
