//
//  AccountsCell.swift
//  TwitterClient
//
//  Created by Akshay Bhandary on 4/19/17.
//  Copyright © 2017 AkshayBhandary. All rights reserved.
//

import UIKit


@objc protocol AccountsCellDelegate {
    func delete(sender : AccountsCell)
    func selected(sender: AccountsCell)
}

class AccountsCell: UITableViewCell {

    weak var delegate : AccountsCellDelegate?
    
    @IBOutlet weak var cellFGViewLeadingSpaceConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var thumbNailImage: UIImageView!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var userScreenName: UILabel!
    
    var gestureStaringPoint : CGPoint!
    
    var userAccount : UserAccount! {
        didSet {
            if let user = userAccount.user {
                thumbNailImage.setImageWith(user.profileURL!)
                userName.text = user.name
                userScreenName.text = user.screename
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        let panGR = UIPanGestureRecognizer(target: self, action: #selector(panGesture))
        self.contentView.addGestureRecognizer(panGR)
        // Initialization code
    }

    func panGesture(sender : UIPanGestureRecognizer) {
        let point = sender.translation(in: self.contentView)
        let velocity = sender.velocity(in: self.contentView)
        print(point)
        print(velocity)
        
        if sender.state == .began {
            gestureStaringPoint = point
        } else if sender.state == .changed {
            cellFGViewLeadingSpaceConstraint.constant = point.x - gestureStaringPoint.x
        } else {
            if velocity.x > 0 && point.x > self.contentView.frame.width * 0.8 {
                print("delete account")
                cellFGViewLeadingSpaceConstraint.constant = self.contentView.frame.width
            } else {
                // snap it back into place
                cellFGViewLeadingSpaceConstraint.constant = 0
                UIView.animate(withDuration: 1, animations: { 
                    self.contentView.setNeedsLayout()
                })
            }
        }
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        self.delegate?.selected(sender: self)
        // Configure the view for the selected state
    }

}
