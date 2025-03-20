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
  }
  
  // MARK: - Private Methods
  
  private func setupUI() {
    view.backgroundColor = .mainBackground
    title = "Currency Converter"
    
    addSubviews()
    makeConstraints()
  }
  
  private func addSubviews() {
    view.addSubview(converterView)
    view.addSubview(historyView)
  }
  
  private func makeConstraints() {
    converterView.snp.makeConstraints { make in
      make.top.equalTo(view.safeAreaLayoutGuide).offset(20)
      make.leading.trailing.equalToSuperview().inset(20)
    }
    
    historyView.snp.makeConstraints { make in
      make.top.equalTo(converterView.snp.bottom).offset(20)
      make.leading.trailing.equalToSuperview().inset(20)
      make.bottom.lessThanOrEqualTo(view.safeAreaLayoutGuide).inset(20)
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
