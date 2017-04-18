//
//  TweetComposeViewController.swift
//  TwitterClient
//
//  Created by Akshay Bhandary on 4/14/17.
//  Copyright © 2017 AkshayBhandary. All rights reserved.
//

import UIKit
import MBProgressHUD


class TweetComposeViewController: UIViewController {

    static let kUnwindToTimeLineViewSegue = "unwindToTimeLineView"
    
    var user : User?
    var inReplyToID : Int?
    var inReplyToScreenName : String?
    var postedTweet : Tweet?
    
    @IBOutlet weak var networkErrorView: UIView!
    @IBOutlet weak var tweetEntryTextField: UITextView!
    @IBOutlet weak var thumbNailImageLabel: UIImageView!

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var screenNameLabel: UILabel!
    @IBOutlet weak var countdownLabel: UILabel!

    @IBOutlet weak var replyingToLabel: UILabel!
    @IBOutlet weak var tweetEntryVerticalDistanceToThumbnailImageConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var replyingToScreename: UILabel!
    var tweetCount = 140
    let maxTweetCount = 140
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let _ = inReplyToID {
            replyingToScreename.isHidden = false
            replyingToLabel.isHidden = false
            tweetEntryVerticalDistanceToThumbnailImageConstraint.constant = 50
            replyingToScreename.text = inReplyToScreenName
        } else {
            replyingToScreename.isHidden = true
            replyingToLabel.isHidden = true
            tweetEntryVerticalDistanceToThumbnailImageConstraint.constant = 20
        }
        if let user = User.currentUser {
            if let profileURL = user.profileURL {
                thumbNailImageLabel.setImageWith(profileURL)
                thumbNailImageLabel.clipsToBounds = true
                thumbNailImageLabel.layer.cornerRadius = 5
            }
            nameLabel.text = user.name
            screenNameLabel.text = user.screename
            self.tweetEntryTextField.becomeFirstResponder()
        }
        
        tweetEntryTextField?.delegate = self
    }

    @IBAction func tweetButtonTapped(_ sender: AnyObject) {

        
        if var tweetText = self.tweetEntryTextField.text {
            let hud = MBProgressHUD.showAdded(to: self.view, animated: true);
            
            let successBlock : (Tweet)->() = { (receivedTweet) in
                hud.hide(animated: true)
                self.postedTweet = receivedTweet
                self.performSegue(withIdentifier: TweetComposeViewController.kUnwindToTimeLineViewSegue, sender: self)
            }
            
            let errorBlock : (Error)->() = { (error) in
                hud.hide(animated: true)
                ViewUtils.showToast(view: self.networkErrorView)
            }

            if let inReplyToID = inReplyToID {
                tweetText = "@\(inReplyToScreenName!) \(tweetText)"
                UserAccount.currentUserAccount?.post(statusUpdate: tweetText, inReplyTo: inReplyToID, success: successBlock, error: errorBlock)
            } else {
                UserAccount.currentUserAccount?.post(statusUpdate: tweetText, success: successBlock, error: errorBlock)
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension TweetComposeViewController : UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        if let enteredText = tweetEntryTextField.text {
            var enteredTextArray = Array(enteredText.characters)
            tweetCount = enteredTextArray.count
            
            // possible to go over 140 at one go, if the text was pasted, truncate
            if tweetCount > maxTweetCount  {
                tweetCount = 140
                enteredTextArray = Array(enteredTextArray[0..<maxTweetCount])
                tweetEntryTextField.text = String(enteredTextArray)
            }
            countdownLabel.text = String(maxTweetCount - tweetCount)
        }
    }
}
