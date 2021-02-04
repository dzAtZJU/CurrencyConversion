//
//  ViewController.swift
//  CurrencyConversion
//
//  Created by Zhou Wei Ran on 2021/2/1.
//

import UIKit
import Combine

class CurrencyConvertingVC: UIViewController {
    
    @IBOutlet weak var sourceCurrencyBtn: UIButton!
    
    @IBOutlet weak var amountTextField: UITextField!
    
    @IBOutlet weak var conversionsGrid: UICollectionView!
    
    private var vm = CurrencyConvertingVM()
    
    private var newV: AnyCancellable?
    
    private var sourceCurrency: String = "USD" {
        didSet {
            vm.changeSourceCurrency(to: sourceCurrency)
            conversionsGrid.reloadData()
            sourceCurrencyBtn.setTitle(sourceCurrency, for: .normal)
        }
    }
        
    private var amount: Double = 0 {
        didSet {
            conversionsGrid.reloadData()
        }
    }
    
    private lazy var numberFormatter: NumberFormatter = {
        let tmp = NumberFormatter()
        tmp.maximumFractionDigits = 2
        return tmp
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        conversionsGrid.delegate = self
        conversionsGrid.dataSource = self
        (conversionsGrid.collectionViewLayout as!UICollectionViewFlowLayout).itemSize = .init(width: 207, height: 130)
        
        newV = vm.$newV.sink {  [weak self] _ in
            guard let self = self else {
                return
            }
            DispatchQueue.main.async {
                self.conversionsGrid.reloadData()
            }
        }
    }
    
    @IBAction func sourceCurrencyBtnTapped(_ sender: Any) {
        let selectionVC = CurrencySelectionVC()
        selectionVC.vm = vm
        selectionVC.didSelect = { newSourceCurrency in
            self.sourceCurrency = newSourceCurrency
        }
        present(selectionVC, animated: true)
    }
    
    @IBAction func amountChanged(_ sender: UITextField) {
        guard let text = sender.text, let amount = Double(text) else {
            self.amount = 0
            return
        }
        
        self.amount = amount
    }
}

extension CurrencyConvertingVC: UICollectionViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        amountTextField.resignFirstResponder()
    }
}

extension CurrencyConvertingVC: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return vm.numberOfTargetCurrencies()
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let conversionCell = collectionView.dequeueReusableCell(withReuseIdentifier: "conversionCell", for: indexPath) as! ConversionCell
        if let targetCurrency = vm.targetCurrency(at: indexPath.item, sourceAmount: amount, sourceCurrency: sourceCurrency) {
            conversionCell.currencyLabel.text = targetCurrency.name
            conversionCell.amountLabel.text = numberFormatter.string(from: NSNumber(value: targetCurrency.amount))
            conversionCell.exchangeRateLabel.text = numberFormatter.string(from: NSNumber(value: targetCurrency.exchangeRate))
        }
        return conversionCell
    }
}
