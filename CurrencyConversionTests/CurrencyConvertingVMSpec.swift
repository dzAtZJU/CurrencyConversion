import Quick
import Nimble
@testable import CurrencyConversion

class CurrencyConvertingVMSpec: QuickSpec {
    override func spec() {
        it("CNY to JPY") {
            let quotes = [
                "USDJPY":104.94602,
                "USDCNY":6.459903,
            ]
            let usdExchangeRates = USDExchangeRates(timestamp: 0, quotes: quotes)
            let vm = CurrencyConvertingVM(usdExchangeRates: usdExchangeRates)
            expect(vm.convertSourceCurrency("USDCNY", sourceAmount: 45, to: "USDJPY")) == TargetCurrency(name: "JPY", amount: 731.0591041382511, exchangeRate: 16.245757869738913)
        }
    }
}
