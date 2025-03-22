//
//  CurrencySelector.swift
//  CurrencyConverter
//
//  Created by tornike <parunashvili on 17.03.25.
//

import UIKit
import Combine

final class CurrencySelector: UIView {
  
  // MARK: - Properties
  
  private let currencies: [Currency]
  private var selectedCurrency: Currency
  private let currencySubject = PassthroughSubject<Currency, Never>()
  
  var currencyPublisher: AnyPublisher<Currency, Never> {
    return currencySubject.eraseToAnyPublisher()
  }
  
  // MARK: - UI Components
  
  private lazy var containerView: UIView = {
    let view = UIView()
    view.backgroundColor = .clear
    return view
  }()
  
  private lazy var flagView: CurrencyFlagView = {
    return CurrencyFlagView(currency: selectedCurrency, size: Grid.Spacing.xl)
  }()
  
  private lazy var currencyLabel: UILabel = {
    let label = UILabel()
    label.font = .systemFont(ofSize: Grid.FontSize.regular)
    label.textColor = .white
    label.textAlignment = .left
    return label
  }()
  
  private lazy var codeLabel: UILabel = {
    let label = UILabel()
    label.font = .systemFont(ofSize: Grid.FontSize.small)
    label.textColor = .lightGray
    label.textAlignment = .right
    return label
  }()
  
  private lazy var arrowImageView: UIImageView = {
    let imageView = UIImageView(image: UIImage.chevronDown)
    imageView.tintColor = .white
    imageView.contentMode = .scaleAspectFit
    return imageView
  }()
  
  private lazy var spacerView: UIView = {
    let view = UIView()
    return view
  }()
  
  // MARK: - Stack Views
  
  private lazy var centerStack: UIStackView = {
    let stack = UIStackView(arrangedSubviews: [currencyLabel, codeLabel])
    stack.axis = .vertical
    stack.spacing = Grid.Spacing.xs2
    stack.alignment = .leading
    return stack
  }()
  
  private lazy var horizontalStack: UIStackView = {
    let stack = UIStackView()
    stack.axis = .horizontal
    stack.spacing = Grid.Spacing.m
    stack.alignment = .center
    stack.addArrangedSubview(flagView)
    stack.addArrangedSubview(centerStack)
    stack.addArrangedSubview(spacerView)
    stack.addArrangedSubview(arrowImageView)
    return stack
  }()
  
  // MARK: - Initialization
  
  init(currencies: [Currency], selectedCurrency: Currency) {
    self.currencies = currencies
    self.selectedCurrency = selectedCurrency
    super.init(frame: .zero)
    setupUI()
    updateLabels()
    setupActions()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - Private Methods
  
  private func setupUI() {
    addSubview(horizontalStack)
    
    horizontalStack.snp.makeConstraints { make in
      make.edges.equalToSuperview().inset(Grid.Spacing.m)
    }
    
    spacerView.snp.makeConstraints { make in
      make.width.greaterThanOrEqualTo(Grid.Spacing.m)
    }
    
    arrowImageView.snp.makeConstraints { make in
      make.width.height.equalTo(Grid.Size.m)
    }
  }
  
  private func updateLabels() {
    flagView.updateCurrency(selectedCurrency)
    currencyLabel.text = selectedCurrency.name
    codeLabel.text = selectedCurrency.code
  }
  
  private func setupActions() {
    let tapGesture = UITapGestureRecognizer(target: self, action: #selector(showCurrencyPicker))
    addGestureRecognizer(tapGesture)
  }
  
  @objc private func showCurrencyPicker() {
    let alertController = UIAlertController(title: "Select Currency", message: nil, preferredStyle: .actionSheet)
    
    for currency in currencies {
      let action = UIAlertAction(title: "\(currency.name) (\(currency.code))", style: .default) { [weak self] _ in
        self?.selectedCurrency = currency
        self?.updateLabels()
        self?.currencySubject.send(currency)
      }
      alertController.addAction(action)
    }
    
    let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
    alertController.addAction(cancelAction)
    
    /// Configure popover for iPad
    if let popoverController = alertController.popoverPresentationController {
      popoverController.sourceView = self
      popoverController.sourceRect = bounds
    }
    
    /// Find the view controller to present the alert
    if let viewController = findViewController() {
      viewController.present(alertController, animated: true)
    }
  }
  
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
