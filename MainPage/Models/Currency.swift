//
//  Currency.swift
//  CurrencyConverter
//
//  Created by tornike <parunashvili on 17.03.25.
//

import Foundation
import UIKit

enum Currency: String, Codable, CaseIterable {
  case euro = "EUR"
  case usd = "USD"
  case gbp = "GBP"
  case jpy = "JPY"
  case cad = "CAD"
  case aud = "AUD"
  case chf = "CHF"
  case cny = "CNY"
  
  var symbol: String {
    switch self {
    case .euro: return "€"
    case .usd: return "$"
    case .gbp: return "£"
    case .jpy: return "¥"
    case .cad: return "C$"
    case .aud: return "A$"
    case .chf: return "Fr"
    case .cny: return "¥"
    }
  }
  
  var flagImage: UIImage? {
    switch self {
    case .euro: return .iconEUR
    case .usd: return .iconUSD
    case .gbp: return .iconGBP
    case .jpy: return .iconJPY
    case .cad: return .iconCAD
    case .aud: return .iconAUD
    case .chf: return .iconCHF
    case .cny: return .iconCNY
    }
  }
  
  var name: String {
    switch self {
    case .euro: return "Euro"
    case .usd: return "US Dollar"
    case .gbp: return "British Pound"
    case .jpy: return "Japanese Yen"
    case .cad: return "Canadian Dollar"
    case .aud: return "Australian Dollar"
    case .chf: return "Swiss Franc"
    case .cny: return "Chinese Yuan"
    }
  }
  
  var code: String { rawValue }
}
