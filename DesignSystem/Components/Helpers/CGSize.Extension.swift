//
//  CGSize.Extension.swift
//  CurrencyConverter
//
//  Created by tornike <parunashvili on 20.03.25.
//

import UIKit

public extension CGSize {
    init(squareSide: CGFloat) {
        self.init(width: squareSide, height: squareSide)
    }
}
