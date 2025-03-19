//
//  CurrencyService.swift
//  CurrencyConverter
//
//  Created by tornike <parunashvili on 14.03.25.
//

import Combine
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

// MARK: - Models

struct CurrencyExchangeResponse: Decodable {
    let amount: String
    let currency: Currency
}

// MARK: - Cache Key

struct ExchangeRateCacheKey: Hashable {
    let fromCurrency: Currency
    let toCurrency: Currency
    let amount: Double
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(fromCurrency.rawValue)
        hasher.combine(toCurrency.rawValue)
        hasher.combine(amount)
    }
}

// MARK: - Cache Value

struct ExchangeRateCacheValue {
    let rate: Double
    let timestamp: Date
}

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
    private let cacheDuration: TimeInterval = 30 // 30 seconds cache validity
    
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
        self.currentTask?.cancel()
        self.currentTask = nil
        log("🛑 Cancelled ongoing currency exchange requests")
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
        
        /// Cancel any existing task
        cancelOngoingRequests()
        
        /// Create and store a new task
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
                    
                    /// Calculate and cache the exchange rate
                    let rate = amount / fromAmount
                    cacheRate(rate, for: cacheKey)
                    
                    log("🔄 Exchange Rate: \(rate) \(toCurrency.code)/\(fromCurrency.code)")
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
