 //
//  User.swift
//  TwitterClient
//
//  Created by Akshay Bhandary on 4/13/17.
//  Copyright © 2017 AkshayBhandary. All rights reserved.
//

import Foundation

let kCurrentUserData = "kCurrentUserData"

class User  {
    
    var name : String?
    var screename : String?
    var profileURL : URL?
    var tagline : String?
    var userID : Int?
    var description : String?
    
    var dictionary : NSDictionary?
    
    var followersCount : Int?
    var followingCount : Int?
    
    var profileBackgroundURL : URL?
    var profileBackgroundColor : String?
    
    init(dictionary : NSDictionary) {
        name = dictionary["name"] as? String
        screename = dictionary["screen_name"] as? String
        
        if let urlString = dictionary["profile_image_url_https"] as? String {
            profileURL = URL(string: urlString);
        }
        
        description = dictionary["description"] as? String
        
        if let urlString = dictionary["profile_banner_url"] as? String {
            profileBackgroundURL = URL(string: urlString)
        }
        
        
        if let idFromDict = dictionary["id"] as? Int {
            userID = idFromDict
        }
        
        tagline = dictionary["description"] as? String
        followersCount = dictionary["followers_count"] as? Int
        followingCount = dictionary["following"] as? Int
        
        self.dictionary = dictionary as NSDictionary
    }
 
    internal static var _currentUser : User?
    static var currentUser : User? {
        get {
            if _currentUser == nil {
                let defaults = UserDefaults.standard
                let userData = defaults.object(forKey: kCurrentUserData)
                
                if let userData = userData as? Data {
                    
                    let dictionary = try! JSONSerialization.jsonObject(with: userData, options: JSONSerialization.ReadingOptions.allowFragments) as! NSDictionary;
                    print(dictionary)
                    _currentUser = User(dictionary: dictionary)
                }
            }
            return _currentUser
        }
        
        set (user) {
            let defaults = UserDefaults.standard
            _currentUser = user
            if let user = _currentUser {
                let json = try! JSONSerialization.data(withJSONObject: user.dictionary!, options: JSONSerialization.WritingOptions.prettyPrinted)
                defaults.set(json, forKey: kCurrentUserData)
            } else {
                defaults.removeObject(forKey: kCurrentUserData)
                
            }
            
        }
    }
    
 }
