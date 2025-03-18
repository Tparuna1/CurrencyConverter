//
//  CurrencyConverterViewModel.swift
//  CurrencyConverter
//
//  Created by tornike <parunashvili on 14.03.25.
//

import Foundation
import Combine

class CurrencyConverterViewModel: ObservableObject {
  // MARK: - Published Properties
  
  @Published var fromCurrency: Currency = .euro
  @Published var toCurrency: Currency = .usd
  @Published var inputAmount: String = "1.0" {
    didSet {
      /// Automatically trigger conversion when inputAmount changes
      Task { await convert() }
    }
  }
  @Published var convertedAmount: String = ""
  @Published var errorMessage: String? = nil
  @Published var exchangeRate: String = ""
  
  // MARK: - Private Properties
  
  private let service: CurrencyServiceProtocol
  private var cancellables = Set<AnyCancellable>()
  private var timer: AnyCancellable?
  
  // MARK: - Initializer
  
  init(service: CurrencyServiceProtocol = CurrencyService()) {
    self.service = service
    setupBindings()
    fetchInitialExchangeRate()
  }
  
  // MARK: - Setup Methods
  
  private func setupBindings() {
    /// Bind the input fields (debounced) to trigger conversion
    Publishers.CombineLatest3($inputAmount, $fromCurrency, $toCurrency)
      .debounce(for: .seconds(0.5), scheduler: RunLoop.main)
      .sink { [weak self] _, _, _ in
        Task { await self?.convert() }
      }
      .store(in: &cancellables)
    
    /// Timer for periodic refresh of exchange rate
    timer = Timer.publish(every: 10, on: .main, in: .common)
      .autoconnect()
      .sink { [weak self] _ in
        /// Refresh exchange rate periodically
        Task { await self?.fetchExchangeRate() }
      }
  }
  
  // MARK: - Public Methods
  
  func fetchInitialExchangeRate() {
    Task { await self.fetchExchangeRate() }
  }
  
  func fetchExchangeRate() async {
    do {
      let exchangeRateValue = try await service.fetchExchangeRate(fromAmount: 1.0,
                                                                  fromCurrency: fromCurrency,
                                                                  toCurrency: toCurrency)
      
      exchangeRate = String(format: "%.4f", exchangeRateValue)
    } catch {
      handleError(error)
    }
  }
  
  func convert() async {
    guard let amount = Double(inputAmount) else {
      errorMessage = "Invalid amount"
      return
    }
    
    guard let exchangeRateValue = Double(exchangeRate), exchangeRateValue > 0 else {
      errorMessage = "Invalid exchange rate"
      return
    }
    
    let convertedValue = amount * exchangeRateValue
    
    convertedAmount = String(format: "%.2f", convertedValue)
  }
  
  // MARK: - Error Handling
  
  private func handleError(_ error: Error) {
    guard let error = error as? CurrencyServiceError else { return }
    
    switch error {
    case .invalidURL:
      errorMessage = "Invalid URL"
    case .decodingError(let message):
      errorMessage = message
    case .networkError(let error):
      errorMessage = error.localizedDescription
    case .taskCancelled:
      errorMessage = nil
    }
  }
}
