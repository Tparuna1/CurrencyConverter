//
//  UIImageView.Extension.swift
//  CurrencyConverter
//
//  Created by tornike <parunashvili on 22.03.25.
//

import UIKit

extension UIImageView {
    func makeCircular() {
        self.layer.cornerRadius = self.frame.size.width / 2
        self.clipsToBounds = true
        self.layer.borderWidth = 1.0
        self.layer.borderColor = UIColor.lightGray.cgColor
    }
}
