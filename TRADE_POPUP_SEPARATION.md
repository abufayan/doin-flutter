# Trade Popup Separation - Implementation Summary

## Overview
Separated the buy and sell popups in the trade feature with different labels based on order type, while maintaining the same field names and form structure.

## Files Created

### 1. `lib/views/trade/ui/widgets/buy_popup.dart`
- **Main function**: `showBuyPopup(context, symbol)`
- **Features**:
  - 3 tabs: Market, Limit, Advanced
  - Same form fields as before: `symbol`, `order_type`, `lot_size`, `trigger_price`, `take_profit`, `stop_loss`
  - **Dynamic label for trigger_price**:
    - **Limit tab**: Shows "Limit Price"
    - **Advanced tab**: Shows "Buy Above"
  - **Form field name unchanged**: Still uses `trigger_price` internally
  - Green "BUY" submit button
  - Emits `TradeBuyPressed` event

### 2. `lib/views/trade/ui/widgets/sell_popup.dart`
- **Main function**: `showSellPopup(context, symbol)`
- **Features**:
  - 3 tabs: Market, Limit, Advanced
  - Same form fields as before: `symbol`, `order_type`, `lot_size`, `trigger_price`, `take_profit`, `stop_loss`
  - **Dynamic label for trigger_price**:
    - **Limit tab**: Shows "Limit Price"
    - **Advanced tab**: Shows "Sell Below"
  - **Form field name unchanged**: Still uses `trigger_price` internally
  - Red "SELL" submit button
  - Emits `TradeSellPressed` event

## Files Modified

### `lib/views/trade/ui/trade_page.dart`
- **Removed**:
  - Shared `showTradePopup()` function
  - `OrderFormContent` class
  - `_SubmitButton` class
  - Unused imports (lot_field, margin_summary, optional_field, form_builder)
  
- **Updated**:
  - Imports: Added `buy_popup.dart` and `sell_popup.dart`
  - `BuySellSection` button callbacks:
    - SELL button: Calls `showSellPopup(context, symbol: symbol)`
    - BUY button: Calls `showBuyPopup(context, symbol: symbol)`
  - Removed `TradeSide` enum usage (no longer needed)

## Key Implementation Details

### Label Logic (Both Popups)
```dart
OptionalPriceField(
  'trigger_price',  // Field name never changes
  orderType == OrderType.limit ? 'Limit Price' : 'BUY Above/Sell Below',
)
```

### Label Mapping
| Popup | Order Type | Label |
|-------|-----------|-------|
| **Buy** | Market | Not shown |
| **Buy** | Limit | "Limit Price" |
| **Buy** | Advanced | "Buy Above" |
| **Sell** | Market | Not shown |
| **Sell** | Limit | "Limit Price" |
| **Sell** | Advanced | "Sell Below" |

### Form Structure Preserved
- **Hidden fields** (FormBuilderField with no UI):
  - `symbol`: Carries the symbol value
  - `order_type`: Updated when tab changes (market/limit/advanced)
  
- **Input fields**:
  - `lot_size`: Volume field with +/- buttons
  - `trigger_price`: Dynamic label based on order type
  - `take_profit`: Always "Take Profit"
  - `stop_loss`: Always "Stop Loss"

### Data Flow Unchanged
1. User interacts with form fields
2. Form values stored in `formKey.currentState?.value`
3. Submit button calls `form.save()` then adds event with full form data
4. Data passed to BLoC unchanged

## Testing Checklist

- [ ] BUY popup shows:
  - Limit tab: "Limit Price"
  - Advanced tab: "Buy Above"
  
- [ ] SELL popup shows:
  - Limit tab: "Limit Price"
  - Advanced tab: "Sell Below"
  
- [ ] Form submission works for both popups
- [ ] Field values are correctly passed to BLoC
- [ ] No form errors when submitting
- [ ] Success/failure messages appear
- [ ] Popup closes after successful submission

## Notes
- All field names remain unchanged (`trigger_price`, `lot_size`, etc.)
- Only labels are different per popup
- Form structure and submission logic identical
- Market tab doesn't show trigger_price field (as before)
- All form validation rules preserved
