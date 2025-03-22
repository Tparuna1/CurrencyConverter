//
//  Currency.Model.swift
//  CurrencyConverter
//
//  Created by tornike <parunashvili on 14.03.25.
//

import Foundation

// MARK: - Models

struct CurrencyExchangeResponse: Decodable {
  let amount: String
  let currency: Currency
}

// MARK: - CurrencyExchangeResponse Extensions

extension CurrencyExchangeResponse {
  var amountAsDouble: Double? {
    return Double(amount)
  }
}
