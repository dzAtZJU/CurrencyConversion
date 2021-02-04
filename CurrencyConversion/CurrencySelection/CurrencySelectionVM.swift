//
//  CurrencySelectionVM.swift
//  CurrencyConversion
//
//  Created by Zhou Wei Ran on 2021/2/4.
//

protocol ACurrencySelectionVM {
    var numberOfCurrencies: Int {
        get
    }
    
    func currency(at position: Int) -> String?
}
