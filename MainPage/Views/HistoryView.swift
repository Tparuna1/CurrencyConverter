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
  
  private lazy var historyStackView: UIStackView = {
    let stack = UIStackView()
    stack.axis = .vertical
    stack.spacing = 8.0
    return stack
  }()
  
  private lazy var titleLabel: UILabel = {
    let label = UILabel()
    label.text = "Last 5 Conversions"
    label.font = .boldSystemFont(ofSize: 16)
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
    containerView.addContent(historyStackView)
    historyStackView.addArrangedSubview(titleLabel)
    
    addSubview(containerView)
    
    containerView.snp.makeConstraints { make in
      make.edges.equalToSuperview()
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
    
    history.forEach { conversion in
      let historyLabel = UILabel()
      historyLabel.text = "\(conversion.fromAmount) \(conversion.fromCurrency.symbol) = \(conversion.toAmount) \(conversion.toCurrency.symbol)"
      historyLabel.font = .systemFont(ofSize: 14)
      historyLabel.textColor = .white
      historyStackView.addArrangedSubview(historyLabel)
    }
  }
}
