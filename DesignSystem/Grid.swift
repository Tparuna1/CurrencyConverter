//
//  Grid.swift
//  CurrencyConverter
//
//  Created by tornike <parunashvili on 20.03.25.
//

import Foundation

public enum Grid {
  public enum Spacing {
    public static let xs4: CGFloat = 1.0
    public static let xs3: CGFloat = 2.0
    public static let xs2: CGFloat = 4.0
    public static let xs: CGFloat = 8.0
    public static let s: CGFloat = 12.0
    public static let m: CGFloat = 16.0
    public static let l: CGFloat = 20.0
    public static let xl: CGFloat = 24.0
    public static let xl2: CGFloat = 28.0
    public static let xl3: CGFloat = 32.0
    public static let xl4: CGFloat = 48.0
  }
  
  public enum Size {
    public static let xs4: CGSize = .init(squareSide: Spacing.xs4)
    public static let xs3: CGSize = .init(squareSide: Spacing.xs3)
    public static let s2: CGSize = .init(squareSide: Spacing.xs2)
    public static let xs: CGSize = .init(squareSide: Spacing.xs)
    public static let s: CGSize = .init(squareSide: Spacing.s)
    public static let m: CGSize = .init(squareSide: Spacing.m)
    public static let l: CGSize = .init(squareSide: Spacing.l)
    public static let xl: CGSize = .init(squareSide: Spacing.xl)
    public static let xl2: CGSize = .init(squareSide: Spacing.xl2)
    public static let xl3: CGSize = .init(squareSide: Spacing.xl3)
    public static let xl4: CGSize = .init(squareSide: Spacing.xl4)
  }
  
  public enum FontSize {
    public static let small: CGFloat = 12.0
    public static let regular: CGFloat = 14.0
    public static let medium: CGFloat = 16.0
    public static let large: CGFloat = 18.0
  }
  
  public enum BorderWidth {
    public static let thin: CGFloat = 1.0
    public static let thick: CGFloat = 4.0
  }
  
  public enum Opacity {
    public static let thin: CGFloat = 0.5
  }
  
  public enum Height {
    public static let container: CGFloat = 300
  }
  
  public enum CornerRadius {
    public static let small: CGFloat = 8.0
    public static let medium: CGFloat = 12.0
    public static let large: CGFloat = 24.0
  }
}
