//
//  CurrencyService.swift
//  CurrencyConverter
//
//  Created by tornike <parunashvili on 14.03.25.
//

import Combine
import Foundation

// MARK: - Service Protocol

protocol CurrencyServiceProtocol {
  func fetchExchangeRate(fromAmount: Double,
                         fromCurrency: Currency,
                         toCurrency: Currency) async throws -> Double
  func cancelOngoingRequests()
  func enableLogging(_ enabled: Bool)
  func clearCache()
}

// MARK: - Currency Service Implementation

final class CurrencyService: CurrencyServiceProtocol {
  private let baseURL: String
  private let endpoint: String
  private var isLoggingEnabled: Bool
  private var currentTask: Task<Double, Error>?
  
  /// Cache for exchange rates with expiration time
  private var cache: [ExchangeRateCacheKey: ExchangeRateCacheValue] = [:]
  private let cacheDuration: TimeInterval = 30
  
  /// Add a serial queue for task cancellation
  private let serialQueue = DispatchQueue(label: "com.currencyconverter.taskQueue")
  
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
  
  // MARK: - Cache Management
  
  func clearCache() {
    cache.removeAll()
    log("🧹 Cache cleared")
  }
  
  private func getCachedRate(for key: ExchangeRateCacheKey) -> Double? {
    guard let cachedValue = cache[key],
          Date().timeIntervalSince(cachedValue.timestamp) < cacheDuration else {
      return nil
    }
    
    log("🗄️ Using cached exchange rate for \(key.fromCurrency.code) to \(key.toCurrency.code)")
    return cachedValue.rate
  }
  
  private func cacheRate(_ rate: Double, for key: ExchangeRateCacheKey) {
    cache[key] = ExchangeRateCacheValue(rate: rate, timestamp: Date())
    log("💾 Cached exchange rate for \(key.fromCurrency.code) to \(key.toCurrency.code)")
  }
  
  // MARK: - Cancellation
  
  func cancelOngoingRequests() {
    /// Use the serial queue to prevent race conditions during cancellation
    serialQueue.sync {
      self.currentTask?.cancel()
      self.currentTask = nil
      log("🛑 Cancelled ongoing currency exchange requests")
    }
  }
  
  // MARK: - API Methods
  func fetchExchangeRate(fromAmount: Double,
                         fromCurrency: Currency,
                         toCurrency: Currency) async throws -> Double {
    
    /// If currencies are the same, return the same amount
    if fromCurrency == toCurrency {
      return fromAmount
    }
    
    /// Check cache first
    let cacheKey = ExchangeRateCacheKey(
      fromCurrency: fromCurrency,
      toCurrency: toCurrency,
      amount: fromAmount
    )
    
    if let cachedRate = getCachedRate(for: cacheKey) {
      return cachedRate
    }
    
    /// Use the serial queue for task cancellation and creation
    return try await withCheckedThrowingContinuation { continuation in
      serialQueue.async {
        /// Cancel any existing task
        self.currentTask?.cancel()
        self.currentTask = nil
        
        /// Create a new task
        let task = Task<Double, Error> {
          let urlString = "\(self.baseURL)/\(self.endpoint)/\(fromAmount)-\(fromCurrency.code)/\(toCurrency.code)/latest"
          
          self.log("📡 Fetching exchange rate from: \(urlString)")
          
          guard let url = URL(string: urlString) else {
            self.log("❌ Invalid URL: \(urlString)")
            throw CurrencyServiceError.invalidURL
          }
          
          do {
            /// Add a small delay to prevent rapid consecutive requests
            try await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds
            
            if Task.isCancelled {
              self.log("🛑 Task was cancelled before network request")
              throw CurrencyServiceError.taskCancelled
            }
            
            let (data, response) = try await URLSession.shared.data(from: url)
            
            if Task.isCancelled {
              self.log("🛑 Task was cancelled after network request")
              throw CurrencyServiceError.taskCancelled
            }
            
            if let httpResponse = response as? HTTPURLResponse {
              self.log("🌐 HTTP Response: \(httpResponse.statusCode)")
              
              guard (200...299).contains(httpResponse.statusCode) else {
                throw CurrencyServiceError.networkError(
                  NSError(domain: "HTTP", code: httpResponse.statusCode, userInfo: nil)
                )
              }
            }
            
            if self.isLoggingEnabled, let jsonString = String(data: data, encoding: .utf8) {
              self.log("✅ Raw API Response: \(jsonString)")
            }
            
            let decoder = JSONDecoder()
            
            do {
              let response = try decoder.decode(CurrencyExchangeResponse.self, from: data)
              
              guard let amount = response.amountAsDouble else {
                throw CurrencyServiceError.decodingError("Failed to convert amount '\(response.amount)' to Double")
              }
              
              /// Calculate and cache the exchange rate
              let rate = amount / fromAmount
              self.cacheRate(rate, for: cacheKey)
              
              self.log("🔄 Exchange Rate: \(rate) \(toCurrency.code)/\(fromCurrency.code)")
              return amount
            } catch {
              self.log("❌ Decoding Error: \(error.localizedDescription)")
              throw CurrencyServiceError.decodingError(error.localizedDescription)
            }
          } catch let error as CurrencyServiceError {
            throw error
          } catch {
            if Task.isCancelled {
              self.log("🛑 Task was cancelled")
              throw CurrencyServiceError.taskCancelled
            }
            self.log("❌ Network Error: \(error.localizedDescription)")
            throw CurrencyServiceError.networkError(error)
          }
        }
        
        /// Store the task and set up continuation
        self.currentTask = task
        
        Task {
          do {
            let result = try await task.value
            continuation.resume(returning: result)
          } catch {
            continuation.resume(throwing: error)
          }
        }
      }
    }
  }
  
  // MARK: - Helper Methods
  
  private func log(_ message: String) {
    guard isLoggingEnabled else { return }
    print(message)
  }
}
