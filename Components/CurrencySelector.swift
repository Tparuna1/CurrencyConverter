//
//  CurrencySelector.swift
//  CurrencyConverter
//
//  Created by tornike <parunashvili on 19.03.25.
//

import UIKit
import Combine

final class CurrencySelector: UIView {
  // MARK: - Properties
  
  private(set) var selectedCurrency: Currency {
    didSet {
      currencyChangeSubject.send(selectedCurrency)
      updateSelectionDisplay()
    }
  }
  
  private let currencies: [Currency]
  private let currencyChangeSubject = PassthroughSubject<Currency, Never>()
  var currencyPublisher: AnyPublisher<Currency, Never> {
    return currencyChangeSubject.eraseToAnyPublisher()
  }
  
  // MARK: - UI Components
  
  private lazy var containerStack: UIStackView = {
    let stack = UIStackView()
    stack.axis = .horizontal
    stack.spacing = 8
    stack.alignment = .center
    stack.isLayoutMarginsRelativeArrangement = true
    stack.layoutMargins = UIEdgeInsets(top: 8, left: 12, bottom: 8, right: 12)
    stack.backgroundColor = UIColor(white: 0.95, alpha: 1.0)
    stack.layer.cornerRadius = 8
    return stack
  }()
  
  private lazy var currencySymbolLabel: UILabel = {
    let label = UILabel()
    label.font = .systemFont(ofSize: 18, weight: .bold)
    label.textColor = .black
    label.textAlignment = .center
    label.setContentHuggingPriority(.defaultHigh, for: .horizontal)
    return label
  }()
  
  private lazy var currencyCodeLabel: UILabel = {
    let label = UILabel()
    label.font = .systemFont(ofSize: 16)
    label.textColor = .darkGray
    label.textAlignment = .left
    return label
  }()
  
  private lazy var arrowImageView: UIImageView = {
    let configuration = UIImage.SymbolConfiguration(pointSize: 14, weight: .medium)
    let image = UIImage(systemName: "chevron.down", withConfiguration: configuration)
    let imageView = UIImageView(image: image)
    imageView.tintColor = .darkGray
    imageView.contentMode = .scaleAspectFit
    imageView.setContentHuggingPriority(.defaultHigh, for: .horizontal)
    return imageView
  }()
  
  // MARK: - Initialization
  
  init(currencies: [Currency], selectedCurrency: Currency) {
    self.currencies = currencies
    self.selectedCurrency = selectedCurrency
    super.init(frame: .zero)
    setupView()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - Setup
  
  private func setupView() {
    addSubview(containerStack)
    
    containerStack.addArrangedSubview(currencySymbolLabel)
    containerStack.addArrangedSubview(currencyCodeLabel)
    containerStack.addArrangedSubview(arrowImageView)
    
    containerStack.snp.makeConstraints { make in
      make.edges.equalToSuperview()
    }
    
    updateSelectionDisplay()
    
    let tapGesture = UITapGestureRecognizer(target: self, action: #selector(showCurrencyPicker))
    containerStack.addGestureRecognizer(tapGesture)
    containerStack.isUserInteractionEnabled = true
  }
  
  private func updateSelectionDisplay() {
    currencySymbolLabel.text = selectedCurrency.symbol
    currencyCodeLabel.text = selectedCurrency.code
  }
  
  // MARK: - Actions
  
  @objc private func showCurrencyPicker() {
    let alertController = UIAlertController(
      title: "Select Currency",
      message: nil,
      preferredStyle: .actionSheet
    )
    
    for currency in currencies {
      let action = UIAlertAction(
        title: "\(currency.symbol) \(currency.code) - \(currency.name)",
        style: .default
      ) { [weak self] _ in
        self?.selectedCurrency = currency
      }
      
      if currency == selectedCurrency {
        /// Add a checkmark to the current selection
        action.setValue(true, forKey: "checked")
      }
      
      alertController.addAction(action)
    }
    
    alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel))
    
    /// Present from the top-most view controller
    if let viewController = findViewController() {
      if UIDevice.current.userInterfaceIdiom == .pad {
        /// For iPad, we need to specify a source view for the popover
        alertController.popoverPresentationController?.sourceView = self
        alertController.popoverPresentationController?.sourceRect = bounds
      }
      viewController.present(alertController, animated: true)
    }
  }
  
  /// Helper to find the view controller that contains this view
  private func findViewController() -> UIViewController? {
    var responder: UIResponder? = self
    while let nextResponder = responder?.next {
      if let viewController = nextResponder as? UIViewController {
        return viewController
      }
      responder = nextResponder
    }
    return nil
  }
}
