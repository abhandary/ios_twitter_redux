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
    
    // controller to login user into an existing account
    var addAccountViewController  : AddAccountViewController?
    
    
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
        if indexPath.row == UserAccount.allAccounts.count {
            addNewAccount()
        } else {
            UserAccount.currentUserAccount = UserAccount.allAccounts[indexPath.row]
            self.tableView.reloadData()
        }
    }
    
    func addNewAccount() {
        
        let previousCurrentUserAccount = UserAccount.currentUserAccount
        let userAccount = UserAccount()
        
        // need to preemptively switch current account, as the AppDelgate uses the
        // 'current account' to pass the received token
        UserAccount.currentUserAccount = userAccount
        userAccount.loginUser(success: { () in
            
            // all is good here, able to add the new account
            self.addAccountViewController?.dismiss(animated: true, completion:nil)
            
            // commit this new user account to the 'all accounts' list
            UserAccount.allAccounts.append(userAccount)
            }, error: { (error) in
                
                // failed to log in the user
                self.addAccountViewController?.dismiss(animated: true, completion: nil)
                
                // restore the current user account to the previous current account
                UserAccount.currentUserAccount = previousCurrentUserAccount
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
