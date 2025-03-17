//
//  Currency.swift
//  CurrencyConverter
//
//  Created by tornike <parunashvili on 17.03.25.
//

import Foundation

enum Currency: String, Decodable {
  case euro = "EUR"
  case usd = "USD"
}

extension Currency {
  var symbol: String {
    switch self {
    case .euro:
      return "€"
    case .usd:
      return "$"
    }
  }
  
  var code: String { rawValue }
}
