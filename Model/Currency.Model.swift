//
//  Currency.Model.swift
//  CurrencyConverter
//
//  Created by tornike <parunashvili on 14.03.25.
//

import Foundation

extension CurrencyExchangeResponse {
    var amountAsDouble: Double? {
        return Double(amount)
    }
}
