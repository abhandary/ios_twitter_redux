//
//  AccountsViewController.swift
//  TwitterClient
//
//  Created by Akshay Bhandary on 4/19/17.
//  Copyright © 2017 AkshayBhandary. All rights reserved.
//

import UIKit

class AccountsViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var doneButton: UIBarButtonItem!
    
    
    var currentAccountIndex : Int!
    
    let kAccountsCell = "AccountsCell"
    let kAddAccountCell = "AddAccountCell"
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        
        // get the index corresponding to the current user
        for ix in 0..<UserAccount.allAccounts.count {
            
            if let currentUser = UserAccount.currentUserAccount.user,
                let user = UserAccount.allAccounts[ix].user,
                user.userID! == currentUser.userID! {
                
                currentAccountIndex = ix
            }
        }
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

extension AccountsViewController : UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return UserAccount.allAccounts.count + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.row < UserAccount.allAccounts.count {
            let cell = tableView.dequeueReusableCell(withIdentifier: kAccountsCell) as! AccountsCell
            cell.user = UserAccount.allAccounts[indexPath.row].user
            return cell
        } else {
            return tableView.dequeueReusableCell(withIdentifier: kAddAccountCell)!
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
}
