//
//  AccountsCell.swift
//  TwitterClient
//
//  Created by Akshay Bhandary on 4/19/17.
//  Copyright © 2017 AkshayBhandary. All rights reserved.
//

import UIKit

class AccountsCell: UITableViewCell {

    @IBOutlet weak var thumbNailImage: UIImageView!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var userScreenName: UILabel!
    
    var user : User! {
        didSet {
            thumbNailImage.setImageWith(user.profileURL!)
            userName.text = user.name
            userScreenName.text = user.screename
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
