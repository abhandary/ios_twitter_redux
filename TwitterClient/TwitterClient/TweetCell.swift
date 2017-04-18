//
//  TweetCell.swift
//  TwitterClient
//
//  Created by Akshay Bhandary on 4/13/17.
//  Copyright © 2017 AkshayBhandary. All rights reserved.
//

import UIKit

@objc protocol TweetCellDelegate {
    func retweetTapped(sender : TweetCell)
    func favoriteTapped(sender : TweetCell)
    func replyTapped(sender : TweetCell)
}

class TweetCell: UITableViewCell {

    let kFavoritedImage = "favorite_heart"
    let kUnfavoritedImage = "unfavorite_heart"

    let kRetweetedImage = "retweeted"
    let kNotRetweetedImage = "notretweeted"

    
    weak var delegate : TweetCellDelegate?
    
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var handle: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var tweetTextLabel: UILabel!

    @IBOutlet weak var thumbNailImage: UIImageView!
    
    // replay image
    @IBOutlet weak var replyImageView: UIImageView!
    
    // retweet image + label
    @IBOutlet weak var retweetImageView: UIImageView!
    @IBOutlet weak var retweetCountLabel: UILabel!
    
    // favorite image + label
    @IBOutlet weak var favoriteImage: UIImageView!
    @IBOutlet weak var favoriteLabel: UILabel!
    
    var tweet : Tweet! {
        didSet {
            updateCellOnTweetSet()
        }
    }
    
    func updateCellOnTweetSet() {
        // tweet text
        tweetTextLabel.text = tweet.text
        
        // user name and screenname
        name.text = tweet.user?.name
        if let screenname = tweet.user?.screename {
            handle.text = "@\(screenname)"
        }
        
        // thumbnail
        if let user = tweet.user,
            let imageURL = user.profileURL {
            self.thumbNailImage.setImageWith(URLRequest(url: imageURL),
                                             placeholderImage: nil,
                                             success: { (request, imageResponse, image) in
                                                if imageResponse != nil {
                                                    
                                                    self.thumbNailImage?.alpha = 0.0
                                                    self.thumbNailImage?.image = image
                                                    self.thumbNailImage?.contentMode = UIViewContentMode.scaleToFill
                                                    UIView.animate(withDuration: 0.3, animations: { () -> Void in
                                                        self.thumbNailImage?.alpha = 1.0
                                                    })
                                                } else {
                                                    self.thumbNailImage?.image = image
                                                    self.thumbNailImage?.contentMode = UIViewContentMode.scaleToFill
                                                }
                                                self.thumbNailImage.layer.cornerRadius = 5
                                                self.thumbNailImage.clipsToBounds = true
                }, failure: { (request, response, error) in
                    print(error)
            })
            
        }
        
        // update favorite text and image
        updateFavoritesDisplay()
        
        // update retweet text and image
        updateRetweetDisplay()
        
        // time label
        timeLabel.text = tweet.timeString()
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let retweetTapGS = UITapGestureRecognizer(target: self, action: #selector(retweetTapped))
        self.retweetImageView.isUserInteractionEnabled = true
        self.retweetImageView?.addGestureRecognizer(retweetTapGS)
        
        let favoriteTapGS = UITapGestureRecognizer(target: self, action: #selector(favoriteTapped))
        self.favoriteImage.isUserInteractionEnabled = true
        self.favoriteImage?.addGestureRecognizer(favoriteTapGS)
        
        let replyTapGS = UITapGestureRecognizer(target: self, action: #selector(replyTapped))
        self.replyImageView.isUserInteractionEnabled = true
        self.replyImageView?.addGestureRecognizer(replyTapGS)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    
    func replyTapped() {
        self.delegate?.replyTapped(sender: self)
    }
    
    func retweetTapped() {
        self.delegate?.retweetTapped(sender: self)
    }
    
    func favoriteTapped() {
        self.delegate?.favoriteTapped(sender: self)
    }

    func updateRetweetDisplay() {
        
        retweetCountLabel.text = String(tweet.retweetCount!)
        
        ViewUtils.transition(imageView: retweetImageView,
                             imageNamed: tweet.retweeted! == true ? kRetweetedImage : kNotRetweetedImage,
                             duration: 0.1)
        
        self.setNeedsDisplay()
    }

    func updateFavoritesDisplay() {
        
        // likes count
        if let likes = tweet.favoritesCount {
            favoriteLabel.text = String(likes)
        }
        
        // update favorite image as per favorite state
        ViewUtils.transition(imageView: favoriteImage,
                             imageNamed: tweet.favorited! == true ? kFavoritedImage : kUnfavoritedImage,
                             duration: 0.1)
        

        self.setNeedsDisplay()
    }

    
}
