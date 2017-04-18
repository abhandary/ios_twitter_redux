//
//  Tweet.swift
//  TwitterClient
//
//  Created by Akshay Bhandary on 4/13/17.
//  Copyright © 2017 AkshayBhandary. All rights reserved.
//

import Foundation


class Tweet {
    
    var tweetID : Int?
    var text : String?
    var tweetDate : Date?
    var retweetCount : Int?
    var favoritesCount : Int?
    
    var inReplyToScreenname : String?

    // https://courses.codepath.com/courses/intro_to_ios/pages/unretweeting
    var originalTweetID : String?
    
    let kMonthsOfYear = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]
    
    var retweeted : Bool?
    var favorited : Bool?
    
    var user : User?
    
    static let dateFormatter = DateFormatter()
    
    var dictionary : NSDictionary!
    
    init(dictionary : NSDictionary) {
       // print(dictionary)
        self.dictionary = dictionary
        text = dictionary["text"] as? String
        retweetCount = (dictionary["retweet_count"] as? Int) ?? 0

        let timestampString = dictionary["created_at"] as? String
        
        if let timestampString = timestampString {
            
            Tweet.dateFormatter.dateFormat = "EEE MMM d HH:mm:ss Z y"
            tweetDate = Tweet.dateFormatter.date(from: timestampString)
        }
        
        if let userDict = dictionary["user"] as? NSDictionary {
            user = User(dictionary: userDict)
        }
        
        if let id = dictionary["id"] as? Int {
            tweetID = id
        }
        
        favoritesCount = (dictionary["favorite_count"] as? Int) ?? 0
        
        if let retweetedInt = dictionary["retweeted"] as? Int {
            retweeted = retweetedInt == 1 ? true : false
            
            // extract the original id str if this is a retweet
            if retweeted == true {
                if let retweetedStatus = dictionary["retweeted_status"] as? [String : Any] {
                    // retweeted tweet
                    originalTweetID = retweetedStatus["id_str"] as? String
                } else {
                    originalTweetID = dictionary["id_str"] as? String
                }
            }
        }
        
        if let favoritedInt = dictionary["favorited"] as? Int {
            favorited = favoritedInt == 1 ? true : false 
        }
        
        inReplyToScreenname = dictionary["in_reply_to_screen_name"] as? String
    }
    
    func updateWith(tweet : Tweet) {
        retweetCount = tweet.retweetCount
        retweeted = tweet.retweeted
        originalTweetID = tweet.originalTweetID
        
        favorited = tweet.favorited
        favoritesCount = tweet.favoritesCount
    }
    
    func timeString() -> String {
        
        guard tweetDate != nil else { return "" }
        
        var qualifiedTime = ""
        let now = Date()
        
        let calendar = Calendar.current
        let today     = calendar.component(.day, from: now)
        
        let tweetMonth = calendar.component(.month, from: tweetDate!)
        let tweetDay   = calendar.component(.day, from: tweetDate!)
        
        // if this tweet wasn't today, then return label as "MMM d"
        if tweetDay != today {
            qualifiedTime = "\(kMonthsOfYear[tweetMonth + 1]) \(tweetDay)"
            return qualifiedTime
        }

        // tweet was posted today, return the appropriate minutes or hours ago
        if let tweetDate = tweetDate {
           let time = Int(now.timeIntervalSince(tweetDate))
            if time < 60 {
                qualifiedTime = "\(time)s"
            } else if time < 60 * 60 {
                let mins = time / 60
                qualifiedTime = "\(mins)m"
            } else {
                let hours = time / (60 * 60)
                qualifiedTime = "\(hours)h"
            }
        }
        return qualifiedTime
    }
    
    
    
    static func tweetsWithArray(dictionaries: [NSDictionary]) -> [Tweet] {
        return dictionaries.map { Tweet(dictionary: $0) }
    }
}
