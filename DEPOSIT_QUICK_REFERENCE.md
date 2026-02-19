# Deposit Feature - Quick Reference Guide

## Implementation Complete ✅

### What Was Built
Complete deposit submission flow with:
- Form validation
- File upload (payment screenshot)
- Error handling and display
- Loading states
- Success/failure feedback

---

## Key Files

| File | Purpose |
|------|---------|
| [deposit_response_model.dart](lib/views/withdraw and deposit/deposit/datamodel/deposit_response_model.dart) | API response model |
| [deposit_bloc.dart](lib/views/withdraw and deposit/deposit/bloc/deposit_bloc.dart) | Business logic + API call |
| [deposit_event.dart](lib/views/withdraw and deposit/deposit/bloc/deposit_event.dart) | OnSubmit event with all params |
| [deposit_state.dart](lib/views/withdraw and deposit/deposit/bloc/deposit_state.dart) | Loading, Success, Failure states |
| [deposit_detail_screen.dart](lib/views/withdraw and deposit/deposit/screen/deposit_detail_screen.dart) | UI with form + error display |

---

## Form Submission Flow

### 1. User Input Collection
- Amount (required, numeric)
- Transaction ID (required)
- UPI ID (optional, only for UPI)
- Payment Screenshot (required)

### 2. Validation
```dart
✓ Screenshot uploaded
✓ Transaction ID filled
✓ Amount is valid number
```

### 3. API Call
```
POST /api/deposit/create
Body: FormData (multipart)
├── user_id
├── username  
├── email
├── payment_method ('upi' or 'usdt')
├── payment_type ('upi' or 'usdt')
├── transaction_id
├── enter_amount
├── upi_id (optional)
└── payment_screenshot (file)
```

### 4. Response Handling
```
Success → Show message + Navigate back
Error   → Show error banner + Snackbar
Loading → Disable submit button + Show spinner
```

---

## Error Handling Examples

### Backend Error (e.g., missing screenshot)
```json
{
    "status": "error",
    "message": "Deposit creation failed.",
    "error": "Column 'payment_screenshot' cannot be null"
}
```
**User sees:** Red error banner in form body + snackbar

### Validation Errors (client-side)
- "Payment screenshot is required"
- "Transaction ID is required"
- "Amount is required"
- "Please enter a valid amount"

### Network Errors
- Caught as DioException
- User-friendly message displayed

---

## State Management

### DepositBloc States
```dart
DepositInitial     // Initial state
DepositLoading     // API call in progress
DepositSuccess     // Submitted successfully (with response details)
DepositFailure     // Error occurred (with error message)
```

---

## UI Components

### Error Display (In Form Body)
```dart
if (_errorMessage != null)
  Container(
    color: red.shade50,
    border: red border,
    child: Row(
      Icon(error),
      Text(error_message)
    )
  )
```

### Submit Button
```dart
ElevatedButton(
  onPressed: isLoading ? null : _submit,
  child: isLoading 
    ? CircularProgressIndicator()
    : Text('Submit')
)
```

### Conditional UPI Field
```dart
if (widget.config.type.toString().contains('UPI'))
  TextFormField(
    label: 'UPI ID',
    hint: 'name@bank'
  )
```

---

## Testing Scenarios

### ✅ Success Flow
1. Fill all fields
2. Upload screenshot
3. Click Submit
4. See loading spinner
5. See success message
6. Auto-navigate back

### ✅ Missing Screenshot
1. Try submit without image
2. See error: "Payment screenshot is required"
3. Upload image
4. Submit again → Success

### ✅ Invalid Amount
1. Enter non-numeric amount
2. See form validation error
3. Fix amount
4. Submit → Success

### ✅ API Error
1. Fill form correctly
2. API returns error response
3. See error banner in form
4. See snackbar notification

---

## Payment Type Logic

```dart
if (config.type.contains('UPI')) {
    paymentType = 'upi'
    // Show UPI ID field
} else {
    paymentType = 'usdt'
    // Hide UPI ID field
}

// Both sent to backend as:
payment_method: paymentType
payment_type: paymentType
```

---

## Important Notes

⚠️ **UI Design:** Completely unchanged - only added error message banner
⚠️ **File Upload:** Uses multipart/form-data for image
⚠️ **User Data:** Fetched from `getIt<MyAccountService>()`
⚠️ **Loading State:** Button disabled during submission
⚠️ **Navigation:** Auto-back after 2 seconds on success

---

## API Integration

**Endpoint:** `api/deposit/create` (POST)
**Base URL:** From [setup.dart](lib/setup.dart) (Android: http://10.0.2.2:5000/)
**Auth:** Automatically added via `AuthInterceptor`
**Timeout:** 30 seconds (from Dio config)

**Success Response:**
```json
{
    "status": "success",
    "message": "Deposit submitted successfully.",
    "deposit_id": 28,
    "payment_screenshot": "https://..."
}
```

**Error Response:**
```json
{
    "status": "error",
    "message": "Deposit creation failed.",
    "error": "Column 'payment_screenshot' cannot be null"
}
```

---

## Dependencies Used

- `bloc` & `flutter_bloc` - State management
- `dio` - HTTP client
- `image_picker` - Image selection
- `flutter_secure_storage` - Token storage (via interceptor)
- `auto_route` - Navigation

---

## Next Steps (Optional)

1. Add image compression before upload
2. Add receipt number OCR validation
3. Add deposit history/tracking
4. Add retry mechanism for failed deposits
5. Add receipt preview before submission
