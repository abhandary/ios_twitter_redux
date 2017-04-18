//
//  UserTimelineViewController.swift
//  TwitterClient
//
//  Created by Akshay Bhandary on 4/18/17.
//  Copyright © 2017 AkshayBhandary. All rights reserved.
//

import UIKit

class UserTimelineViewController: UIViewController {

    @IBOutlet weak var backdropImageView: UIImageView!
    @IBOutlet weak var whiteViewAroundProfileImageView: UIView!
    @IBOutlet weak var profileImageView: UIImageView!
    
    @IBOutlet weak var numberTweetsLabel: UILabel!
    
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var screenName: UILabel!
    @IBOutlet weak var numberFollowingLabel: UILabel!
    
    @IBOutlet weak var numberFollowersLabel: UILabel!
    
    @IBOutlet weak var tableView: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        profileImageView.layer.cornerRadius = 5
        profileImageView.clipsToBounds = true
        whiteViewAroundProfileImageView.layer.cornerRadius = 5
        whiteViewAroundProfileImageView.clipsToBounds = true
        
        if let  user = User.currentUser {
            if let profileURL = user.profileURL {
                profileImageView.setImageWith(profileURL)
            }
            userName.text = user.name
            screenName.text = user.screename
            
            numberFollowersLabel.text = "\(user.followersCount ?? 0)"
            numberFollowingLabel.text = "\(user.followingCount ?? 0)"
        }

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
