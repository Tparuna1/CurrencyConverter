//
//  ConverterView.swift
//  CurrencyConverter
//
//  Created by tornike <parunashvili on 20.03.25.
//

import UIKit
import Combine
import SnapKit

final class ConverterView: UIView {
  
  // MARK: - Properties
  
  private var cancellables = Set<AnyCancellable>()
  private var viewModel: CurrencyConverterViewModel
  
  // MARK: - UI Components
  
  private lazy var selectorsContainer = ContainerView()
  private lazy var fieldsContainer = ContainerView()
  
  private lazy var fromCurrencySelector: CurrencySelector = {
    let selector = CurrencySelector(currencies: Currency.allCases, selectedCurrency: viewModel.fromCurrency)
    return selector
  }()
  
  private lazy var toCurrencySelector: CurrencySelector = {
    let selector = CurrencySelector(currencies: Currency.allCases, selectedCurrency: viewModel.toCurrency)
    return selector
  }()
  
  private lazy var fromCurrencyField = CurrencyTextField(type: .sell)
  private lazy var toCurrencyField = CurrencyTextField(type: .buy)
  
  private lazy var reverseButton = ButtonComponent(type: .reverse)
  
  private lazy var exchangeRateLabel: UILabel = {
    let label = UILabel()
    label.font = .systemFont(ofSize: Grid.FontSize.regular)
    label.textColor = .gray
    label.textAlignment = .center
    return label
  }()
  
  private lazy var converterStackView: UIStackView = {
    let stack = UIStackView()
    stack.axis = .vertical
    stack.spacing = Grid.Spacing.xl
    stack.alignment = .fill
    return stack
  }()
  
  // MARK: - Initialization
  
  init(viewModel: CurrencyConverterViewModel) {
    self.viewModel = viewModel
    super.init(frame: .zero)
    setupUI()
    setupBindings()
    setupActions()
    
    fromCurrencyField.text = viewModel.inputAmount
    toCurrencyField.isUserInteractionEnabled = false
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - Private Methods
  
  private func setupUI() {
    addSubviews()
    makeConstraints()
  }
  
  private func addSubviews() {
    let selectorsStackView = UIStackView(arrangedSubviews: [fromCurrencySelector, toCurrencySelector])
    selectorsStackView.axis = .vertical
    selectorsStackView.spacing = Grid.Spacing.xs
    selectorsContainer.addContent(selectorsStackView)
    
    let fieldsStackView = UIStackView(arrangedSubviews: [fromCurrencyField, toCurrencyField])
    fieldsStackView.axis = .vertical
    fieldsStackView.spacing = Grid.Spacing.m
    fieldsContainer.addContent(fieldsStackView)
    
    fieldsContainer.contentView.addSubview(reverseButton)
    
    converterStackView.addArrangedSubviews([
      selectorsContainer,
      fieldsContainer,
      exchangeRateLabel,
    ])
    
    addSubview(converterStackView)
  }
  
  private func makeConstraints() {
    converterStackView.snp.makeConstraints { make in
      make.edges.equalToSuperview()
    }
    
    reverseButton.snp.makeConstraints { make in
      make.centerX.equalToSuperview()
      make.centerY.equalTo(fieldsContainer.contentView)
      make.size.equalTo(Grid.Size.xl4)
    }
  }
  
  private func setupActions() {
    reverseButton.setTapHandler { [weak self] in
      self?.viewModel.swapCurrencies()
    }
  }
  
  // MARK: - Binding Methods
  
  private func setupBindings() {
    /// Bind the amount text field to the ViewModel's input amount
    fromCurrencyField.textPublisher
      .dispatchOnMainQueue()
      .sink { [weak self] text in
        self?.viewModel.inputAmount = text
      }
      .store(in: &cancellables)
    
    /// Bind the converted amount to the UI
    viewModel.$convertedAmount
      .dispatchOnMainQueue()
      .sink { [weak self] value in
        self?.toCurrencyField.text = value
      }
      .store(in: &cancellables)
    
    /// Bind the exchange rate to the UI
    viewModel.$exchangeRate
      .dispatchOnMainQueue()
      .sink { [weak self] rate in
        self?.exchangeRateLabel.text = "Exchange Rate: \(rate)"
      }
      .store(in: &cancellables)
    
    /// Bind the currencies to the labels
    viewModel.$fromCurrency
      .dispatchOnMainQueue()
      .sink { [weak self] currency in
        self?.fromCurrencyField.updateCurrencySymbol(currency.symbol)
      }
      .store(in: &cancellables)
    
    viewModel.$toCurrency
      .dispatchOnMainQueue()
      .sink { [weak self] currency in
        self?.toCurrencyField.updateCurrencySymbol(currency.symbol)
      }
      .store(in: &cancellables)
    
    fromCurrencySelector.currencyPublisher
      .sink { [weak self] currency in
        self?.viewModel.fromCurrency = currency
      }
      .store(in: &cancellables)
    
    toCurrencySelector.currencyPublisher
      .sink { [weak self] currency in
        self?.viewModel.toCurrency = currency
      }
      .store(in: &cancellables)
  }
}
