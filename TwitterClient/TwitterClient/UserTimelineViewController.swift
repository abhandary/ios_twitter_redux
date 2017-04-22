//
//  UserTimelineViewController.swift
//  TwitterClient
//
//  Created by Akshay Bhandary on 4/18/17.
//  Copyright © 2017 AkshayBhandary. All rights reserved.
//

import UIKit
import MBProgressHUD

enum AccountViewState {
    case notPresented
    case partiallyPresented
    case presentedFullScreen
}

class UserTimelineViewController: TimeLineViewController, UIGestureRecognizerDelegate {

    let kAddAccountSegue   = "addAccountSegue"
    let kUserAccountsSegue = "userAccountsSegue"
    
    @IBOutlet weak var maskView: UIView!
    
    // top level view constraints
    @IBOutlet weak var topLevelViewToTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var topLevelViewTrailingSpaceConstraint: NSLayoutConstraint!
    @IBOutlet weak var topLevelViewLeadingSpaceConstraint: NSLayoutConstraint!
    
    
    
    @IBOutlet weak var topLevelView: UIView!
    
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
    
    // view list of accounts, to enable switching accounts
    var accountsVC : AccountsViewController?
    var accountsVCView : UIView?
    
    var user : User?
    

    override func viewWillAppear(_ animated: Bool) {
        if AppDelegate.showAccountView == true {
            showAccountsView()
        }
        AppDelegate.showAccountView = false
        super.viewWillAppear(animated)
    }

    
    var accountViewState : AccountViewState = .notPresented
    
    override func viewDidLoad() {
        
        
        // setup long press gesture recognizer
        let longPressGR = UILongPressGestureRecognizer(target: self, action: #selector(longPress))
        longPressGR.delegate = self
        self.tabBarController!.tabBar.addGestureRecognizer(longPressGR)
        

        let panGR = UIPanGestureRecognizer(target: self, action: #selector(headeriewPanGesture(_:)));
        headerView.addGestureRecognizer(panGR)
        
        // setup tap gs on mask view
        let tapGS = UITapGestureRecognizer(target: self, action: #selector(maskViewTapped))
        maskView.addGestureRecognizer(tapGS)
        
        // setup accounts view
        accountsVC = AppDelegate.storyboard.instantiateViewController(withIdentifier: AppDelegate.kAccountsViewController) as? AccountsViewController
        accountsVC?.delegate = self
        accountsVCView = accountsVC?.view
        self.tabBarController?.view.addSubview(accountsVCView!)
        accountsVCView?.frame = (accountsVCView?.frame.offsetBy(dx: 0, dy: self.view.frame.size.height))!
        self.tabBarController?.addChildViewController(accountsVC!)

        
        self.tableView.delegate = self

        // set profile image and backdrop image
        profileImageView.layer.cornerRadius = 5
        profileImageView.clipsToBounds = true
        whiteViewAroundProfileImageView.layer.cornerRadius = 5
        whiteViewAroundProfileImageView.clipsToBounds = true
        
        updateProfileHeader()
        
        // defer super till this view has been setup
        super.viewDidLoad()
        

        // Do any additional setup after loading the view.
    }
    
    func updateProfileHeader() {
        
        // default to the current user is a user wasn't passed in
        user = user ?? UserAccountManagement.sharedInstance.currentUserAccount.user
        if let  user = user {
            if let profileURL = user.profileURL {
                profileImageView.setImageWith(profileURL)
            }
            userName.text = user.name
            screenName.text = "@\(user.screename!)"
            
            numberFollowersLabel.text = "\(user.followersCount ?? 0)"
            numberFollowingLabel.text = "\(user.followingCount ?? 0)"
        }
    }
    
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return self.tabBarController!.tabBar.selectedItem!.tag == AppDelegate.kMeTab;
    }
    
    func longPress(gestureRecognizer: UIGestureRecognizer) {
        showAccountsView()
    }
    
    func showAccountsView() {
        
        guard accountViewState == .notPresented else { return; }
        
        accountsVC?.didMove(toParentViewController: self)
        
        maskView.backgroundColor = .black
        
        self.maskView.alpha = 0.3
        self.topLevelViewToTopConstraint.constant = 15
        self.topLevelViewLeadingSpaceConstraint.constant = 15
        self.topLevelViewTrailingSpaceConstraint.constant = 15
        
        accountViewState = .partiallyPresented
        
        UIView.animate(withDuration: 0.4) {
            
            self.view.layoutIfNeeded()
            let yOffset : CGFloat = (44.0 * 2.0).adding(CGFloat(55 * UserAccountManagement.sharedInstance.allAccounts.count)).adding(20)
            self.accountsVCView?.frame = (self.accountsVCView!.frame.offsetBy(dx: 0, dy: -yOffset))
        }
    }
    
    
    func maskViewTapped() {
        
        if let _ = accountsVC {

            self.maskView.alpha = 0.0
            self.topLevelViewToTopConstraint.constant = 0
            self.topLevelViewLeadingSpaceConstraint.constant = 0
            self.topLevelViewTrailingSpaceConstraint.constant = 0
            
            UIView.animate(withDuration: 0.4, animations: {

                    self.view.layoutIfNeeded()
                    let yOffset : CGFloat = (44.0 * 2.0).adding(CGFloat(55 * UserAccountManagement.sharedInstance.allAccounts.count)).adding(20)
                    self.accountsVCView?.frame = (self.accountsVCView!.frame.offsetBy(dx: 0, dy: yOffset))
                }, completion: { (boolVal) in
                    // self.accountsVCView?.removeFromSuperview()
                    // self.accountsVC?.removeFromParentViewController()
                    self.accountViewState = .notPresented
            })
        }
    }

    @IBAction func maskViewPanGesture(_ sender: UIPanGestureRecognizer) {
        
        let velocity = sender.velocity(in: self.view)
        let point = sender.translation(in: self.view)
        print(point)
        print(velocity)

            
    }

    func headeriewPanGesture(_ sender: UIPanGestureRecognizer) {
        
        let velocity = sender.velocity(in: self.view)
        let point = sender.translation(in: self.view)
        print(point)
        print(velocity)
        
        if sender.state == .began {
            if velocity.y > 0 {
                self.topLevelViewToTopConstraint.constant = -(self.headerView.frame.height - 44)
            } else {
                self.topLevelViewToTopConstraint.constant = 0
            }
        } else if sender.state == .changed {
            if point.y > 0 {
                self.topLevelViewToTopConstraint.constant = 0
            } else {
                self.topLevelViewToTopConstraint.constant = point.y
            }
        } else {
            moveHeader(collapse: velocity.y <= 0)
        }
    }

    
    func moveHeader(collapse : Bool) {
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.4, animations: { 
                if collapse == false {
                    self.topLevelViewToTopConstraint.constant = 0
                } else {
                    self.topLevelViewToTopConstraint.constant = -(self.headerView.frame.height - 44)
                }
                self.view.layoutIfNeeded()
            })
        }
    }
    
