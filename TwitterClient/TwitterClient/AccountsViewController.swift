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
    
    let kAccountsCell = "AccountsCell"
    let kAddAccountCell = "AddAccountCell"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        reloadTable()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func reloadTable() {
        allAccounts = UserAccountManagement.sharedInstance.allAccounts
        self.tableView.reloadData()
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
            
            // 1. all is good here, able to add the new account
            self.addAccountViewController?.dismiss(animated: true, completion:nil)
            
            // 2. commit this new user account to the 'all accounts' list
            UserAccountManagement.sharedInstance.addAccount(userAccount)
            
            // 3. update accounts table view
            self.reloadTable()
            
            // 4. notify delegate of account update
            self.delegate?.accountsUpdated(sender: self)
            
            // 5. notify delegate so it can change the offset of the accounts view if required
            self.delegate?.accountSwitched(sender: self, userAccount: userAccount)
            }, error: { (error) in
                
                // 1. failed to log in the user
                self.addAccountViewController?.dismiss(animated: true, completion: nil)
                
                // 2. restore the current user account to the previous current account
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
        
        if allAccounts.count == 1 {
            // last user, log out after confirmation
            confirmLogout(sender)
        } else {
            // 1. remove user, pick another one if this is the current user
            let switchingAccounts = sender.userAccount.isCurrentUserAccount
            UserAccountManagement.sharedInstance.remove(userAccount: sender.userAccount)

            // 2. update the accounts table view
            reloadTable()

            // 3. notify delegate of account update
            self.delegate?.accountsUpdated(sender: self)

            // 4. If this is an account switch, notify the delegate
            let newCurrentAccount = UserAccountManagement.sharedInstance.currentUserAccount
            if switchingAccounts == true,
                let newCurrentAccount = newCurrentAccount {
                self.delegate?.accountSwitched(sender: self, userAccount: newCurrentAccount)
            }
        }
    }
    
    func confirmLogout(_ sender : AccountsCell) {
        let alertVC = UIAlertController(title: "Logout Current User?", message: "", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default) { (action) in
            let userAccount = UserAccountManagement.sharedInstance.currentUserAccount
            userAccount?.logOutUser()
            UserAccountManagement.sharedInstance.currentUserAccount = nil
            NotificationCenter.default.post(name: Notification.Name(rawValue: TimeLineViewController.kNotificationUserLoggedOut), object: self)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .default) { (action) in
            sender.cancelDelete()
        }
        alertVC.addAction(okAction)
        alertVC.addAction(cancelAction)
        present(alertVC, animated: true)
    }
    
    func selected(sender: AccountsCell) {
        
    }

}
