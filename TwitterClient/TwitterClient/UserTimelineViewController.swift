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

    
    @IBOutlet weak var headerViewBottomHalf: UIView!
    @IBOutlet weak var headerView: UIView!
    
    var user : User?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // default to the current user is a user wasn't passed in
        user = user ?? User.currentUser
        
        self.tableView.delegate = self

        // set profile image and backdrop image
        profileImageView.layer.cornerRadius = 5
        profileImageView.clipsToBounds = true
        whiteViewAroundProfileImageView.layer.cornerRadius = 5
        whiteViewAroundProfileImageView.clipsToBounds = true
        
        if let  user = user {
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
        
        if let user = user {
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
    
    override func thumbNailImageTapped(sender: TweetCell) {
        // self.performSegue(withIdentifier: kShowUserProfileSegue, sender: sender)
        print("thumbnail image tapped")
    }
   
    
    @IBAction func backButtonPressed(_ sender: UIButton) {
        print("back button tapped")
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        guard self.tweets != nil else { return; }
        guard self.tweets!.count > 0 else { return; }
        guard self.user != nil else { return; }
        
        // --- infinite scrolling ----
        if (!isMoreDataLoading) {
            // Calculate the position of one screen length before the bottom of the results
            let scrollViewContentHeight = tableView.contentSize.height
            let scrollOffsetThreshold = scrollViewContentHeight - tableView.bounds.size.height
            
            // When the user has scrolled past the threshold, start requesting
            if(scrollView.contentOffset.y > scrollOffsetThreshold && tableView.isDragging) {
                isMoreDataLoading = true
                let hud = MBProgressHUD.showAdded(to: self.view, animated: true);
                UserAccount.currentUserAccount?.fetchTweetsOlderThanLastFetch(user : user!,
                                                                              success: { (tweets) in
                    hud.hide(animated: true);
                    self.isMoreDataLoading = false
                    self.tweets?.append(contentsOf: tweets)
                    self.tableView.reloadData()
                    }, error: { (receivedError) in
                        self.isMoreDataLoading = false
                        hud.hide(animated: true);
                        // @todo: show error banner
                        print(receivedError)
                })
            }
        }
    }

}


