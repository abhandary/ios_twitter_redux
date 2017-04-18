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
let kUnretweet         = "1.1/statuses/unretweet/%@.json"
let kFavorites         = "1.1/favorites/create.json"
let kUnfavorites       = "1.1/favorites/destroy.json"
let kStatuesShow       = "1.1/statuses/show.json"


let kCountParam = "count"
let kMaxIDParam = "max_id"

class UserTimeLineService {
    
    var timeLine = kHomeTimeLine
    
    let kMaxTweetCountPerRequest = 20 // @note: can go upto 200
    
    var lastSeenLowestTweetID = Int.max
    
    var tweetsLoading = false
    
    // MARK:- public routines
    func fetchTweets(success: @escaping (([Tweet]) -> Void),
                     error:@escaping ((Error) -> Void)) {
        
        let params = [kCountParam : kMaxTweetCountPerRequest]
        fetchTweets(params: params, success: success, error: error)
    }
    
    func fetchTweetsOlderThanLastFetch(success: @escaping (([Tweet]) -> Void),
                                       error:@escaping ((Error) -> Void)) {
        
        guard lastSeenLowestTweetID < Int.max else {
            error(NSError(domain: "no more tweets available", code: 0, userInfo: nil));
            return;
        }
        
        let params = [
                      kCountParam : kMaxTweetCountPerRequest,
                      kMaxIDParam :lastSeenLowestTweetID
                      ]
        fetchTweets(params: params, success: success, error: error)
    }
    
    
    func currentUser(success : @escaping (User) -> (), error : @escaping (Error) -> ()) {
        
        OAuthClient.sharedInstance.get(kVerifyCredentials,
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
        OAuthClient.sharedInstance.post(requestURLString,
                                        parameters: params,
                                        progress: nil,
                                        success: { (task, response) in
                                            print(response)
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
        

        let params = ["id" : unretweetID, "include_my_retweet" : 1]
        
        OAuthClient.sharedInstance.get(kStatuesShow,
                                        parameters: params,
                                        progress: nil,
                                        success: { (task, response) in
                                            print(response)
                                            if let dictionary = response as? NSDictionary,
                                                let currentUserRetweet = dictionary["current_user_retweet"] as? NSDictionary,
                                                let idStr = currentUserRetweet["id_str"] as? String {
                                                let requestURLString = String(format: kUnretweet, idStr)
                                                
                                                // let params = ["id" : unretweetID]
                                                
                                                OAuthClient.sharedInstance.post(requestURLString,
                                                                                parameters: params,
                                                                                progress: nil,
                                                                                success: { (task, response) in
                                                                                    print(response)
                                                                                    if let dictionary = response as? NSDictionary {
                                                                                        let tweet = Tweet(dictionary: dictionary);
                                                                                        success(tweet)
                                                                                    } else {
                                                                                        error(NSError(domain: "unable to untweet", code: 0, userInfo: nil))
                                                                                    }
                                                }) { (task, receivedError) in
                                                    error(receivedError)
                                                }
                                                
                                            } else {
                                                error(NSError(domain: "unable to post tweet", code: 0, userInfo: nil))
                                            }
        
                                        }) { (task, receivedError) in
                                            error(receivedError)
                                        }
    }


    func post(favoriteTweetID : Int,  success : @escaping (Tweet) -> (), error : @escaping (Error) -> ()) {
        

        let params = ["id" : favoriteTweetID]
        OAuthClient.sharedInstance.post(kFavorites,
                                        parameters: params,
                                        progress: nil,
                                        success: { (task, response) in
                                            print(response)
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
        OAuthClient.sharedInstance.post(kUnfavorites,
                                        parameters: params,
                                        progress: nil,
                                        success: { (task, response) in
                                            print(response)
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
        
        OAuthClient.sharedInstance.post(kPostStatusUpdate,
                                       parameters: params,
                                       progress: nil,
                                       success: { (task, response) in
                                        print(response)
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
    
    internal func fetchTweets(params : [String : Any], success: @escaping (([Tweet]) -> Void),
                     error:@escaping ((Error) -> Void)) {
        
        
        OAuthClient.sharedInstance.get(timeLine,
                                       parameters: params,
                                       progress: nil,
                                       success: { (task, response) in
                                        if let dictionaries = response as? [NSDictionary] {
                                            let tweets = Tweet.tweetsWithArray(dictionaries: dictionaries);
                                            self.saveLastSeenLowestTweetID(tweets: tweets)
                                            success(tweets)
                                        } else {
                                            error(NSError(domain: "unable to fetcht tweets", code: 0, userInfo: nil))
                                        }
        }) { (task, receivedError) in
            error(receivedError)
        }
    }

    
    internal func saveLastSeenLowestTweetID(tweets : [Tweet]) {
        lastSeenLowestTweetID = Int.max
        tweets.forEach { (tweet) in
            if let tweetID = tweet.tweetID {
                lastSeenLowestTweetID = min(tweetID, lastSeenLowestTweetID)
            }
        }
    }
    
}
