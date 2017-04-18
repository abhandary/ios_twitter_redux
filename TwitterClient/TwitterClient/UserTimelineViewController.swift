//
//  UserTimelineViewController.swift
//  TwitterClient
//
//  Created by Akshay Bhandary on 4/18/17.
//  Copyright © 2017 AkshayBhandary. All rights reserved.
//

import UIKit
import MBProgressHUD

class UserTimelineViewController: TimeLineViewController {

    @IBOutlet weak var backdropImageView: UIImageView!
    @IBOutlet weak var whiteViewAroundProfileImageView: UIView!
    @IBOutlet weak var profileImageView: UIImageView!
    
    @IBOutlet weak var numberTweetsLabel: UILabel!
    
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var screenName: UILabel!
    @IBOutlet weak var numberFollowingLabel: UILabel!
    
    @IBOutlet weak var numberFollowersLabel: UILabel!
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.register(TweetCell.self, forCellReuseIdentifier: "TweetCell")
        self.tableView.register(ReplyTweetCell.self, forCellReuseIdentifier: "ReplyTweetCell")
        self.tableView.register(RetweetCell.self, forCellReuseIdentifier: "RetweetCell")
        
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

        
        reloadTable()
        
        // Do any additional setup after loading the view.
    }
    
    override func reloadTable() {
        
        let hud = MBProgressHUD.showAdded(to: self.view, animated: true);
        
        if let user = User.currentUser {
            UserAccount.currentUserAccount?.fetchTweets(user : user, success: { (tweets) in
                hud.hide(animated: true);
                self.tweets = tweets
                self.refreshControl.endRefreshing()
                self.tableView.reloadData()
                }, error: { (receivedError) in
                    hud.hide(animated: true);
                    ViewUtils.showToast(view: self.networkErrorView)
                    self.refreshControl.endRefreshing()
                    print(receivedError)
            })
        }
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


