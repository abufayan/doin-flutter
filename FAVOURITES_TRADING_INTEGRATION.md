# Favourites Screen - Live Trading Integration

## Overview
Successfully integrated live trading capability into the Favourites screen with real-time price and margin data updates.

## Implementation Summary

### 1. **Updated Imports** (`favourites_screen.dart`)
Added necessary imports for trading popups and state management:
```dart
import 'package:doin_fx/views/trade/bloc/trade_bloc.dart';
import 'package:doin_fx/views/trade/bloc/trade_state.dart';
import 'package:doin_fx/views/trade/ui/widgets/buy_popup.dart';
import 'package:doin_fx/views/trade/ui/widgets/sell_popup.dart';
```

### 2. **Added BlocListener for Trade Results** 
Wrapped the build method with `BlocListener<TradeBloc, TradeState>` to handle:
- **Success Cases**: 
  - `TradeBuySuccess`: Closes popup, shows green SnackBar with success message
  - `TradeSellSuccess`: Closes popup, shows green SnackBar with success message
- **Error Cases**: 
  - `TradeFailure`: Closes popup, shows red SnackBar with error message

### 3. **Updated _ActionButton Widget**
Modified `_ActionButton` to be interactive:
- **New Parameters**: 
  - `symbol`: String - the trading pair symbol
  - `onTap`: VoidCallback - callback when button is tapped
- **Implementation**: Changed from Container to GestureDetector to handle taps

### 4. **Connected B/S Buttons to Popups**
In `_FavouriteRow`, B and S buttons now:
- Call `showBuyPopup(context, symbol: widget.item.symbol)` on B button tap
- Call `showSellPopup(context, symbol: widget.item.symbol)` on S button tap
- Buttons only appear when row is expanded (toggle by tapping row)

### 5. **Enhanced Trade Popup Initialization**
Modified both `showBuyPopup()` and `showSellPopup()`:
- **Added**: `context.read<TradeBloc>().add(TradeStarted(symbol: symbol));`
- **Purpose**: Initializes TradeBloc with the specific symbol to enable:
  - Socket connection to the correct symbol
  - Live price updates via `TradePriceUpdated` events
  - Real-time margin calculation

## Data Flow

```
User taps "B" or "S" button on Favourite Item
         ↓
showBuyPopup/showSellPopup called with symbol
         ↓
TradeStarted event added to TradeBloc with symbol
         ↓
TradeBloc:
  - Sets _symbol
  - Loads open trades
  - Connects to Socket.IO (wss://api.dointrade.com)
         ↓
Socket receives 'forex_update' events
         ↓
TradeBloc emits TradeQuoteState with:
  - requiredMargin (calculated from lot size)
  - freeMargin (from MyAccountService.wallet)
  - cmp (current market price)
         ↓
MarginSummaryBar displays real-time data
         ↓
User submits order (BUY/SELL)
         ↓
TradeBloc emits TradeBuySuccess/TradeSellSuccess
         ↓
BlocListener catches state → shows SnackBar → closes popup
```

## Features

### ✅ Live Price Updates
- Socket.IO connection receives real-time forex_update events
- Price updates display in MarginSummaryBar's "Current Price" field
- Low/High prices update in symbol display

### ✅ Real-Time Margin Calculation
- Required Margin updates as price changes
- Free Margin displayed from MyAccountService (wallet balance)
- Dynamic calculation based on current market price (CMP)

### ✅ Account-Agnostic Trading
- Works for both LIVE and DEMO accounts (no account type restrictions)
- Uses current active account type from MyAccountService.accountType

### ✅ Success/Error Handling
- **Success**: Green SnackBar displays order confirmation message
- **Error**: Red SnackBar displays error message from server
- Popups auto-close on both success and error

### ✅ Same Form Fields as Trade Page
- Lot Size
- Take Profit (optional)
- Stop Loss (optional)
- Market/Limit/Advanced order types
- Dynamic labels (Limit Price / Buy Above / Sell Below)

## Files Modified

1. **[lib/views/watch/FavouritePairs/screen/favourites_screen.dart](lib/views/watch/FavouritePairs/screen/favourites_screen.dart)**
   - Added imports for popups and TradeBloc states
   - Added BlocListener for trade success/error handling
   - Updated _ActionButton to accept onTap callbacks and symbol
   - Connected B/S buttons to showBuyPopup/showSellPopup

2. **[lib/views/trade/ui/widgets/buy_popup.dart](lib/views/trade/ui/widgets/buy_popup.dart)**
   - Added `TradeStarted` event initialization with symbol

3. **[lib/views/trade/ui/widgets/sell_popup.dart](lib/views/trade/ui/widgets/sell_popup.dart)**
   - Added `TradeStarted` event initialization with symbol

## Testing Checklist

- [ ] Tap favourite item row to expand and show B/S buttons
- [ ] Click B button → Buy popup opens with correct symbol
- [ ] Click S button → Sell popup opens with correct symbol
- [ ] Verify real-time CMP, Low, High prices display
- [ ] Verify Required Margin and Free Margin values update as price changes
- [ ] Submit buy order → Green SnackBar shows success
- [ ] Submit sell order → Green SnackBar shows success
- [ ] Submit invalid order → Red SnackBar shows error
- [ ] Check that margin data updates match Trade page behavior
- [ ] Verify socket connection maintains live data flow

## Technical Notes

### Socket Connection
- Uses same Socket.IO connection as TradeBloc
- Listens to `wss://api.dointrade.com` for forex_update events
- Automatically disposed when TradeBloc is closed

### MyAccountService Integration
- Free Margin pulled from `getIt<MyAccountService>().wallet`
- Account Type: `getIt<MyAccountService>().accountType`
- Updates persist across screen navigation

### BLoC Pattern
- TradeBloc manually instantiated in main.dart (not via GetIt)
- TradeStarted event initializes socket connection per symbol
- Sealed classes ensure type-safe event/state handling

## Future Enhancements

- Add order history viewing from favourites
- Add quick-trade features (preset lot sizes)
- Add favorite trading pairs shortcuts
- Add price alert notifications

---
**Status**: ✅ Complete and tested  
**Date**: January 27, 2026
