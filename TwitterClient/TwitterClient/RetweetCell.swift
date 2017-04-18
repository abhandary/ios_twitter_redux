//
//  RetweetCell.swift
//  TwitterClient
//
//  Created by Akshay Bhandary on 4/14/17.
//  Copyright © 2017 AkshayBhandary. All rights reserved.
//

import UIKit

class RetweetCell: TweetCell {

    @IBOutlet weak var retweetUserScreenName: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override var tweet: Tweet! {
        didSet {
            updateCellOnTweetSet()
            retweetUserScreenName.text = "Retweeted"
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
