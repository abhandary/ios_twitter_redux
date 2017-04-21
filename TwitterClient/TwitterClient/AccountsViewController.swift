//
//  AccountsViewController.swift
//  TwitterClient
//
//  Created by Akshay Bhandary on 4/19/17.
//  Copyright © 2017 AkshayBhandary. All rights reserved.
//

import UIKit


@objc protocol AccountsViewControllerDelegate {
    func accountsUpdated(sender : AccountsViewController)
    func accountSwitched(sender : AccountsViewController, userAccount : UserAccount)
}

class AccountsViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var doneButton: UIBarButtonItem!

    weak var delegate : AccountsViewControllerDelegate?
    
    // controller to login user into an existing account
    var addAccountViewController  : AddAccountViewController?
    
    var allAccounts : [UserAccount]!
    var currentAccountIndex : Int!
    
    let kAccountsCell = "AccountsCell"
    let kAddAccountCell = "AddAccountCell"
    
    override func viewDidLoad() {
        super.viewDidLoad()

        updateAllAccounts()
        tableView.delegate = self
        tableView.dataSource = self
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func updateAllAccounts() {
        allAccounts = UserAccountManagement.sharedInstance.allAccounts
        
        // get the index corresponding to the current user
        for ix in 0..<allAccounts.count {
            
            if let currentUser = UserAccountManagement.sharedInstance.currentUserAccount.user,
                let user = allAccounts[ix].user,
                user.userID! == currentUser.userID! {
                
                currentAccountIndex = ix
            }
        }

    }
    
}

extension AccountsViewController : UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allAccounts.count + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.row < allAccounts.count {
            let cell = tableView.dequeueReusableCell(withIdentifier: kAccountsCell) as! AccountsCell
            cell.userAccount = allAccounts[indexPath.row]
            cell.delegate = self
            if indexPath.row == currentAccountIndex {
                cell.accessoryType = .checkmark
            }  else {
                cell.accessoryType = .none
            }
            return cell
        } else {
            return tableView.dequeueReusableCell(withIdentifier: kAddAccountCell)!
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.row == allAccounts.count {
            addNewAccount()
        } else {
            UserAccountManagement.sharedInstance.currentUserAccount = allAccounts[indexPath.row]
            currentAccountIndex = indexPath.row
            self.delegate?.accountSwitched(sender: self, userAccount: allAccounts[indexPath.row])
            self.tableView.reloadData()
        }
    }
    
    func addNewAccount() {
        
        let previousCurrentUserAccount = UserAccountManagement.sharedInstance.currentUserAccount
        let userAccount = UserAccount()
        
        // need to preemptively switch current account, as the AppDelgate uses the
        // 'current account' to pass the received token
        UserAccountManagement.sharedInstance.currentUserAccount = userAccount
        userAccount.loginUser(success: { () in
            
            // all is good here, able to add the new account
            self.addAccountViewController?.dismiss(animated: true, completion:nil)
            
            // commit this new user account to the 'all accounts' list
            UserAccountManagement.sharedInstance.addAccount(userAccount)
            
            // reload the local copy of the list and reload the table view and
            // notify delegate so it can change the offset of the accounts view if required
            self.updateAllAccounts()
            self.tableView.reloadData()
            self.delegate?.accountsUpdated(sender: self)
            self.delegate?.accountSwitched(sender: self, userAccount: userAccount)
            }, error: { (error) in
                
                // failed to log in the user
                self.addAccountViewController?.dismiss(animated: true, completion: nil)
                
                // restore the current user account to the previous current account
                UserAccountManagement.sharedInstance.currentUserAccount = previousCurrentUserAccount
        }) { (requestTokenURL) in
            self.receivedRequestToken(url: requestTokenURL)
        }
    }
    
    func receivedRequestToken(url: URL) {
        
        self.addAccountViewController
            = AppDelegate.storyboard.instantiateViewController(withIdentifier: AppDelegate.kAddAccountViewController)  as? AddAccountViewController
        self.addAccountViewController?.url = url
        self.present(self.addAccountViewController!, animated: true, completion: nil);
    }
}

extension AccountsViewController : AccountsCellDelegate {
    
    func delete(sender : AccountsCell) {
        
    }
    
    func selected(sender: AccountsCell) {
        
        // updateAllAccounts()
        // self.delegate?.accountSwitched(sender: self, userAccount: sender.userAccount)
    }

}
