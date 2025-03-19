//
//  ConvesionHistory.swift
//  CurrencyConverter
//
//  Created by tornike <parunashvili on 18.03.25.
//

import Foundation

// MARK: - ConversionHistory Model

struct ConversionHistory {
  let fromAmount: Double
  let fromCurrency: Currency
  let toAmount: Double
  let toCurrency: Currency
  let exchangeRate: Double
}
