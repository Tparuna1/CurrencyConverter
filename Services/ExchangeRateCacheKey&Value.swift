//
//  ExchangeRateCacheKey.swift
//  CurrencyConverter
//
//  Created by tornike <parunashvili on 22.03.25.
//

import Foundation

// MARK: - Cache Key

struct ExchangeRateCacheKey: Hashable {
  let fromCurrency: Currency
  let toCurrency: Currency
  let amount: Double
  
  func hash(into hasher: inout Hasher) {
    hasher.combine(fromCurrency.rawValue)
    hasher.combine(toCurrency.rawValue)
    hasher.combine(amount)
  }
}

// MARK: - Cache Value

struct ExchangeRateCacheValue {
  let rate: Double
  let timestamp: Date
}
