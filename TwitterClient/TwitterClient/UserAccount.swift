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
    
    var successCompletionHandler : ((Void) -> Void)?
    var errorCompletionHandler : ((Error) -> Void)?
    
    
    // MARK: - construction / init routines
    static var _currentUserAccount : UserAccount?
    static var currentUserAccount : UserAccount? {
        set (userAccount) {
            if userAccount == nil {
                _currentUserAccount?.loginService.logoutUser()
            }
            _currentUserAccount = userAccount
        }
        
        get {
            if _currentUserAccount == nil {
                _currentUserAccount = UserAccount()
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
        
        if User.currentUser != nil {
            self.successCompletionHandler?()
            return
        }
        
        loginService.loginUser(success: { () in
            
            self.homeTimeLineService.currentUser(success: { (user) in
                User.currentUser = user
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
        User.currentUser = nil
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

