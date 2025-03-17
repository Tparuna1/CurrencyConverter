//
//  CurrencyConverter.ViewModel.swift
//  CurrencyConverter
//
//  Created by tornike <parunashvili on 14.03.25.
//

import Foundation
import Combine

// MARK: - ViewModel
class CurrencyConverterViewModel: ObservableObject {
  @Published var fromCurrency: Currency = .euro
  @Published var toCurrency: Currency = .usd
    @Published var inputAmount: String = "1.0"
    @Published var convertedAmount: String = ""
    @Published var errorMessage: String? = nil
    
    private let service: CurrencyServiceProtocol
    private var cancellables = Set<AnyCancellable>()
    private var timer: AnyCancellable?
    
    init(service: CurrencyServiceProtocol = CurrencyService()) {
        self.service = service
        setupBindings()
    }
    
    private func setupBindings() {
        Publishers.CombineLatest3($inputAmount, $fromCurrency, $toCurrency)
            .debounce(for: .seconds(0.5), scheduler: RunLoop.main)
            .sink { [weak self] _, _, _ in
                Task { await self?.convert() }
            }
            .store(in: &cancellables)
        
        timer = Timer.publish(every: 10, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                // TODO: refresh rate every 10 seconds and display it on UI
            }
    }
    
    func convert() async {
        guard let amount = Double(inputAmount) else {
            errorMessage = "Invalid amount"
            return
        }
        
        do {
            let exchangeRate = try await service.fetchExchangeRate(fromAmount: amount,
                                   fromCurrency: fromCurrency,
                                   toCurrency: toCurrency)
            convertedAmount = String(format: "%.2f", exchangeRate)
    } catch {
      guard
        let error = error as? CurrencyServiceError
      else { return }
      
      // TODO: localize error messages
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
}
