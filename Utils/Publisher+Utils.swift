//
//  Publisher+Utils.swift
//  CurrencyConverter
//
//  Created by tornike <parunashvili on 17.03.25.
//

import Combine
import Foundation

extension Publisher {
  func dispatchOnMainQueue() -> AnyPublisher<Output, Failure> {
    receive(on: DispatchQueue.main).eraseToAnyPublisher()
  }
}
