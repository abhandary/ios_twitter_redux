//
//  TwitterClient.swift
//  TwitterClient
//
//  Created by Akshay Bhandary on 4/12/17.
//  Copyright © 2017 AkshayBhandary. All rights reserved.
//

import Foundation
import BDBOAuth1Manager

let kOAuthConsumerKey = "J6JgATLMYpA2LaIMNVEk8xkqo"
let kOAuthConsumerSecret = "29redeM6uFMjJVyCIPTno7w7V8ssclzb9xor6gontHIkQnbyoO"
let kOAuthBaseURL  = "https://api.twitter.com"


class OAuthClient : BDBOAuth1SessionManager {
    
    
    static var sharedInstance : OAuthClient  {
        
        let instance = OAuthClient(baseURL: URL(string: kOAuthBaseURL)!, consumerKey: kOAuthConsumerKey, consumerSecret: kOAuthConsumerSecret)!;
        instance.requestSerializer.timeoutInterval = 5.0
        return instance
    }
    
}
