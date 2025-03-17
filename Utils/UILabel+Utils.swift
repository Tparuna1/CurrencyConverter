//
//  UILabel+Utils.swift
//  CurrencyConverter
//
//  Created by tornike <parunashvili on 17.03.25.
//

import UIKit

extension UILabel {
  convenience init(
    text: String? = nil,
    font: UIFont,
    textColor: UIColor,
    textAlignment: NSTextAlignment = .left,
    numberOfLines: Int = 1
  ) {
    self.init()
    self.font = font
    self.textColor = textColor
    self.textAlignment = textAlignment
    self.numberOfLines = numberOfLines
    self.text = text
  }
}
