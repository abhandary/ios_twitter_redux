//
//  UserAccount.swift
//  TwitterClient
//
//  Created by Akshay Bhandary on 4/12/17.
//  Copyright © 2017 AkshayBhandary. All rights reserved.
//

import Foundation


class UserAccount : NSObject {
    
    var loginService : TwitterLoginService!
    var apiService : TwitterAPIService!
    
    var successCompletionHandler : ((Void) -> Void)?
    var errorCompletionHandler : ((Error) -> Void)?
    
    override init() {
        super.init()
        
        let oauthClient = OAuthClient.oauthAuthClient()
        loginService = TwitterLoginService(oauthClient: oauthClient)
        apiService = TwitterAPIService(oauthClient: oauthClient)
    }
    
    convenience init(_ user : User) {
        self.init()
        self.user = user
    }
    
    var accessToken : Data? {
        didSet {
            if let accessToken = accessToken,
                isCurrentUserAccount == true {
                loginService.saveAccessToken(accessToken: accessToken)
            }
        }
    }
    
    var user : User?
    var isCurrentUserAccount : Bool = false {
        didSet {
            if let accessToken = accessToken,
                isCurrentUserAccount == true {
                loginService.saveAccessToken(accessToken: accessToken)
            }
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
        
        loginService.loginUser(success: { (accessToken) in
            
            self.apiService.currentUser(success: { (user) in
                self.accessToken = accessToken
                self.user = user
                if self.isCurrentUserAccount == true {
                    User.currentUser = user
                }
                UserAccountManagement.sharedInstance.saveAllAccountsToDisk()
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
        
        apiService.fetchTweets(success: success, error: error)
    }
    
    func fetchTweetsOlderThanLastFetch(success: @escaping (([Tweet]) -> Void),
                     error:@escaping ((Error) -> Void)) {
        
        apiService.fetchTweetsOlderThanLastFetch(success: success, error: error)
    }

    func fetchTweets(user : User, success: @escaping (([Tweet]) -> Void),
                     error:@escaping ((Error) -> Void)) {
        
        apiService.fetchTweets(user : user, success: success, error: error)
    }
    
    func fetchTweetsOlderThanLastFetch(user : User, success: @escaping (([Tweet]) -> Void),
                                       error:@escaping ((Error) -> Void)) {
        
        apiService.fetchTweetsOlderThanLastFetch(user : user, success: success, error: error)
    }
    
    func fetchMentionTweets(success: @escaping (([Tweet]) -> Void),
                            error:@escaping ((Error) -> Void)) {
        
        apiService.fetchMentionTweets(success: success, error: error)
    }
    
    
    func fetchMentionTweetsOlderThanLastFetch(success: @escaping (([Tweet]) -> Void),
                                              error:@escaping ((Error) -> Void)) {
        apiService.fetchMentionTweetsOlderThanLastFetch(success: success, error: error)
    }


    func post(statusUpdate : String,  success: @escaping ((Tweet)->()), error:@escaping ((Error)->Void)) {
        apiService.post(statusUpdate: statusUpdate, success: success, error: error)
    }
    
    func post(statusUpdate : String, inReplyTo: Int, success : @escaping (Tweet) -> (), error : @escaping (Error) -> ()) {
        apiService.post(statusUpdate: statusUpdate, inReplyTo: inReplyTo, success: success, error: error)
    }
    
    func post(retweetID : Int,  success : @escaping (Tweet) -> (), error : @escaping (Error) -> ()) {
        apiService.post(retweetID: retweetID, success: success, error: error)
    }
    
    func post(unretweetID : Int,  success : @escaping (Tweet) -> (), error : @escaping (Error) -> ()) {
        apiService.post(unretweetID: unretweetID, success: success, error: error)
    }
    
    func post(favoriteTweetID : Int,  success : @escaping (Tweet) -> (), error : @escaping (Error) -> ()) {
        apiService.post(favoriteTweetID: favoriteTweetID, success: success, error: error)
    }
    
    func post(unfavoriteTweetID : Int,  success : @escaping (Tweet) -> (), error : @escaping (Error) -> ()) {
        apiService.post(unfavoriteTweetID: unfavoriteTweetID, success: success, error: error)
    }
}

