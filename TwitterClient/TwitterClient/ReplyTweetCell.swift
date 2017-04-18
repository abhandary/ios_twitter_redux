//
//  ReplyTweetCell.swift
//  TwitterClient
//
//  Created by Akshay Bhandary on 4/16/17.
//  Copyright © 2017 AkshayBhandary. All rights reserved.
//

import UIKit

class ReplyTweetCell: TweetCell {

    @IBOutlet weak var replyingToScreennameLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override var tweet: Tweet! {
        didSet {
            updateCellOnTweetSet()
            
            if let inReplyToScreenname = tweet.inReplyToScreenname {
                var tweetText = self.tweetTextLabel.text!
                tweetText = tweetText.replacingOccurrences(of: "@\(inReplyToScreenname) ", with: "")
                self.tweetTextLabel.text =  tweetText
                self.replyingToScreennameLabel.text = "@\(inReplyToScreenname)"
            }
        }
    }


    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
