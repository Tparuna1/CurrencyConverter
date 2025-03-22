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
  
  private lazy var converterView = ConverterView(viewModel: viewModel)
  private lazy var historyView = HistoryView()
  
  // MARK: - Lifecycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setupUI()
    setupBindings()
    setupKeyboardDismissal()
  }
  
  // MARK: - Private Methods
  
  private func setupUI() {
    view.backgroundColor = .mainBackground
    title = "Currency Converter"
    
    addSubviews()
    makeConstraints()
  }
  
  private func setupKeyboardDismissal() {
    let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
    tapGesture.cancelsTouchesInView = false
    view.addGestureRecognizer(tapGesture)
  }
  
  @objc private func dismissKeyboard() {
    view.endEditing(true)
  }
  
  private func addSubviews() {
    view.addSubview(converterView)
    view.addSubview(historyView)
  }
  
  private func makeConstraints() {
    converterView.snp.makeConstraints { make in
      make.top.equalTo(view.safeAreaLayoutGuide).offset(Grid.Spacing.l)
      make.leading.trailing.equalToSuperview().inset(Grid.Spacing.l)
    }
    
    historyView.snp.makeConstraints { make in
      make.top.equalTo(converterView.snp.bottom).offset(Grid.Spacing.l)
      make.leading.trailing.equalToSuperview().inset(Grid.Spacing.l)
      make.height.equalTo(Grid.Height.container)
      make.bottom.lessThanOrEqualTo(view.safeAreaLayoutGuide).inset(Grid.Spacing.l)
    }
  }
  
  // MARK: - Binding Methods
  
  private func setupBindings() {
    /// Handle error messages and display them to the user
    viewModel.$errorMessage
      .dispatchOnMainQueue()
      .sink { [weak self] message in
        guard let self, let message else { return }
        showError(message)
      }
      .store(in: &cancellables)
    
    /// Update history view when conversion history changes
    viewModel.$conversionHistory
      .dispatchOnMainQueue()
      .sink { [weak self] history in
        self?.historyView.updateHistory(with: history)
      }
      .store(in: &cancellables)
  }
  
  // MARK: - Error Handling
  
  private func showError(_ message: String) {
    let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
    alert.addAction(UIAlertAction(title: "OK", style: .default))
    present(alert, animated: true)
  }
}
