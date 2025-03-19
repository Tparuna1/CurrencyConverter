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
    
    private lazy var stackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 16.0
        return stack
    }()
    
    private lazy var fromCurrencyLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16.0)
        label.textColor = .black
        return label
    }()
    
    private lazy var toCurrencyLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16.0)
        label.textColor = .black
        return label
    }()
    
    private lazy var amountTextField: UITextField = {
        let textField = UITextField()
        textField.borderStyle = .roundedRect
        textField.keyboardType = .decimalPad
        textField.textAlignment = .left
        return textField
    }()
    
    private lazy var convertedAmountTextField: UITextField = {
        let textField = UITextField()
        textField.borderStyle = .roundedRect
        textField.keyboardType = .decimalPad
        textField.isUserInteractionEnabled = false
        textField.textAlignment = .right
        return textField
    }()
    
    private lazy var exchangeRateLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16.0)
        label.textColor = .gray
        return label
    }()
    
    private lazy var historyContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.systemGray6
        view.layer.cornerRadius = 12
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.1
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        view.layer.shadowRadius = 4
        return view
    }()
    
    private lazy var historyStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 8.0
        return stack
    }()
    
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
        
        historyContainerView.addSubview(historyStackView)
        view.addSubview(historyContainerView)
    }
    
    private func makeConstraints() {
        stackView.snp.remakeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(20)
        }
        
        historyContainerView.snp.makeConstraints { make in
            make.top.equalTo(stackView.snp.bottom).offset(20)
            make.leading.trailing.equalToSuperview().inset(20)
        }
        
        historyStackView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(12)
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
        
        viewModel.$conversionHistory
            .dispatchOnMainQueue()
            .sink { [weak self] history in
                self?.updateHistoryView(with: history)
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Update History View
    
    private func updateHistoryView(with history: [ConversionHistory]) {
        historyStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        let titleLabel = UILabel()
        titleLabel.text = "Last 5 Conversions"
        titleLabel.font = .boldSystemFont(ofSize: 16)
        titleLabel.textColor = .black
        historyStackView.addArrangedSubview(titleLabel)
        
        history.forEach { conversion in
            let historyLabel = UILabel()
            historyLabel.text = "\(conversion.fromAmount) \(conversion.fromCurrency.symbol) = \(conversion.toAmount) \(conversion.toCurrency.symbol)"
            historyLabel.font = .systemFont(ofSize: 14)
            historyLabel.textColor = .black
            historyStackView.addArrangedSubview(historyLabel)
        }
    }
    
    // MARK: - Error Handling
    
    private func showError(_ message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
