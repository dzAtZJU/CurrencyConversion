//
//  USDExchangeRatesFetcher.swift
//  CurrencyConversion
//
//  Created by Zhou Wei Ran on 2021/2/1.
//

import Foundation

fileprivate let endpointUSDExchangeRate = "http://api.currencylayer.com/live?access_key=b4b653ae6239052d18dcccd3ff349f92"

extension Notification.Name {
    static let newUSDExchangeRatesResult = Notification.Name("newUSDExchangeRatesResult")
}

let keyNotificationUSDExchangeRatesResult = "usdExchangeRatesResult"

let keyUserDefaultsUSDExchangeRatesTimeStamp = "USDExchangeRatesTimeStamp"

final class USDExchangeRatesFetcher: NSObject {
    static let shared = USDExchangeRatesFetcher()
        
    /**
     Persistent Layer: utilize URLCache as persistent layer. If the hit response is older than 30 mins. CachePolicy can be set to ignore local cache data.
     
     the json response from server is strings and ints of only several-KB. Memory data model constructed from the whole json response thus consumes only a little memory.
     
     Besides, this json response can be updated as a whole instead of requiring many small writes. Thus file system is sufficient for persistent layer without bothering database like core data.
     
     Since the endpoint api.currencylayer.com/live reply without http cache control header, URLCache with disk persistence can be utilized for our 30 mins refreshing aim.
     */
    func tryFetch(completion: ((Result<USDExchangeRates, FetcherError>) -> Void)? = nil) {
        let config = URLSessionConfiguration.default
        config.waitsForConnectivity = true
        let session = URLSession(configuration: config)
        
        let cachePolicy: URLRequest.CachePolicy = shouldCheckCache ? .returnCacheDataElseLoad: .reloadIgnoringLocalCacheData
        var request = URLRequest(url: URL(string: endpointUSDExchangeRate)!, cachePolicy: cachePolicy)
        request.networkServiceType = .responsiveData
        
        session.dataTask(with: request) { (data, response, error) in
            var result: Result<USDExchangeRates, FetcherError>!
            defer {
                completion?(result)
                NotificationCenter.default.post(name: .newUSDExchangeRatesResult, object: nil, userInfo: [keyNotificationUSDExchangeRatesResult: result!])
            }
            
            if error != nil || response == nil || data == nil {
                result = .failure(.tryRefresh)
                return
            }
            
            guard let endpointResult = try? JSONDecoder().decode(EndpointResult.self, from: data!),
                  endpointResult.success,
                  let timestamp = endpointResult.timestamp,
                  let quotes = endpointResult.quotes else {
                result = .failure(.unRecoverable)
                return
            }
            
            UserDefaults.standard.setValue(Date().timeIntervalSince1970, forKey: keyUserDefaultsUSDExchangeRatesTimeStamp)
            result = .success(USDExchangeRates(timestamp: timestamp, quotes: quotes))
        }
        .resume()
        session.finishTasksAndInvalidate()
    }
    
    var shouldCheckCache: Bool {
        let lastTimeStamp = UserDefaults.standard.double(forKey: keyUserDefaultsUSDExchangeRatesTimeStamp)
        return lastTimeStamp > Date(timeIntervalSinceNow: -30*60).timeIntervalSince1970
    }
}

enum FetcherError: Error {
    case tryRefresh
    case unRecoverable
}

struct USDExchangeRates {
    let timestamp: Double
    let quotes: [String: Double]
}

private extension USDExchangeRatesFetcher {
    struct EndpointResult: Decodable {
        let success: Bool
        
        let timestamp: Double?
        let quotes: [String: Double]?
    }
}
