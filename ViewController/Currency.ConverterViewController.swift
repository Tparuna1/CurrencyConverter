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
  
  private var viewModel = CurrencyConverterViewModel()
  private var cancellables = Set<AnyCancellable>()

  private let stackView = UIStackView(axis: .vertical, spacing: 16.0)
  private let resultLabel = UILabel(font: .boldSystemFont(ofSize: 18.0),
                    textColor: .black)
  private let amountTextField: UITextField = {
    let textField = UITextField()
    textField.borderStyle = .roundedRect
    textField.keyboardType = .decimalPad
    return textField
  }()
  
  // MARK: - Lifecycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setupUI()
    setupBindings()
  }
}

// MARK: - Private

private extension CurrencyConverterViewController {
  func setupUI() {
    view.backgroundColor = .white
    
    addSubviews()
    makeConstraints()
  }
  
  func addSubviews() {
    stackView.addArrangedSubviews([amountTextField, resultLabel])
    view.addSubview(stackView)
  }
  
  func makeConstraints() {
      stackView.snp.makeConstraints { make in
          make.centerX.equalToSuperview()
          make.centerY.equalToSuperview()
          make.leading.equalToSuperview().offset(20)
          make.trailing.equalToSuperview().offset(-20)
      }
  }
  
  func setupBindings() {
    amountTextField.textPublisher
      .dispatchOnMainQueue()
      .assign(to: &viewModel.$inputAmount)
    
    viewModel.$convertedAmount
      .dispatchOnMainQueue()
      .sink { [weak self] value in
        self?.resultLabel.text = value
      }
      .store(in: &cancellables)
    
    viewModel.$errorMessage
      .dispatchOnMainQueue()
      .sink { [weak self] message in
        guard let self, let message else { return }
        showError(message)
      }
      .store(in: &cancellables)
    
    amountTextField.textPublisher
      .dispatchOnMainQueue()
      .removeDuplicates()
      .debounce(for: .milliseconds(500), scheduler: RunLoop.main)
      .sink { [weak self] _ in
        Task { await self?.viewModel.convert() }
      }
      .store(in: &cancellables)
  }

  func showError(_ message: String) {
    let alert = UIAlertController(title: String(localized: "alert.error.title"),
                    message: message,
                    preferredStyle: .alert)
    alert.addAction(UIAlertAction(title: String(localized: "alert.button.ok"), style: .default))
    present(alert, animated: true)
  }
}
