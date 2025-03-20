//
//  CurrencyConverterViewModel.swift
//  CurrencyConverter
//
//  Created by tornike <parunashvili on 14.03.25.
//

import Foundation
import Combine

final class CurrencyConverterViewModel: ObservableObject {
  // MARK: - Published Properties
  
  @Published var fromCurrency: Currency = .euro
  @Published var toCurrency: Currency = .usd
  @Published var inputAmount: String = "1.0"
  @Published var convertedAmount: String = ""
  @Published var errorMessage: String? = nil
  @Published var exchangeRate: String = ""
  @Published var isLoading: Bool = false
  
  // MARK: - Available Currencies
  let availableCurrencies: [Currency] = Currency.allCases
  
  // MARK: - Conversion History
  @Published var conversionHistory: [ConversionHistory] = []
  
  // MARK: - Private Properties
  
  private let service: CurrencyServiceProtocol
  private var cancellables = Set<AnyCancellable>()
  private var timer: AnyCancellable?
  private var lastInputAmountValue: String = ""
  
  // MARK: - Initializer
  
  init(service: CurrencyServiceProtocol = CurrencyService(loggingEnabled: true)) {
    self.service = service
    setupBindings()
    fetchInitialExchangeRate()
  }
  
  // MARK: - Setup Methods
  
  private func setupBindings() {
    /// Monitor input amount changes with debounce
    $inputAmount
      .dropFirst()
      .debounce(for: .seconds(0.5), scheduler: RunLoop.main)
      .sink { [weak self] newValue in
        guard let self = self, self.lastInputAmountValue != newValue else { return }
        self.lastInputAmountValue = newValue
        Task { await self.convert() }
      }
      .store(in: &cancellables)
    
    /// Monitor currency changes
    Publishers.CombineLatest($fromCurrency, $toCurrency)
      .dropFirst()
      .sink { [weak self] fromCurrency, toCurrency in
        Task { await self?.fetchExchangeRate() }
      }
      .store(in: &cancellables)
    
    /// Setup timer for periodic refresh (every 10 seconds)
    timer = Timer.publish(every: 10, on: .main, in: .common)
      .autoconnect()
      .sink { [weak self] _ in
        Task { await self?.fetchExchangeRate(forceRefresh: true) }
      }
  }
  
  // MARK: - Public Methods
  
  func fetchInitialExchangeRate() {
    Task { await self.fetchExchangeRate() }
  }
  
  func swapCurrencies() {
    let tempCurrency = fromCurrency
    fromCurrency = toCurrency
    toCurrency = tempCurrency
    
    /// After swapping, fetch the updated exchange rate
    Task { await fetchExchangeRate() }
  }
  
  func fetchExchangeRate(forceRefresh: Bool = false) async {
    /// Skip if currencies are the same
    if fromCurrency == toCurrency {
      exchangeRate = "1.0000"
      await convert()
      return
    }
    
    /// Clear cache if force refresh is requested
    if forceRefresh {
      service.clearCache()
    }
    
    isLoading = true
    errorMessage = nil
    
    do {
      let amount: Double = 1.0
      let exchangeRateValue = try await service.fetchExchangeRate(
        fromAmount: amount,
        fromCurrency: fromCurrency,
        toCurrency: toCurrency
      )
      
      /// Calculate the actual exchange rate
      let rate = exchangeRateValue / amount
      exchangeRate = String(format: "%.4f", rate)
      
      /// Update the converted amount
      await convert()
    } catch {
      handleError(error)
    }
    
    isLoading = false
  }
  
  func convert() async {
    /// First validate the input
    guard let amount = Double(inputAmount.replacingOccurrences(of: ",", with: ".")) else {
      errorMessage = "Please enter a valid number"
      convertedAmount = ""
      return
    }
    
    /// Skip conversion if the input amount is zero
    if amount == 0 {
      convertedAmount = "0.00"
      return
    }
    
    /// If currencies are the same, the amount doesn't change
    if fromCurrency == toCurrency {
      convertedAmount = String(format: "%.2f", amount)
      return
    }
    
    /// Check if we have a valid exchange rate
    guard let exchangeRateValue = Double(exchangeRate), exchangeRateValue > 0 else {
      /// If not, try to fetch it first
      await fetchExchangeRate()
      
      /// Then check again
      guard let exchangeRateValue = Double(exchangeRate), exchangeRateValue > 0 else {
        errorMessage = "Unable to get a valid exchange rate"
        return
      }
      
      /// Continue with conversion below
      let convertedValue = amount * exchangeRateValue
      updateConvertedAmount(amount, convertedValue)
      return
    }
    
    /// Perform the conversion
    let convertedValue = amount * exchangeRateValue
    updateConvertedAmount(amount, convertedValue)
  }
  
  private func updateConvertedAmount(_ fromAmount: Double, _ toAmount: Double) {
    /// Format the converted amount
    convertedAmount = String(format: "%.2f", toAmount)
    
    /// Store the conversion history
    let newHistory = ConversionHistory(
      fromAmount: fromAmount,
      fromCurrency: fromCurrency,
      toAmount: toAmount,
      toCurrency: toCurrency,
      exchangeRate: Double(exchangeRate) ?? 0
    )
    
    /// Append the new history and limit to the last 5 entries
    /// Only add if it's different from the most recent one
    if conversionHistory.isEmpty ||
        conversionHistory[0].fromCurrency != newHistory.fromCurrency ||
        conversionHistory[0].toCurrency != newHistory.toCurrency ||
        abs(conversionHistory[0].fromAmount - newHistory.fromAmount) > 0.001 {
      
      conversionHistory.insert(newHistory, at: 0)
      if conversionHistory.count > 5 {
        conversionHistory.removeLast()
      }
    }
  }
  
  // MARK: - Error Handling
  
  private func handleError(_ error: Error) {
    if let currencyError = error as? CurrencyServiceError {
      errorMessage = currencyError.errorDescription
    } else {
      errorMessage = error.localizedDescription
    }
  }
}
