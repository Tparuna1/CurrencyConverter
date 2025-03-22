//
//  HistoryCell.swift
//  CurrencyConverter
//
//  Created by tornike <parunashvili on 22.03.25.
//

import UIKit
import SnapKit

final class HistoryCell: UIView {
  
  // MARK: - UI Components
  
  private lazy var containerView: UIView = {
    let view = UIView()
    view.backgroundColor = UIColor.white.withAlphaComponent(Grid.Opacity.thin)
    view.layer.cornerRadius = Grid.CornerRadius.small
    return view
  }()
  
  private lazy var fromFlagView = CurrencyFlagView(currency: .usd, size: Grid.Spacing.xl2)
  private lazy var toFlagView = CurrencyFlagView(currency: .euro, size: Grid.Spacing.xl2)
  
  private lazy var fromAmountLabel: UILabel = {
    let label = UILabel()
    label.font = .systemFont(ofSize: Grid.FontSize.regular)
    label.textColor = .white
    return label
  }()
  
  private lazy var toAmountLabel: UILabel = {
    let label = UILabel()
    label.font = .systemFont(ofSize: Grid.FontSize.regular)
    label.textColor = .white
    return label
  }()
  
  private lazy var arrowImageView: UIImageView = {
    let imageView = UIImageView(image: UIImage.arrowRight)
    imageView.tintColor = .white
    imageView.contentMode = .scaleAspectFit
    return imageView
  }()
  
  // MARK: - Stack Components
  
  private lazy var fromStack: UIStackView = {
    let stack = UIStackView(arrangedSubviews: [fromFlagView, fromAmountLabel])
    stack.axis = .horizontal
    stack.spacing = Grid.Spacing.xs
    stack.alignment = .center
    return stack
  }()
  
  private lazy var toStack: UIStackView = {
    let stack = UIStackView(arrangedSubviews: [toFlagView, toAmountLabel])
    stack.axis = .horizontal
    stack.spacing = Grid.Spacing.xs
    stack.alignment = .center
    return stack
  }()
  
  private lazy var mainStack: UIStackView = {
    let stack = UIStackView(arrangedSubviews: [fromStack, arrowImageView, toStack])
    stack.axis = .horizontal
    stack.spacing = Grid.Spacing.m
    stack.alignment = .center
    stack.distribution = .equalSpacing
    return stack
  }()
  
  // MARK: - Initialization
  
  init(conversion: ConversionHistory) {
    super.init(frame: .zero)
    setupUI()
    configure(with: conversion)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - Setup Methods
  
  private func setupUI() {
    addSubview(containerView)
    
    containerView.snp.makeConstraints { make in
      make.edges.equalToSuperview().inset(Grid.Spacing.xs)
    }
    
    containerView.addSubview(mainStack)
    
    mainStack.snp.makeConstraints { make in
      make.edges.equalToSuperview().inset(Grid.Spacing.m)
    }
    
    arrowImageView.snp.makeConstraints { make in
      make.width.height.equalTo(Grid.Size.m)
    }
  }
  
  // MARK: - Configuration
  
  func configure(with conversion: ConversionHistory) {
    fromFlagView.updateCurrency(conversion.fromCurrency)
    toFlagView.updateCurrency(conversion.toCurrency)
    
    fromAmountLabel.text = String(format: "%.2f %@", conversion.fromAmount, conversion.fromCurrency.symbol)
    toAmountLabel.text = String(format: "%.2f %@", conversion.toAmount, conversion.toCurrency.symbol)
  }
}
