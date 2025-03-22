//
//  CurrencyFlag.swift
//  CurrencyConverter
//
//  Created by tornike <parunashvili on 22.03.25.
//

import UIKit
import SnapKit

final class CurrencyFlagView: UIView {
  
  // MARK: - UI Components
  
  private lazy var flagImageView: UIImageView = {
    let imageView = UIImageView()
    imageView.contentMode = .scaleAspectFill
    return imageView
  }()
  
  // MARK: - Properties
  
  private var currency: Currency
  
  // MARK: - Initialization
  
  init(currency: Currency, size: CGFloat = Grid.Spacing.xl) {
    self.currency = currency
    super.init(frame: .zero)
    setupUI(size: size)
    updateFlag()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - Lifecycle
  
  override func layoutSubviews() {
    super.layoutSubviews()
    flagImageView.makeCircular()
  }
  
  // MARK: - Public Methods
  
  func updateCurrency(_ currency: Currency) {
    self.currency = currency
    updateFlag()
  }
  
  // MARK: - Private Methods
  
  private func setupUI(size: CGFloat) {
    addSubview(flagImageView)
    
    flagImageView.snp.makeConstraints { make in
      make.edges.equalToSuperview()
      make.width.height.equalTo(size)
    }
  }
  
  private func updateFlag() {
    if let image = currency.flagImage {
      flagImageView.image = image
    } else {
      let size = flagImageView.frame.size.width
      let renderer = UIGraphicsImageRenderer(size: CGSize(width: size, height: size))
      
      let img = renderer.image { ctx in
        let colors: [CGColor]
        switch currency {
        case .euro: colors = [UIColor.blue.cgColor, UIColor(hex: "#003399").cgColor]
        case .usd: colors = [UIColor.red.cgColor, UIColor.blue.cgColor]
        case .gbp: colors = [UIColor.red.cgColor, UIColor.blue.cgColor]
        case .jpy: colors = [UIColor.white.cgColor, UIColor.red.cgColor]
        case .cad: colors = [UIColor.red.cgColor, UIColor.white.cgColor]
        case .aud: colors = [UIColor.blue.cgColor, UIColor.red.cgColor]
        case .chf: colors = [UIColor.red.cgColor, UIColor.white.cgColor]
        case .cny: colors = [UIColor.red.cgColor, UIColor.yellow.cgColor]
        }
        
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = colors
        gradientLayer.frame = CGRect(x: 0, y: 0, width: size, height: size)
        ctx.cgContext.saveGState()
        let path = CGPath(ellipseIn: CGRect(x: 0, y: 0, width: size, height: size), transform: nil)
        ctx.cgContext.addPath(path)
        ctx.cgContext.clip()
        gradientLayer.render(in: ctx.cgContext)
        ctx.cgContext.restoreGState()
        
        let text = currency.code
        let font = UIFont.boldSystemFont(ofSize: size * 0.35)
        let textAttributes: [NSAttributedString.Key: Any] = [
          .font: font,
          .foregroundColor: UIColor.white
        ]
        
        let textSize = text.size(withAttributes: textAttributes)
        let rect = CGRect(x: (size - textSize.width) / 2,
                          y: (size - textSize.height) / 2,
                          width: textSize.width,
                          height: textSize.height)
        
        text.draw(in: rect, withAttributes: textAttributes)
      }
      
      flagImageView.image = img
    }
  }
}
