//
//  HistoryView.swift
//  CurrencyConverter
//
//  Created by tornike <parunashvili on 20.03.25.
//

import UIKit
import SnapKit

final class HistoryView: UIView {
  
  // MARK: - Properties
  
  private var history: [ConversionHistory] = []
  
  // MARK: - UI Components
  
  private lazy var containerView = ContainerView()
  
  private lazy var scrollView: UIScrollView = {
    let scrollView = UIScrollView()
    scrollView.showsVerticalScrollIndicator = true
    scrollView.alwaysBounceVertical = true
    return scrollView
  }()
  
  private lazy var contentView: UIView = {
    let view = UIView()
    return view
  }()
  
  private lazy var historyStackView: UIStackView = {
    let stack = UIStackView()
    stack.axis = .vertical
    stack.spacing = Grid.Spacing.xs
    stack.alignment = .fill
    stack.distribution = .fill
    return stack
  }()
  
  private lazy var titleLabel: UILabel = {
    let label = UILabel()
    label.text = "Last 5 Conversions"
    label.font = .boldSystemFont(ofSize: Grid.FontSize.large)
    label.textColor = .white
    return label
  }()
  
  // MARK: - Initialization
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    setupUI()
  }
  
  required init?(coder: NSCoder) {
    super.init(coder: coder)
    setupUI()
  }
  
  // MARK: - Private Methods
  
  private func setupUI() {
    containerView.addSubview(scrollView)
    scrollView.addSubview(contentView)
    contentView.addSubview(historyStackView)
    historyStackView.addArrangedSubview(titleLabel)
    addSubview(containerView)
    setupConstraints()
  }
  
  private func setupConstraints() {
    containerView.snp.makeConstraints { make in
      make.edges.equalToSuperview()
    }
    
    scrollView.snp.makeConstraints { make in
      make.edges.equalToSuperview().inset(Grid.Spacing.m)
    }
    
    contentView.snp.makeConstraints { make in
      make.edges.equalToSuperview()
      make.width.equalToSuperview()
      make.height.greaterThanOrEqualTo(0)
    }
    
    historyStackView.snp.makeConstraints { make in
      make.top.leading.trailing.equalToSuperview()
      make.bottom.lessThanOrEqualToSuperview()
      make.width.equalToSuperview()
    }
  }
  
  // MARK: - Public Methods
  
  func updateHistory(with history: [ConversionHistory]) {
    self.history = history
    
    historyStackView.arrangedSubviews.forEach { view in
      if view != titleLabel {
        view.removeFromSuperview()
      }
    }
    
    if history.isEmpty {
      let emptyLabel = UILabel()
      emptyLabel.text = "No conversions yet"
      emptyLabel.font = .systemFont(ofSize: Grid.FontSize.regular)
      emptyLabel.textColor = .white
      emptyLabel.textAlignment = .center
      historyStackView.addArrangedSubview(emptyLabel)
    } else {
      history.forEach { conversion in
        let historyCell = HistoryCell(conversion: conversion)
        historyStackView.addArrangedSubview(historyCell)
      }
    }
    
    setNeedsLayout()
    layoutIfNeeded()
  }
}
