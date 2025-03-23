# Currency Converter

A powerful, responsive iOS application for real-time currency conversion with an elegant UI, caching system, and historical tracking.

<img src="https://github.com/user-attachments/assets/f0273a95-bf91-4305-b0af-a764315b4b79" width="120" height="250">
<img src="https://github.com/user-attachments/assets/94ba6fc9-bbd4-4e4c-a9d0-5e5ef9c86b11" width="120" height="250">

## Features

- **Real-time Currency Exchange:** Fetches up-to-date exchange rates from a commercial API
- **Multiple Currency Support:** Convert between various international currencies
- **Historical Tracking:** Keeps a record of your recent conversions
- **Responsive UI:** Clean interface with intuitive controls and visual feedback
- **Smart Caching:** Reduces API calls with a 30-second local cache
- **Error Handling:** Robust error management with user-friendly messages
- **Performance Optimized:** Implements efficient task cancellation and debouncing

## Architecture

This app follows the MVVM (Model-View-ViewModel) architecture pattern:

- **Model:** Currency and exchange rate data structures
- **View:** UI components including ConverterView and HistoryView
- **ViewModel:** Business logic in CurrencyConverterViewModel

## Technical Implementation

### Core Components

- **CurrencyService:** Handles API calls with robust error handling, caching, and logging
- **CurrencyConverterViewModel:** Manages business logic and state
- **ConverterView:** Main UI component for currency conversion
- **HistoryView:** Displays recent conversion history

### Key Technical Features

- **Combine Framework:** Reactive programming for UI updates and data flow
- **Async/Await:** Modern concurrency for network requests
- **Task Management:** Smart handling of concurrent operations
- **SnapKit:** Programmatic Auto Layout constraints
- **Debouncing:** Prevents excessive API calls during user input
- **Real-time Updates:** Automatically refreshes exchange rates every 10 seconds

## Getting Started

### Prerequisites

- iOS 16.6+
- Xcode 13.0+
- Swift 5.5+

### Installation

1. Clone the repository
```bash
git clone https://github.com/yourusername/CurrencyConverter.git
```

2. Open the project in Xcode
```bash
cd CurrencyConverter
open CurrencyConverter.xcodeproj
```

3. Install dependencies using CocoaPods or Swift Package Manager (if applicable)
```bash
pod install
# or
swift package resolve
```

4. Build and run the application

## Usage

1. Select source and target currencies from the dropdown menus
2. Enter the amount you want to convert
3. View the converted amount and exchange rate
4. Use the swap button to quickly reverse the conversion
5. Check your conversion history at the bottom of the screen

## Dependencies

- **SnapKit:** Simplifies Auto Layout constraints
- **Combine:** Used for reactive programming

## API Integration

The app uses currency exchange API at `api.evp.lt/currency/commercial/exchange`.
