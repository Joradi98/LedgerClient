//
//  CategoryTableViewController.swift
//  LedgerClient
//
//  Created by Johannes on 03.10.17.
//  Copyright © 2017 Johannes Raufeisen. All rights reserved.
//

import UIKit

class CategoryTableViewController: UITableViewController {

    //Instance variables
    let ledger = LedgerModel.shared()
    let categories = LedgerModel.shared().categories()
    var budget = [String:Decimal]()
   
    var categoryDelegate: CategoryTableViewDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "Categories"
        
        //Init values
        for cat in categories {
            let amount = ledger.budgetInCategory(category: cat)
            budget[cat] = amount
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "categoryID") as! BudgetTableViewCell
        
        //Set budget text
        let category = categories[indexPath.row]
        cell.textLabel?.text = category

        //Set amount of money in this budget category
        if let amount = budget[category] {
            cell.detailTextLabel?.text = "\(amount) €"
        } else {
            cell.detailTextLabel?.text = "NaN €"
        }
        
        //Set fill
        let budgetAccount = Account.init(name: "Assets:Budget:\(categories[indexPath.row])")
        let spentAccount = Account.init(name: "Expenses:\(categories[indexPath.row])")
        let currentBalance = ledger.balanceForAccount(acc: budgetAccount)
        let spentThisMonth = ledger.balanceSinceDate(acc: spentAccount, date: Date().firstDayOfCurrentMonth())
        let proportion: Decimal = currentBalance/(currentBalance+spentThisMonth)
        if proportion.isNaN == false {
            cell.fillProportion = CGFloat(truncating: proportion as NSNumber)
        } else {
            cell.fillProportion = 0
        }        
        return cell
    }
 

    //On selection: Go back to main transaction view with the selected category
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        categoryDelegate?.didSelectCategory(category: categories[indexPath.row])
    }

}

protocol CategoryTableViewDelegate {
    func didSelectCategory(category: String)
}

