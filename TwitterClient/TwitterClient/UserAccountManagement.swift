//
//  UserAccountManagement.swift
//  TwitterClient
//
//  Created by Akshay Bhandary on 4/20/17.
//  Copyright © 2017 AkshayBhandary. All rights reserved.
//

import Foundation


class UserAccountManagement {
    
    let kAccountsDictionary = "kAccountsDictionary"
    
    static let sharedInstance = UserAccountManagement()
    
    let queue  = DispatchQueue(label: "UserAccountManagement")
    
    var _allAccounts : [UserAccount]?
    
    var allAccounts : [UserAccount]! {
        
        get {
            self.queue.sync {
                if _allAccounts == nil {
                    readAllAccountsFromDisk()
                }
            }
            return _allAccounts
        }
    }
    
    func addAccount(_ userAccount : UserAccount) {
        
        self.queue.async {
            if self._allAccounts == nil {
                self._allAccounts = [UserAccount]()
            }
            self._allAccounts!.append(userAccount)
            self.saveAllAccountsToDisk()
        }
    }
 
    
    func saveAllAccountsToDisk() {
        
        self.queue.async {
            
            guard self._allAccounts != nil else { return; }
        

            let defaults = UserDefaults.standard
            var accountsDict = [String : NSDictionary]()
            
            // only save accounts with a valid user ID
            for account in self._allAccounts! {
                if let user = account.user,
                    let userID = user.userID,
                    let userDict = user.dictionary {
                    let userID = String(userID)
                    accountsDict[userID] = userDict
                }
            }
            
            let json = try! JSONSerialization.data(withJSONObject: accountsDict, options: JSONSerialization.WritingOptions.prettyPrinted)

            defaults.set(json, forKey: self.kAccountsDictionary);
        }
    }
    
    func readAllAccountsFromDisk() {
        
        _allAccounts = [UserAccount]()
        let defaults = UserDefaults.standard
        let userData = defaults.object(forKey: kAccountsDictionary)
        if let userData = userData as? Data {
            let accountsDict = try! JSONSerialization.jsonObject(with: userData, options: JSONSerialization.ReadingOptions.allowFragments) as! NSDictionary;


            for account in accountsDict {

                _allAccounts?.append(UserAccount(User(dictionary: account.value as! NSDictionary)))
            }

        }
        
    }
    
    
    var _currentUserAccount : UserAccount?
    var currentUserAccount : UserAccount! {
        set (userAccount) {
            queue.async {
                self.set(currentUserAccount: userAccount)
            }
        }
        
        get {
            queue.sync {
                createCurrentUserIfNil()
            }
            return _currentUserAccount
        }
    }
    
    func createCurrentUserIfNil() {
        if _currentUserAccount == nil {
            readAllAccountsFromDisk()
            
            for account in _allAccounts! {
                if let currentUser = User.currentUser,
                    let userID = currentUser.userID,
                    let accountUser = account.user,
                    let accountUserID = accountUser.userID,
                    accountUserID == userID {
                    _currentUserAccount = account
                    _currentUserAccount?.isCurrentUserAccount = true
                    return;
                }
            }
            
            // should only be here if there were no accounts added
            _currentUserAccount = UserAccount()
            _currentUserAccount?.isCurrentUserAccount = true
            addAccount( _currentUserAccount!)
        }
    }
    
    func set(currentUserAccount : UserAccount?) {
        if currentUserAccount == nil {
            _currentUserAccount?.loginService.logoutUser()
            _currentUserAccount?.user = nil
            User.currentUser = nil
        } else {
            User.currentUser = currentUserAccount?.user
        }
        
        _currentUserAccount = currentUserAccount
        _currentUserAccount?.isCurrentUserAccount = true
    }
    
}
