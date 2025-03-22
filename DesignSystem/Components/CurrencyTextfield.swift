//
//  CurrencyTextField.swift
//  CurrencyConverter
//
//  Created by tornike <parunashvili on 19.03.25.
//

import UIKit
import Combine
import SnapKit

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
  private var decimalSeparator: String { Locale.current.decimalSeparator ?? "." }
  private var cancellables = Set<AnyCancellable>()
  
  // MARK: - UI Components
  
  private lazy var containerView: UIView = {
    let view = UIView()
    view.backgroundColor = .white
    view.layer.borderColor = UIColor.lightGreen.cgColor
    view.layer.borderWidth = Grid.BorderWidth.thin
    view.layer.cornerRadius = Grid.CornerRadius.small
    return view
  }()
  
  private lazy var textField: UITextField = {
    let field = UITextField()
    field.borderStyle = .none
    field.keyboardType = .decimalPad
    field.textAlignment = .left
    field.font = .systemFont(ofSize: Grid.FontSize.medium)
    field.textColor = .black
    return field
  }()
  
  private lazy var currencyLabel: UILabel = {
    let label = UILabel(
      font: .systemFont(ofSize: Grid.FontSize.medium, weight: .semibold),
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
    setupBindings()
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
      make.height.equalTo(Grid.Size.xl4)
    }
    
    textField.snp.makeConstraints { make in
      make.top.bottom.equalToSuperview()
      make.leading.equalToSuperview().offset(Grid.Spacing.m)
      make.trailing.equalTo(currencyLabel.snp.leading).offset(-Grid.Spacing.xs)
    }
    
    currencyLabel.snp.makeConstraints { make in
      make.top.bottom.equalToSuperview()
      make.trailing.equalToSuperview().inset(Grid.Spacing.m)
      make.width.equalTo(Grid.Size.xl3)
    }
  }
  
  private func configureUI() {
    textField.placeholder = type.placeholder
    currencyLabel.text = currencySymbol
  }
  
  private func setupBindings() {
    textField.textPublisher
      .sink { [weak self] text in
        self?.filterInput(text)
      }
      .store(in: &cancellables)
  }
  
  private func filterInput(_ text: String?) {
    guard let text = text else { return }
    
    let allowedCharacters = CharacterSet(charactersIn: "0123456789\(decimalSeparator)")
    let filteredText = text.components(separatedBy: allowedCharacters.inverted).joined()
    
    if filteredText != text {
      textField.text = filteredText
    }
    
    if filteredText.components(separatedBy: decimalSeparator).count > 2 {
      let components = filteredText.components(separatedBy: decimalSeparator)
      let wholeNumber = components[0]
      let fraction = components[1]
      textField.text = "\(wholeNumber)\(decimalSeparator)\(fraction)"
    }
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
