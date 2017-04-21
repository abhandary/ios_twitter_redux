//
//  UserStream.swift
//  TwitterClient
//
//  Created by Akshay Bhandary on 4/12/17.
//  Copyright © 2017 AkshayBhandary. All rights reserved.
//

import Foundation


let kHomeTimeLine      = "1.1/statuses/home_timeline.json"
let kVerifyCredentials = "1.1/account/verify_credentials.json"
let kPostStatusUpdate  = "1.1/statuses/update.json"
let kRetweet           = "1.1/statuses/retweet/%lld.json"
let kUnretweet         = "1.1/statuses/unretweet/%lld.json"
let kFavorites         = "1.1/favorites/create.json"
let kUnfavorites       = "1.1/favorites/destroy.json"
let kRetweeters        = "1.1/statuses/retweeters/ids.json"

let kUserTimeLine      = "1.1/statuses/user_timeline.json"
let kMentionsTimeLine  = "1.1/statuses/mentions_timeline.json"

let kUserParam  = "user_id"
let kCountParam = "count"
let kMaxIDParam = "max_id"

class TwitterAPIService {
    
    var timeLine = kHomeTimeLine
    
    let kMaxTweetCountPerRequest = 20 // @note: can go upto 200
    
    var apiToLastSeenIDMap = [String : Int]()
    
    var tweetsLoading = false
    
    var oauthClient : OAuthClient!
    
    init(oauthClient : OAuthClient) {
        self.oauthClient = oauthClient
    }

    // MARK:- public routines
    
    // MARK:- home timeline
    func fetchTweets(success: @escaping (([Tweet]) -> Void),
                     error:@escaping ((Error) -> Void)) {
        
        let params = [kCountParam : kMaxTweetCountPerRequest]
        fetchTweets(kHomeTimeLine, params: params, success: success, error: error)
    }
    
    func fetchTweetsOlderThanLastFetch(success: @escaping (([Tweet]) -> Void),
                                       error:@escaping ((Error) -> Void)) {
        
        let lastSeenLowestTweetID = apiToLastSeenIDMap[kHomeTimeLine]!
        guard lastSeenLowestTweetID < Int.max else {
            error(NSError(domain: "no more tweets available", code: 0, userInfo: nil));
            return;
        }
        
        let params = [
                      kCountParam : kMaxTweetCountPerRequest,
                      kMaxIDParam :lastSeenLowestTweetID
                      ]
        fetchTweets(kHomeTimeLine, params: params, success: success, error: error)
    }
    
    // MARK: - user timeline
    func fetchTweets(user : User, success: @escaping (([Tweet]) -> Void),
                     error:@escaping ((Error) -> Void)) {
        
        let params = [kCountParam : kMaxTweetCountPerRequest,
                      kUserParam : user.userID!]
        fetchTweets(kUserTimeLine, params: params, success: success, error: error)
    }
    
    func fetchTweetsOlderThanLastFetch(user : User, success: @escaping (([Tweet]) -> Void),
                                       error:@escaping ((Error) -> Void)) {
        
        let lastSeenLowestTweetID = apiToLastSeenIDMap[kUserTimeLine]!
        guard lastSeenLowestTweetID < Int.max else {
            error(NSError(domain: "no more tweets available", code: 0, userInfo: nil));
            return;
        }
        
        let params = [
            kCountParam : kMaxTweetCountPerRequest,
            kMaxIDParam :lastSeenLowestTweetID,
            kUserParam : user.userID!
        ]
        fetchTweets(kUserTimeLine, params: params, success: success, error: error)
    }
    
    
    // MARK: - mentions
    func fetchMentionTweets(success: @escaping (([Tweet]) -> Void),
                     error:@escaping ((Error) -> Void)) {
        
        let params = [kCountParam : kMaxTweetCountPerRequest]
        fetchTweets(kMentionsTimeLine, params: params, success: success, error: error)
    }
    
    func fetchMentionTweetsOlderThanLastFetch(success: @escaping (([Tweet]) -> Void),
                                       error:@escaping ((Error) -> Void)) {
        
        let lastSeenLowestTweetID = apiToLastSeenIDMap[kMentionsTimeLine]!
        guard lastSeenLowestTweetID < Int.max else {
            error(NSError(domain: "no more tweets available", code: 0, userInfo: nil));
            return;
        }
        
        let params = [
            kCountParam : kMaxTweetCountPerRequest,
            kMaxIDParam :lastSeenLowestTweetID
        ]
        fetchTweets(kMentionsTimeLine, params: params, success: success, error: error)
    }
    
    
    func currentUser(success : @escaping (User) -> (), error : @escaping (Error) -> ()) {
        
        oauthClient.get(kVerifyCredentials,
                                       parameters: nil,
                                       progress: nil,
                                       success: { (task, response) in
                                        if let dictionary = response as? NSDictionary {
                                            let user = User(dictionary: dictionary)
                                            success(user)
                                        } else {
                                            error(NSError(domain: "unable to fetch user", code: 0, userInfo: nil))
                                        }
        }) { (task, receivedError) in
            error(receivedError)
        }
    }
    
