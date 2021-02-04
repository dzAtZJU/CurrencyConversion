//
//  CurrencyConvertingVM.swift
//  CurrencyConversion
//
//  Created by Zhou Wei Ran on 2021/2/4.
//
import Foundation
import Combine

struct TargetCurrency: Equatable {
    let name: String
    let amount: Double
    let exchangeRate: Double
}

class CurrencyConvertingVM {
    @Published var newV = 1
    
    private var usdExchangeRates: USDExchangeRates? {
        didSet {
            sortedCurrencies = usdExchangeRates?.quotes.keys.sorted()
        }
    }
    
    private var sortedCurrencies: [String]?
    
    private var quotes: [String: Double]? {
        usdExchangeRates?.quotes
    }
    
    private var newUSDExchangeRatesResultToken: AnyCancellable?
    
    init(usdExchangeRates: USDExchangeRates? = nil) {
        self.usdExchangeRates = usdExchangeRates
        newUSDExchangeRatesResultToken = NotificationCenter.default.publisher(for: .newUSDExchangeRatesResult).sink {[weak self] notification in
            guard let self = self else {
                return
            }
            
            switch notification.userInfo![keyNotificationUSDExchangeRatesResult] as! Result<USDExchangeRates, FetcherError>{
            case let .success(usdExchangeRates):
                self.usdExchangeRates = usdExchangeRates
                self.newV = 2
            case let .failure(error):
                return
            }
        }
    }
    
    func numberOfTargetCurrencies() -> Int {
        sortedCurrencies?.count ?? 0
    }
    
    func targetCurrency(at position: Int, sourceAmount: Double, sourceCurrency: String) -> TargetCurrency? {
        guard sortedCurrencies != nil else {
            return nil
        }
        
        let targetCurrency = sortedCurrencies![position]
        return convertSourceCurrency("USD"+sourceCurrency, sourceAmount: sourceAmount, to: targetCurrency)
    }
    
    /// only exchange rates from usd to other currencies are provided by the free backedn api. Thus calculation is required to get non-usd currency to other currencies
    func convertSourceCurrency(_ sourceCurrency: String, sourceAmount: Double, to targetCurrency: String) -> TargetCurrency {
        let usd2SourceCurrency = quotes![sourceCurrency]!
        let usd2TargetCurrency = quotes![targetCurrency]!
        let source2Target = usd2TargetCurrency / usd2SourceCurrency
        return TargetCurrency(name: String(targetCurrency.dropFirst(3)), amount: source2Target * sourceAmount, exchangeRate: source2Target)
    }
    
    func changeSourceCurrency(to currency: String) {
        
    }
}

extension CurrencyConvertingVM: ACurrencySelectionVM {
    var numberOfCurrencies: Int {
        sortedCurrencies?.count ?? 0
    }
    
    func currency(at position: Int) -> String? {
        guard let name = sortedCurrencies?[position].dropFirst(3) else {
            return nil
        }
        
        return String(name)
    }
}
