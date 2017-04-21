//
//  TwitterLoginService.swift
//  TwitterClient
//
//  Created by Akshay Bhandary on 4/13/17.
//  Copyright © 2017 AkshayBhandary. All rights reserved.
//

import Foundation

import BDBOAuth1Manager


let kRequestTokenPath = "oauth/request_token"
let kRequestTokenMethod = "GET"
let kCallbackURL = "cpchitter://oauth"

let kAuthorizePath = "/oauth/authorize"
let kRequestTokenParam = "oauth_token"

let kAccessTokenPath = "oauth/access_token"
let kAccessTokenMethod = "POST"



class TwitterLoginService {
    
    var errorCompletionHandler : ((Error) -> Void)?
    var successCompletionHandler: ((Void) -> Void)?
    var receivedRequestTokenHandler: ((URL) -> Void)?
    
    var oauthClient : OAuthClient!
    
    init(oauthClient : OAuthClient) {
        self.oauthClient = oauthClient
    }
    
    // MARK: - public routines
    func loginUser(success:@escaping((Void) -> Void),
                   error: @escaping((Error) -> Void),
                   receivedRequestToken: @escaping((URL) -> Void)) {
        
        self.errorCompletionHandler = error
        self.successCompletionHandler = success
        self.receivedRequestTokenHandler = receivedRequestToken
        
        oauthClient.deauthorize()
        oauthClient.fetchRequestToken(withPath: kRequestTokenPath,
                                                       method: kRequestTokenMethod,
                                                       callbackURL: URL(string:kCallbackURL)!,
                                                       scope: nil,
                                                       success: { (requestToken) in
                                                        if let requestToken = requestToken {
                                                            self.received(requestToken: requestToken.token)
                                                        } else {
                                                            self.errorCompletionHandler?(NSError(domain: "Got empty request token!", code: 0, userInfo: nil))
                                                        }
            }, failure: { (error )  in
                if let error = error {
                    self.errorCompletionHandler?(error)
                } else {
                    self.errorCompletionHandler?(NSError(domain: "No Token, no error!", code: 0, userInfo: nil))
                }
        })
        
    }
    
    
    func receivedOauthToken(url: URL,
                            success: @escaping ((Void)->Void),
                            error:@escaping ((Error)->Void)) {
        
        if let urlQuery = url.query {
            
            oauthClient.fetchAccessToken(withPath: kAccessTokenPath,
                                                        method: kAccessTokenMethod,
                                                        requestToken: BDBOAuth1Credential(queryString: urlQuery),
                                                        success: { (accessToken) in
                                                            self.oauthClient.requestSerializer.saveAccessToken(accessToken)
                                                            self.successCompletionHandler?()
                                                            success()
                                                            
                }, failure: { (receivedError )  in
                    // print(receivedError)
                    error(receivedError!);
            })
            
        }
        
    }
    
    func logoutUser() {
        oauthClient.deauthorize()
    }
    
    internal func received(requestToken : String) {
        let authURL = oauthClient.baseURL!.absoluteString
        let fullURL = authURL + kAuthorizePath + "?\(kRequestTokenParam)=\(requestToken)"
        if let url = URL(string: fullURL) {
            self.receivedRequestTokenHandler?(url)
        } else {
            self.errorCompletionHandler?(NSError(domain: "Unable to form authorize URL", code: 0, userInfo: nil))
        }
    }
    
    
    
}
