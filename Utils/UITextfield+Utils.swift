//
//  UITextfield+Utils.swift
//  CurrencyConverter
//
//  Created by tornike <parunashvili on 17.03.25.
//

import Combine
import UIKit

extension UITextField {
  var textPublisher: AnyPublisher<String, Never> {
    NotificationCenter.default.publisher(for: UITextField.textDidChangeNotification, object: self)
      .compactMap { ($0.object as? UITextField)?.text }
      .eraseToAnyPublisher()
  }
}
