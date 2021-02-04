//
//  CurrencySelectionVC.swift
//  CurrencyConversion
//
//  Created by Zhou Wei Ran on 2021/2/4.
//

import UIKit

final class CurrencySelectionVC: UITableViewController {
    static let cellIdentifier = "currencyCell"
    
    var vm: ACurrencySelectionVM?
    
    var didSelect: ((String) -> Void)?
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: Self.cellIdentifier)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        vm?.numberOfCurrencies ?? 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Self.cellIdentifier)!
        if let currency = vm?.currency(at: indexPath.item) {
            cell.textLabel?.text = currency
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let currency = tableView.cellForRow(at: indexPath)!.textLabel!.text!
        didSelect?(currency)
        dismiss(animated: true, completion: nil)
    }
}
