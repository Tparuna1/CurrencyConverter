//
//  CurrencyTextField.swift
//  CurrencyConverter
//
//  Created by tornike <parunashvili on 19.03.25.
//

import UIKit
import Combine

final class CurrencyTextField: UIView {
    
    // MARK: - Properties
    
    var textPublisher: AnyPublisher<String, Never> {
        textField.textPublisher
    }
    
    var text: String? {
        get { textField.text }
        set { textField.text = newValue }
    }
    
    override var isUserInteractionEnabled: Bool {
        get { textField.isUserInteractionEnabled }
        set { textField.isUserInteractionEnabled = newValue }
    }
    
    private let type: FieldType
    private var currencySymbol: String = "€"
    
    // MARK: - UI Components
    
    private lazy var containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBackground
        view.layer.borderColor = UIColor.systemGray4.cgColor
        view.layer.borderWidth = 1.0
        view.layer.cornerRadius = 8.0
        return view
    }()
    
    private lazy var textField: UITextField = {
        let field = UITextField()
        field.borderStyle = .none
        field.keyboardType = .decimalPad
        field.textAlignment = .left
        field.font = .systemFont(ofSize: 16)
        return field
    }()
    
    private lazy var currencyLabel: UILabel = {
        let label = UILabel(
            font: .systemFont(ofSize: 16, weight: .semibold),
            textColor: .black
        )
        label.textAlignment = .center
        label.setContentHuggingPriority(.required, for: .horizontal)
        return label
    }()
    
    // MARK: - Initialization
    
    init(type: FieldType) {
        self.type = type
        super.init(frame: .zero)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Public Methods
    
    func updateCurrencySymbol(_ symbol: String) {
        currencySymbol = symbol
        currencyLabel.text = symbol
    }
    
    // MARK: - Private Methods
    
    private func setupUI() {
        addSubviews()
        makeConstraints()
        configureUI()
    }
    
    private func addSubviews() {
        addSubview(containerView)
        containerView.addSubview(textField)
        containerView.addSubview(currencyLabel)
    }
    
    private func makeConstraints() {
        containerView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.height.equalTo(50)
        }
        
        textField.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalTo(currencyLabel.snp.leading).offset(-8)
        }
        
        currencyLabel.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.trailing.equalToSuperview().inset(16)
            make.width.equalTo(30)
        }
    }
    
    private func configureUI() {
        textField.placeholder = type.placeholder
        currencyLabel.text = currencySymbol
    }
}

// MARK: - Field Type

extension CurrencyTextField {
    enum FieldType {
        case sell
        case buy
        
        var placeholder: String {
            switch self {
            case .sell:
                return "Sell"
            case .buy:
                return "Buy"
            }
        }
    }
}
