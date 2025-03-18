//
//  CurrencyConverterViewController.swift
//  CurrencyConverter
//
//  Created by tornike <parunashvili on 14.03.25.
//

import Combine
import UIKit
import SnapKit

final class CurrencyConverterViewController: UIViewController {
  
  // MARK: - Properties
  
  private var viewModel = CurrencyConverterViewModel()
  private var cancellables = Set<AnyCancellable>()
  
  // MARK: - UI Components
  
  private let stackView = UIStackView(axis: .vertical, spacing: 16.0)
  private let fromCurrencyLabel = UILabel(font: .systemFont(ofSize: 16.0), textColor: .black)
  private let toCurrencyLabel = UILabel(font: .systemFont(ofSize: 16.0), textColor: .black)
  
  private let amountTextField: UITextField = {
    let textField = UITextField()
    textField.borderStyle = .roundedRect
    textField.keyboardType = .decimalPad
    textField.textAlignment = .left
    return textField
  }()
  
  private let convertedAmountTextField: UITextField = {
    let textField = UITextField()
    textField.borderStyle = .roundedRect
    textField.keyboardType = .decimalPad
    textField.isUserInteractionEnabled = false
    textField.textAlignment = .right
    return textField
  }()
  
  private let exchangeRateLabel = UILabel(font: .systemFont(ofSize: 16.0), textColor: .gray)
  
  // MARK: - Lifecycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setupUI()
    setupBindings()
    
    amountTextField.text = viewModel.inputAmount
  }
  
  // MARK: - Private Methods
  
  private func setupUI() {
    view.backgroundColor = .white
    
    addSubviews()
    makeConstraints()
  }
  
  private func addSubviews() {
    stackView.addArrangedSubviews([fromCurrencyLabel, amountTextField, exchangeRateLabel, toCurrencyLabel, convertedAmountTextField])
    view.addSubview(stackView)
  }
  
  private func makeConstraints() {
    stackView.snp.remakeConstraints { make in
      make.centerX.equalToSuperview()
      make.centerY.equalToSuperview()
      make.leading.equalToSuperview().offset(20)
      make.trailing.equalToSuperview().offset(-20)
    }
    
    amountTextField.snp.makeConstraints { make in
      make.width.equalTo(100)
    }
    
    convertedAmountTextField.snp.makeConstraints { make in
      make.width.equalTo(100)
    }
    
    exchangeRateLabel.snp.makeConstraints { make in
      make.width.equalTo(100)
    }
    
    fromCurrencyLabel.snp.makeConstraints { make in
      make.width.equalTo(60)
    }
    toCurrencyLabel.snp.makeConstraints { make in
      make.width.equalTo(60)
    }
  }
  
  // MARK: - Binding Methods
  
  private func setupBindings() {
    /// Bind the amount text field to the ViewModel's input amount
    amountTextField.textPublisher
      .dispatchOnMainQueue()
      .sink { [weak self] text in
        self?.viewModel.inputAmount = text
      }
      .store(in: &cancellables)
    
    /// Bind the converted amount to the UI
    viewModel.$convertedAmount
      .dispatchOnMainQueue()
      .sink { [weak self] value in
        self?.convertedAmountTextField.text = value
      }
      .store(in: &cancellables)
    
    /// Handle error messages and display them to the user
    viewModel.$errorMessage
      .dispatchOnMainQueue()
      .sink { [weak self] message in
        guard let self, let message else { return }
        showError(message)
      }
      .store(in: &cancellables)
    
    /// Bind the exchange rate to the UI
    viewModel.$exchangeRate
      .dispatchOnMainQueue()
      .sink { [weak self] rate in
        self?.exchangeRateLabel.text = "Rate: \(rate)"
      }
      .store(in: &cancellables)
    
    /// Bind the currencies to the labels
    viewModel.$fromCurrency
      .dispatchOnMainQueue()
      .sink { [weak self] currency in
        self?.fromCurrencyLabel.text = currency.symbol
      }
      .store(in: &cancellables)
    
    viewModel.$toCurrency
      .dispatchOnMainQueue()
      .sink { [weak self] currency in
        self?.toCurrencyLabel.text = currency.symbol
      }
      .store(in: &cancellables)
    
    /// Debounce amount field input and trigger conversion
    amountTextField.textPublisher
      .dispatchOnMainQueue()
      .removeDuplicates()
      .debounce(for: .milliseconds(500), scheduler: RunLoop.main)
      .sink { [weak self] _ in
        Task { await self?.viewModel.convert() }
      }
      .store(in: &cancellables)
  }
  
  // MARK: - Error Handling
  
  private func showError(_ message: String) {
    let alert = UIAlertController(title: String(localized: "alert.error.title"),
                    message: message,
                    preferredStyle: .alert)
    alert.addAction(UIAlertAction(title: String(localized: "alert.button.ok"), style: .default))
    present(alert, animated: true)
  }
}
