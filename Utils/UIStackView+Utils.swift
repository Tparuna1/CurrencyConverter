//
//  UIStackView+Utils.swift
//  CurrencyConverter
//
//  Created by tornike <parunashvili on 17.03.25.
//

import UIKit

extension UIStackView {
  convenience init(
    arrangedSubviews: [UIView] = [],
    axis: NSLayoutConstraint.Axis,
    distribution: UIStackView.Distribution = .fill,
    alignment: UIStackView.Alignment = .fill,
    spacing: CGFloat = .zero
  ) {
    self.init()
    self.axis = axis
    self.distribution = distribution
    self.alignment = alignment
    self.spacing = spacing
    addArrangedSubviews(arrangedSubviews)
  }
  
  func addArrangedSubviews(_ views: [UIView]) {
    views.forEach { addArrangedSubview($0) }
  }
  
  func addArrangedSubviews(_ views: UIView...) {
    views.forEach { addArrangedSubview($0) }
  }
}
