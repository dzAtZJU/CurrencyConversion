import Quick
import Nimble
@testable import CurrencyConversion

class USDExchangeRatesFetcherSpec: QuickSpec {
    override func spec() {
        it("endpoint is working") {
            var usdExchangeRates: USDExchangeRates?
            USDExchangeRatesFetcher.shared.tryFetch() { result in
                usdExchangeRates = try? result.get()
            }
            expect(usdExchangeRates).toEventuallyNot(beNil(), timeout: .seconds(5))
        }
        
        it("timestamp is controlling refreshing correctly") {
            UserDefaults.standard.removeObject(forKey: keyUserDefaultsUSDExchangeRatesTimeStamp)
            expect(USDExchangeRatesFetcher.shared.shouldCheckCache) == false
            var shouldCheckCache: Bool?
            USDExchangeRatesFetcher.shared.tryFetch() { _ in
                shouldCheckCache = USDExchangeRatesFetcher.shared.shouldCheckCache
                UserDefaults.standard.removeObject(forKey: keyUserDefaultsUSDExchangeRatesTimeStamp)
            }
            expect(shouldCheckCache).toEventually(equal(true), timeout: .seconds(5))
        }
    }
}
