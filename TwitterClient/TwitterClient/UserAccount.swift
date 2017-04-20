//
//  UserAccount.swift
//  TwitterClient
//
//  Created by Akshay Bhandary on 4/12/17.
//  Copyright © 2017 AkshayBhandary. All rights reserved.
//

import Foundation


class UserAccount {
    
    let loginService = UserLoginService()
    var homeTimeLineService = UserTimeLineService()
    var userTimeLineService = UserTimeLineService()
    
    var successCompletionHandler : ((Void) -> Void)?
    var errorCompletionHandler : ((Error) -> Void)?
    
    
    static var _allAccounts : [UserAccount]?
    static var allAccounts : [UserAccount]! {
        set (allAccounts) {
            _allAccounts = allAccounts
        }
        get {
            if _allAccounts == nil {
                _allAccounts = [UserAccount]()
            }
            return _allAccounts
        }
    }
    
    var user : User?
    var isCurrentUserAccount : Bool = false
    
    // MARK: - construction / init routines
    static var _currentUserAccount : UserAccount?
    static var currentUserAccount : UserAccount! {
        set (userAccount) {
            if userAccount == nil {
                _currentUserAccount?.loginService.logoutUser()
                _currentUserAccount?.user = nil
            }
            _currentUserAccount = userAccount
            User.currentUser = userAccount.user
            _currentUserAccount?.isCurrentUserAccount = true
        }
        
        get {
            if _currentUserAccount == nil {
                _currentUserAccount = UserAccount()
                _currentUserAccount?.isCurrentUserAccount = true
                _currentUserAccount?.user = User.currentUser
                self.allAccounts.append(_currentUserAccount!)
            }
            return _currentUserAccount
        }
    }

    // MARK: - public routines
    
    func loginUser(success:@escaping((Void) -> Void),
                   error: @escaping((Error) -> Void),
                   receivedRequestToken: @escaping((URL) -> Void)) {
        
        successCompletionHandler = success
        errorCompletionHandler = error
        
        if let _ = self.user {
            self.successCompletionHandler?()
            return
        }
        
        loginService.loginUser(success: { () in
            
            self.homeTimeLineService.currentUser(success: { (user) in
                self.user = user
                if self.isCurrentUserAccount == true {
                    User.currentUser = user
                }
                self.successCompletionHandler?()
                }, error: { (receivedError) in
                    self.errorCompletionHandler?(receivedError)
                })
            }, error: { (error) in
                
            }, receivedRequestToken: { (url) in
                receivedRequestToken(url)
        })
        
    }
    
    func logOutUser() {
        loginService.logoutUser()
        self.user = nil
    }
    
    func receivedOauthToken(url: URL, success: @escaping ((Void)->Void), error:@escaping ((Error)->Void)) {
        self.loginService.receivedOauthToken(url: url, success: success, error: error)
    }
    
    func fetchTweets(success: @escaping (([Tweet]) -> Void),
                     error:@escaping ((Error) -> Void)) {
        
        homeTimeLineService.fetchTweets(success: success, error: error)
    }
    
    func fetchTweetsOlderThanLastFetch(success: @escaping (([Tweet]) -> Void),
                     error:@escaping ((Error) -> Void)) {
        
        homeTimeLineService.fetchTweetsOlderThanLastFetch(success: success, error: error)
    }

    func fetchTweets(user : User, success: @escaping (([Tweet]) -> Void),
                     error:@escaping ((Error) -> Void)) {
        
        userTimeLineService.fetchTweets(user : user, success: success, error: error)
    }
    
    func fetchTweetsOlderThanLastFetch(user : User, success: @escaping (([Tweet]) -> Void),
                                       error:@escaping ((Error) -> Void)) {
        
        userTimeLineService.fetchTweetsOlderThanLastFetch(user : user, success: success, error: error)
    }

    
    
    func post(statusUpdate : String,  success: @escaping ((Tweet)->()), error:@escaping ((Error)->Void)) {
        homeTimeLineService.post(statusUpdate: statusUpdate, success: success, error: error)
    }
    
    func post(statusUpdate : String, inReplyTo: Int, success : @escaping (Tweet) -> (), error : @escaping (Error) -> ()) {
        homeTimeLineService.post(statusUpdate: statusUpdate, inReplyTo: inReplyTo, success: success, error: error)
    }
    
    func post(retweetID : Int,  success : @escaping (Tweet) -> (), error : @escaping (Error) -> ()) {
        homeTimeLineService.post(retweetID: retweetID, success: success, error: error)
    }
    
    func post(unretweetID : Int,  success : @escaping (Tweet) -> (), error : @escaping (Error) -> ()) {
        homeTimeLineService.post(unretweetID: unretweetID, success: success, error: error)
    }
    
    func post(favoriteTweetID : Int,  success : @escaping (Tweet) -> (), error : @escaping (Error) -> ()) {
        homeTimeLineService.post(favoriteTweetID: favoriteTweetID, success: success, error: error)
    }
    
    func post(unfavoriteTweetID : Int,  success : @escaping (Tweet) -> (), error : @escaping (Error) -> ()) {
        homeTimeLineService.post(unfavoriteTweetID: unfavoriteTweetID, success: success, error: error)
    }
    
    
}