    func post(statusUpdate : String, success : @escaping (Tweet) -> (), error : @escaping (Error) -> ()) {
        let params = ["status" : statusUpdate]
        postStatusUpdate(params: params, success: success, error: error)
    }

    func post(statusUpdate : String, inReplyTo: Int, success : @escaping (Tweet) -> (), error : @escaping (Error) -> ()) {
        let params : [String : Any] = ["status" : statusUpdate,
                      "in_reply_to_status_id" : inReplyTo
                      ]
        
        postStatusUpdate(params: params, success: success, error: error)
    }

    
    func post(retweetID : Int,  success : @escaping (Tweet) -> (), error : @escaping (Error) -> ()) {
        
        let requestURLString = String(format: kRetweet, retweetID)
        let params = ["id" : retweetID]
        oauthClient.post(requestURLString,
                                        parameters: params,
                                        progress: nil,
                                        success: { (task, response) in
                                           // print(response)
                                            if let dictionary = response as? NSDictionary {
                                                let tweet = Tweet(dictionary: dictionary);
                                                success(tweet)
                                            } else {
                                                error(NSError(domain: "unable to post tweet", code: 0, userInfo: nil))
                                            }
        }) { (task, receivedError) in
            error(receivedError)
        }
    }
    
    func post(unretweetID : Int,  success : @escaping (Tweet) -> (), error : @escaping (Error) -> ()) {
        
        let requestURLString = String(format: kUnretweet, unretweetID)
        let params = ["id" : unretweetID]
        oauthClient.post(requestURLString,
                                        parameters: params,
                                        progress: nil,
                                        success: { (task, response) in
                                           // print(response)
                                            if let dictionary = response as? NSDictionary {
                                                let tweet = Tweet(dictionary: dictionary);
                                                success(tweet)
                                            } else {
                                                error(NSError(domain: "unable to post tweet", code: 0, userInfo: nil))
                                            }
        }) { (task, receivedError) in
            error(receivedError)
        }
    }


    func post(favoriteTweetID : Int,  success : @escaping (Tweet) -> (), error : @escaping (Error) -> ()) {
        

        let params = ["id" : favoriteTweetID]
        oauthClient.post(kFavorites,
                                        parameters: params,
                                        progress: nil,
                                        success: { (task, response) in
                                           // print(response)
                                            if let dictionary = response as? NSDictionary {
                                                let tweet = Tweet(dictionary: dictionary);
                                                success(tweet)
                                            } else {
                                                error(NSError(domain: "unable to post tweet", code: 0, userInfo: nil))
                                            }
        }) { (task, receivedError) in
            error(receivedError)
        }
    }

    
    func post(unfavoriteTweetID : Int,  success : @escaping (Tweet) -> (), error : @escaping (Error) -> ()) {
        
        
        let params = ["id" : unfavoriteTweetID]
        oauthClient.post(kUnfavorites,
                                        parameters: params,
                                        progress: nil,
                                        success: { (task, response) in
                                           // print(response)
                                            if let dictionary = response as? NSDictionary {
                                                let tweet = Tweet(dictionary: dictionary);
                                                success(tweet)
                                            } else {
                                                error(NSError(domain: "unable to post tweet", code: 0, userInfo: nil))
                                            }
        }) { (task, receivedError) in
            error(receivedError)
        }
        
    }

    
    
    // MARK: - internal tweets
    
    internal func postStatusUpdate(params : [String : Any], success : @escaping (Tweet) -> (), error : @escaping (Error) -> ()) {
        
        oauthClient.post(kPostStatusUpdate,
                                       parameters: params,
                                       progress: nil,
                                       success: { (task, response) in
                                      //  print(response)
                                        if let dictionary = response as? NSDictionary {
                                            let tweet = Tweet(dictionary: dictionary);
                                            success(tweet)
                                        } else {
                                            error(NSError(domain: "unable to post tweet", code: 0, userInfo: nil))
                                        }
        }) { (task, receivedError) in
            error(receivedError)
        }
    }
    
    internal func fetchTweets(_ api : String, params : [String : Any], success: @escaping (([Tweet]) -> Void),
                     error:@escaping ((Error) -> Void)) {
        
        
        oauthClient.get(api,
                        parameters: params,
                        progress: nil,
                        success: { (task, response) in
                            if let dictionaries = response as? [NSDictionary] {
                                let tweets = Tweet.tweetsWithArray(dictionaries: dictionaries);
                                self.saveLastSeenLowestTweetID(tweets: tweets, api: api)
                                success(tweets)
                            } else {
                                error(NSError(domain: "unable to fetch tweets", code: 0, userInfo: nil))
                            }
        }) { (task, receivedError) in
            error(receivedError)
        }
    }

    
    internal func saveLastSeenLowestTweetID(tweets : [Tweet], api : String ) {
        
        var lastSeenLowestTweetID = Int.max
        
        tweets.forEach { (tweet) in
            if let tweetID = tweet.tweetID {
                lastSeenLowestTweetID = min(tweetID, lastSeenLowestTweetID)
            }
        }
        apiToLastSeenIDMap[api] = lastSeenLowestTweetID
    }
    
}
