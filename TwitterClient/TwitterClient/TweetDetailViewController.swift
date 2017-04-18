//
//  TweetDetailViewController.swift
//  TwitterClient
//
//  Created by Akshay Bhandary on 4/14/17.
//  Copyright © 2017 AkshayBhandary. All rights reserved.
//

import UIKit
import MBProgressHUD

class TweetDetailViewController: UIViewController {

    let kFavoritedImage = "favorite_heart"
    let kUnfavoritedImage = "unfavorite_heart"
    
    let kRetweetedImage = "retweeted"
    let kNotRetweetedImage = "notretweeted"
    
    let kTweetReplyFromDetailSegue = "tweetReplyFromDetailSegue"

    static let dateFormatter = DateFormatter()
    
    var tweet : Tweet?
    
    var tweetCell : TweetCell?
    
    @IBOutlet weak var thumbNailImage: UIImageView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var screenName: UILabel!
    @IBOutlet weak var tweetText: UILabel!
    @IBOutlet weak var timeStamp: UILabel!
    @IBOutlet weak var numberOfRetweetsLabel: UILabel!
    @IBOutlet weak var numberOfLikesLabel: UILabel!

    @IBOutlet weak var replyImageView: UIImageView!
    
    @IBOutlet weak var retweetImageView: UIImageView!
    
    @IBOutlet weak var favoritesImageView: UIImageView!
    
    @IBOutlet weak var networkErrorBannerView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if let tweet = tweet {
            if let user = tweet.user {
                
                // user thumbnail image
                if let imageURL = user.profileURL {
                    thumbNailImage.setImageWith(imageURL)
                }

                // user name and handle
                name.text = user.name
                screenName.text = user.screename
            }

            // likes
            if let  likes = tweet.favoritesCount {
                numberOfLikesLabel.text = String(likes)
            }
            updateFavoritesImage()

            
            
            // retweets count
            if let retweetsCount = tweet.retweetCount {
                numberOfRetweetsLabel.text = String(retweetsCount)
            }
            updateRetweetImage()
            
            // tweet text
            tweetText.text = tweet.text
            
            // set tweet date
            if let tweetDate = tweet.tweetDate {
                TweetDetailViewController.dateFormatter.dateFormat = "MM/dd/yy, HH:mm a"
                timeStamp.text = TweetDetailViewController.dateFormatter.string(from: tweetDate)
            } else {
                timeStamp.text = ""
            }
            
            // add gesture recognizers
            let replyImageTapGS = UITapGestureRecognizer(target: self, action: #selector(replyImageTapped))
            replyImageView.isUserInteractionEnabled = true
            replyImageView.addGestureRecognizer(replyImageTapGS)

            let retweetImageTapGS = UITapGestureRecognizer(target: self, action: #selector(retweetImageTapped))
            retweetImageView.isUserInteractionEnabled = true
            retweetImageView.addGestureRecognizer(retweetImageTapGS)

            let favoritesImageTapGS = UITapGestureRecognizer(target: self, action: #selector(likeImageTapped))
            favoritesImageView.isUserInteractionEnabled = true
            favoritesImageView.addGestureRecognizer(favoritesImageTapGS)
        }
        // Do any additional setup after loading the view.
    }

    func replyImageTapped() {
        self.performSegue(withIdentifier: kTweetReplyFromDetailSegue, sender: self)
    }

    func retweetImageTapped() {

        if let tweet = tweet,
            let tweetID = tweet.tweetID {

            let successBlock : (Tweet) -> () = { (receivedTweet)  in
                tweet.updateWith(tweet: receivedTweet)
                self.updateRetweetCountDisplay()
                self.updateRetweetImage()
            }
            
            let errorBlock : (Error)->() = { (error) in
                // ViewUtils.showToast(view: self.networkErrorBannerView)
            }
            
            if tweet.retweeted == false {
                UserAccount.currentUserAccount?.post(retweetID: tweetID, success: successBlock, error: errorBlock)
            } else {
                if let originalTweetIDStr = tweet.originalTweetID,
                    let originalID = Int(originalTweetIDStr) {
                    UserAccount.currentUserAccount?.post(unretweetID: originalID, success: successBlock, error: errorBlock)
                } else {
                    errorBlock(NSError(domain: "No original ID in retweet", code: 0, userInfo: nil))
                }
            }

        }
    }

    func likeImageTapped() {
        if let tweet = tweet,
            let tweetID = tweet.tweetID {

            let successBlock : (Tweet) -> () = { (receivedTweet)  in
                tweet.updateWith(tweet: receivedTweet)
                self.updateFavoriteCountDisplay()
                self.updateFavoritesImage()
            }
            
            let errorBlock : (Error)->() = { (error) in
                // ViewUtils.showToast(view: self.networkErrorBannerView)
            }

            
            if tweet.favorited! == false {
                UserAccount.currentUserAccount?.post(favoriteTweetID: tweetID, success: successBlock, error: errorBlock)
            } else {
                UserAccount.currentUserAccount?.post(unfavoriteTweetID: tweetID, success: successBlock, error: errorBlock)
            }
        }
    }

    
    func updateRetweetCountDisplay() {
        
        if let tweet = tweet {
            numberOfRetweetsLabel.text = String(tweet.retweetCount!)
            if let tweetCell = tweetCell {
                tweetCell.updateRetweetDisplay()
            }
        }
    }

    func updateRetweetImage() {
        
        if let tweet = tweet {
            ViewUtils.transition(imageView: self.retweetImageView,
                                 imageNamed: tweet.retweeted! == true ? kRetweetedImage : kNotRetweetedImage,
                                 duration: 0.1)
            self.retweetImageView.setNeedsDisplay()
        }
    }
    
    func updateFavoritesImage() {
        if let tweet = tweet {
            ViewUtils.transition(imageView: self.favoritesImageView,
                                 imageNamed: tweet.favorited! == true ? kFavoritedImage : kUnfavoritedImage,
                                 duration: 0.1)
            self.favoritesImageView.setNeedsDisplay()
        }
    }

  
    func updateFavoriteCountDisplay() {
        
        if let tweet = tweet {
            tweet.favoritesCount = tweet.favoritesCount!
            numberOfLikesLabel.text = String(tweet.favoritesCount!)
            if let tweetCell = tweetCell {
                tweetCell.updateFavoritesDisplay()
            }
        }
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if  segue.identifier! == kTweetReplyFromDetailSegue,
            let navVC = segue.destination as? UINavigationController,
            let composeVC = navVC.topViewController as? TweetComposeViewController,
            let tweet = tweet,
            let tweetID = tweet.tweetID {

            // set in reply to ID and screename
            composeVC.inReplyToID = tweetID
            composeVC.inReplyToScreenName = tweet.user?.screename
        }
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
