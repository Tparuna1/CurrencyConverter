//
//  SceneDelegate.swift
//  CurrencyConverter
//
//  Created by tornike <parunashvili on 14.03.25.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
  
  var window: UIWindow?
  
  func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
    
    guard let someScene = (scene as? UIWindowScene) else { return }
    
    window = UIWindow(windowScene: someScene)
    let firstVC = CurrencyConverterViewController()
    let someNavigationController = UINavigationController(rootViewController: firstVC)
    window?.backgroundColor = .systemBackground
    window?.rootViewController = someNavigationController
    window?.makeKeyAndVisible()
  }
}

