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

    private lazy var selectorsContainer = ContainerView()
    private lazy var fieldsContainer = ContainerView()
    private lazy var historyContainer = ContainerView()

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
    private lazy var convertButton = ButtonComponent(type: .convert)

    private lazy var exchangeRateLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.textColor = .gray
        label.textAlignment = .center
        return label
    }()

    private lazy var converterStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 24.0
        stack.alignment = .fill
        return stack
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
        setupActions()

        fromCurrencyField.text = viewModel.inputAmount
        toCurrencyField.isUserInteractionEnabled = false
    }

    // MARK: - Private Methods

    private func setupUI() {
        view.backgroundColor = .white
        title = "Currency Converter"

        addSubviews()
        makeConstraints()
    }

    private func addSubviews() {
        let selectorsStackView = UIStackView(arrangedSubviews: [fromCurrencySelector, toCurrencySelector])
        selectorsStackView.axis = .vertical
        selectorsStackView.spacing = 8
        selectorsContainer.addContent(selectorsStackView)

        let fieldsStackView = UIStackView(arrangedSubviews: [fromCurrencyField, toCurrencyField])
        fieldsStackView.axis = .vertical
        fieldsStackView.spacing = 16
        fieldsContainer.addContent(fieldsStackView)

        fieldsContainer.contentView.addSubview(reverseButton)

        converterStackView.addArrangedSubviews([
            selectorsContainer,
            fieldsContainer,
            exchangeRateLabel,
            convertButton
        ])

        historyContainer.addContent(historyStackView)

        view.addSubview(converterStackView)
        view.addSubview(historyContainer)
    }

    private func makeConstraints() {
        converterStackView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(20)
            make.leading.trailing.equalToSuperview().inset(20)
        }

        historyContainer.snp.makeConstraints { make in
            make.top.equalTo(converterStackView.snp.bottom).offset(20)
            make.leading.trailing.equalToSuperview().inset(20)
            make.bottom.lessThanOrEqualTo(view.safeAreaLayoutGuide).inset(20)
        }

        reverseButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalTo(fieldsContainer.contentView)
            make.size.equalTo(50)
        }

        convertButton.snp.makeConstraints { make in
            make.height.equalTo(50)
        }
    }

    private func setupActions() {
        reverseButton.setTapHandler { [weak self] in
            self?.viewModel.swapCurrencies()
        }

        convertButton.setTapHandler { [weak self] in
            Task { [weak self] in
                await self?.viewModel.convert()
            }
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

        viewModel.$conversionHistory
            .dispatchOnMainQueue()
            .sink { [weak self] history in
                self?.updateHistoryView(with: history)
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
