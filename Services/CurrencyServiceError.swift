//
//  CurrencyServiceError.swift
//  CurrencyConverter
//
//  Created by tornike <parunashvili on 22.03.25.
//

import Foundation

// MARK: - Errors

enum CurrencyServiceError: Error, LocalizedError {
  case invalidURL
  case decodingError(String)
  case networkError(Error)
  case taskCancelled
  
  var errorDescription: String? {
    switch self {
    case .invalidURL:
      return "Invalid URL format"
    case .decodingError(let message):
      return "Failed to decode response: \(message)"
    case .networkError(let error):
      return "Network error: \(error.localizedDescription)"
    case .taskCancelled:
      return "Request was cancelled"
    }
  }
}
