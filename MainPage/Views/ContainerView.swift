//
//  ContainerView.swift
//  CurrencyConverter
//
//  Created by tornike <parunashvili on 19.03.25.
//

import UIKit
import SnapKit

final class ContainerView: UIView {
  
  // MARK: - UI Components
  
  lazy var contentView: UIView = {
    let view = UIView()
    view.backgroundColor = UIColor.clear
    view.layer.cornerRadius = Grid.CornerRadius.medium
    view.layer.shadowColor = UIColor.lightGray.cgColor
    view.layer.shadowOpacity = Float(Grid.Opacity.thin)
    view.layer.shadowOffset = CGSize(width: Grid.Spacing.xs3,
                                     height: Grid.Spacing.xs2)
    view.layer.borderWidth = Grid.BorderWidth.thin
    view.layer.borderColor = UIColor.navyBlue.cgColor
    view.layer.shadowRadius = Grid.Spacing.xs2
    return view
  }()
  
  private let gradientLayer = CAGradientLayer()
  
  // MARK: - Init
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    setupUI()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - Public Methods
  
  func addContent(_ view: UIView) {
    contentView.addSubview(view)
    view.snp.makeConstraints { make in
      make.edges.equalToSuperview().inset(Grid.Spacing.m)
    }
  }
  
  // MARK: - Private Methods
  
  private func setupUI() {
    addSubview(contentView)
    contentView.snp.makeConstraints { make in
      make.edges.equalToSuperview()
    }
    
    applyGradient()
  }
  
  private func applyGradient() {
    gradientLayer.colors = [
      UIColor(hex: "#5297F7").withAlphaComponent(0.6).cgColor,
      UIColor(hex: "#000093").withAlphaComponent(0.6).cgColor
    ]
    gradientLayer.startPoint = CGPoint(x: 0, y: 0)
    gradientLayer.endPoint = CGPoint(x: Grid.Spacing.xs4, y: Grid.Spacing.xs4)
    gradientLayer.cornerRadius = Grid.CornerRadius.medium
    contentView.layer.insertSublayer(gradientLayer, at: 0)
  }
  
  override func layoutSubviews() {
    super.layoutSubviews()
    gradientLayer.frame = contentView.bounds
  }
}
