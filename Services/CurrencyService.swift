//
//  CurrencyService.swift
//  CurrencyConverter
//
//  Created by tornike <parunashvili on 14.03.25.
//

import Combine
import Foundation

// MARK: - Errors

enum CurrencyServiceError: Error {
  case invalidURL
  case decodingError(String)
  case networkError(Error)
  case taskCancelled
}

// MARK: - Models

struct CurrencyExchangeResponse: Decodable {
  let amount: String
  let currency: Currency
}

// MARK: - Service Protocol

protocol CurrencyServiceProtocol {
  func fetchExchangeRate(fromAmount: Double,
               fromCurrency: Currency,
               toCurrency: Currency) async throws -> Double
  func cancelOngoingRequests()
  func enableLogging(_ enabled: Bool)
}

// MARK: - Currency Service Implementation

final class CurrencyService: CurrencyServiceProtocol {
  private let baseURL: String
  private let endpoint: String
  private var isLoggingEnabled: Bool
  private var currentTask: Task<Double, Error>?
  
  // MARK: - Initialization
  init(baseURL: String = "http://api.evp.lt/currency/commercial",
     endpoint: String = "exchange",
     loggingEnabled: Bool = false) {
    self.baseURL = baseURL
    self.endpoint = endpoint
    self.isLoggingEnabled = loggingEnabled
  }
  
  // MARK: - Configuration Methods
    
  func enableLogging(_ enabled: Bool) {
    self.isLoggingEnabled = enabled
  }
  
  // MARK: - Cancellation
  
  func cancelOngoingRequests() {
    self.currentTask?.cancel()
    self.currentTask = nil
    log("🛑 Cancelled ongoing currency exchange requests")
  }
  
  // MARK: - API Methods
  func fetchExchangeRate(fromAmount: Double,
               fromCurrency: Currency,
               toCurrency: Currency) async throws -> Double {
    // Cancel any existing task
    cancelOngoingRequests()
    
    // Create and store a new task
    let task = Task<Double, Error> {
      let urlString = "\(baseURL)/\(endpoint)/\(fromAmount)-\(fromCurrency.code)/\(toCurrency.code)/latest"
      
      log("📡 Fetching exchange rate from: \(urlString)")
      
      guard let url = URL(string: urlString) else {
        log("❌ Invalid URL: \(urlString)")
        throw CurrencyServiceError.invalidURL
      }
      
      do {
        let (data, response) = try await URLSession.shared.data(from: url)
        
        if let httpResponse = response as? HTTPURLResponse {
          log("🌐 HTTP Response: \(httpResponse.statusCode)")
          
          // Handle non-success status codes
          guard (200...299).contains(httpResponse.statusCode) else {
            throw CurrencyServiceError.networkError(
              NSError(domain: "HTTP", code: httpResponse.statusCode, userInfo: nil)
            )
          }
        }
        
        if isLoggingEnabled, let jsonString = String(data: data, encoding: .utf8) {
          log("✅ Raw API Response: \(jsonString)")
        }
        
        let decoder = JSONDecoder()
        
        do {
          let response = try decoder.decode(CurrencyExchangeResponse.self, from: data)
          
          guard let amount = response.amountAsDouble else {
            throw CurrencyServiceError.decodingError("Failed to convert amount '\(response.amount)' to Double")
          }
          
          log("🔄 Exchange Rate: \(amount) \(toCurrency)")
          return amount
        } catch {
          log("❌ Decoding Error: \(error.localizedDescription)")
          throw CurrencyServiceError.decodingError(error.localizedDescription)
        }
      } catch let error as CurrencyServiceError {
        throw error
      } catch {
        if Task.isCancelled {
          log("🛑 Task was cancelled")
          throw CurrencyServiceError.taskCancelled
        }
        log("❌ Network Error: \(error.localizedDescription)")
        throw CurrencyServiceError.networkError(error)
      }
    }
    
    self.currentTask = task
    
    do {
      return try await task.value
    } catch {
      if Task.isCancelled {
        throw CurrencyServiceError.taskCancelled
      }
      throw error
    }
  }
  
  // MARK: - Helper Methods
  
  private func log(_ message: String) {
    guard isLoggingEnabled else { return }
    print(message)
  }
}
