//
//  ButtonComponent.swift
//  CurrencyConverter
//
//  Created by tornike <parunashvili on 19.03.25.
//

import UIKit

final class ButtonComponent: UIView {
  
  // MARK: - Types
  
  typealias ButtonTapHandler = () -> Void
  
  // MARK: - Properties
  
  private let type: ButtonType
  private var onTap: ButtonTapHandler?
  
  // MARK: - UI Components
  
  private lazy var button: UIButton = {
    let button = UIButton(type: .system)
    button.setTitleColor(.white, for: .normal)
    button.titleLabel?.font = .systemFont(ofSize: Grid.FontSize.medium, weight: .semibold)
    button.layer.cornerRadius = Grid.CornerRadius.small
    button.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
    return button
  }()
  
  // MARK: - Initialization
  
  init(type: ButtonType) {
    self.type = type
    super.init(frame: .zero)
    setupUI()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - Public Methods
  
  func setTapHandler(_ handler: @escaping ButtonTapHandler) {
    onTap = handler
  }
  
  // MARK: - Private Methods
  
  private func setupUI() {
    addSubview(button)
    button.snp.makeConstraints { make in
      make.edges.equalToSuperview()
      make.height.equalTo(Grid.Size.xl4)
    }
    
    configureForType()
  }
  
  private func configureForType() {
    button.setTitle(type.title, for: .normal)
    button.backgroundColor = type.backgroundColor
    
    if case .reverse = type {
      button.setImage(UIImage(systemName: "arrow.up.arrow.down"), for: .normal)
      button.tintColor = .white
      button.backgroundColor = .lightBlue
      button.layer.cornerRadius = Grid.CornerRadius.large
      button.snp.remakeConstraints { make in
        make.center.equalToSuperview()
        make.size.equalTo(Grid.Size.xl4)
      }
    }
  }
  
  @objc private func buttonTapped() {
    onTap?()
  }
}

// MARK: - Button Type

extension ButtonComponent {
  enum ButtonType {
    case reverse
    
    var title: String {
      switch self {
      case .reverse:
        return ""
      }
    }
    
    var backgroundColor: UIColor {
      switch self {
      case .reverse:
        return .systemBlue
      }
    }
  }
}