    override func reloadTable() {
        
        if let user = user {
            let hud = MBProgressHUD.showAdded(to: self.tableView, animated: true);
            UserAccountManagement.sharedInstance.currentUserAccount.fetchTweets(user : user, success: { (tweets) in
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

        print("thumbnail image tapped")
//        
//        let newUserTimeLineVC = AppDelegate.storyboard.instantiateViewController(withIdentifier: AppDelegate.kUserTimeLineViewController)
//        
//        let transition = CATransition()
//        transition.duration = 0.5
//        transition.type = kCATransitionPush
//        transition.subtype = kCATransitionFromRight
//        view.window!.layer.add(transition, forKey: kCATransition)
//        present(newUserTimeLineVC, animated: false, completion: nil)

    }
   
    
    @IBAction func backButtonPressed(_ sender: UIButton) {
        print("back button tapped")
        dismiss(animated: false, completion: nil)
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
                UserAccountManagement.sharedInstance.currentUserAccount.fetchTweetsOlderThanLastFetch(user : user!,
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

extension UserTimelineViewController : AccountsViewControllerDelegate {
    func accountsUpdated(sender : AccountsViewController) {
        
        // reset account vc view frame
        accountsVCView?.frame = self.view.frame.offsetBy(dx: 0, dy: self.view.frame.height)
        UIView.animate(withDuration: 0.4) {
            
            self.view.layoutIfNeeded()
            
            // update as per the number of accounts
            let yOffset : CGFloat = (44.0 * 2.0).adding(CGFloat(55 * UserAccountManagement.sharedInstance.allAccounts.count)).adding(20)
            self.accountsVCView?.frame = (self.accountsVCView!.frame.offsetBy(dx: 0, dy: -yOffset))
        }
    }
    
    func accountSwitched(sender : AccountsViewController, userAccount : UserAccount) {
        user = userAccount.user
        reloadTable()
        updateProfileHeader()
        maskViewTapped()
    }
}


