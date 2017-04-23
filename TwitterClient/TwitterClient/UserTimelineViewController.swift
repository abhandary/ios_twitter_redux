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
    @IBOutlet weak var page1LeadingConstraint: NSLayoutConstraint!
    var headerGROriginalPoint : CGPoint?
    var page1LeadingConstraintStart : CGFloat?
    
    @IBOutlet weak var topLevelViewToBottomConstraint: NSLayoutConstraint!
    
    // page control
    @IBOutlet weak var pageControl: UIPageControl!

        @IBOutlet weak var topLevelView: UIView!
    
    // header view and subviews
    @IBOutlet weak var headerViewBottomHalf: UIView!
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var headerViewTopHalf: UIView!
    @IBOutlet weak var backdropImageView: UIImageView!
    @IBOutlet weak var whiteViewAroundProfileImageView: UIView!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var numberTweetsLabel: UILabel!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var screenName: UILabel!
    @IBOutlet weak var numberFollowingLabel: UILabel!
    @IBOutlet weak var numberFollowersLabel: UILabel!
    @IBOutlet weak var userDescription: UILabel!
    @IBOutlet weak var blurViewForBackdrop: UIView!
    
    
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
    
    // MARK: - view setup and related
    override func viewDidLoad() {
        
        super.viewDidLoad()

        // setup gesture recognizers
        setupGestureRecognizers()
        
        // setup accounts view
        setupAccountsView()

        // setup table view, this is also done in super view
        self.tableView.delegate = self

        // setup header view
        setupHeaderView()
        
        // set profile image and backdrop image
        updateProfileHeader()
        
        // configure page control
        setupPageControl()
    }
    
    func setupHeaderView() {
        profileImageView.layer.cornerRadius = 5
        profileImageView.clipsToBounds = true
        whiteViewAroundProfileImageView.layer.cornerRadius = 5
        whiteViewAroundProfileImageView.clipsToBounds = true
    }
    
    func setupAccountsView() {
        accountsVC = AppDelegate.storyboard.instantiateViewController(withIdentifier: AppDelegate.kAccountsViewController) as? AccountsViewController
        accountsVC?.delegate = self
        accountsVCView = accountsVC?.view
        self.tabBarController?.view.addSubview(accountsVCView!)
        accountsVCView?.frame = (accountsVCView?.frame.offsetBy(dx: 0, dy: self.view.frame.size.height))!
        self.tabBarController?.addChildViewController(accountsVC!)
    }
    
    func setupGestureRecognizers() {
        // setup long press gesture recognizer
        let longPressGR = UILongPressGestureRecognizer(target: self, action: #selector(longPress))
        longPressGR.delegate = self
        self.tabBarController!.tabBar.addGestureRecognizer(longPressGR)
        
        
        let panGR = UIPanGestureRecognizer(target: self, action: #selector(headeriewPanGesture(_:)));
        headerViewBottomHalf.addGestureRecognizer(panGR)
        
        // setup tap gs on mask view
        let tapGS = UITapGestureRecognizer(target: self, action: #selector(maskViewTapped))
        maskView.addGestureRecognizer(tapGS)
        
        let headerTopPanGR = UIPanGestureRecognizer(target: self, action: #selector(headerViewTopHalfPanGesture(_:)))
        headerViewTopHalf.addGestureRecognizer(headerTopPanGR)
    }
    
    func setupPageControl() {
        self.pageControl.numberOfPages = 2
        self.pageControl.currentPage = 0
        self.pageControl.frame = self.headerView.frame
    }
    
    func updateProfileHeader() {
        
        // default to the current user is a user wasn't passed in
        user = user ?? UserAccountManagement.sharedInstance.currentUserAccount.user
        if let  user = user {
            if let profileURL = user.profileURL {
                profileImageView.setImageWith(profileURL)
            }
            
            if let profileBGURL = user.profileBackgroundURL {
                backdropImageView.setImageWith(profileBGURL)
            }
            
            userDescription.text = user.description
            
            userName.text = user.name
            screenName.text = "@\(user.screename!)"
            
            numberFollowersLabel.text = "0"
            if let followersCount = user.followersCount {
                if followersCount > 999 {
                    numberFollowersLabel.text = "\(followersCount / 1000) k"
                } else {
                    numberFollowersLabel.text = "\(followersCount)"
                }
            }
            
            numberFollowingLabel.text = "0"
            if let followingCount = user.followingCount {
                if followingCount > 999 {
                    numberFollowingLabel.text = "\(followingCount / 1000) k"
                } else {
                    numberFollowingLabel.text = "\(followingCount)"
                }
            }
        }
    }
    
    
    // MARK: - gesture recognizer handlers
    
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


    func headerViewTopHalfPanGesture(_ sender: UIPanGestureRecognizer) {
        let velocity = sender.velocity(in: self.view)
        let point = sender.translation(in: self.view)

        if sender.state == .began {
            headerGROriginalPoint = point
        } else if sender.state == .changed {
            if velocity.y > 0 {
                topLevelViewToBottomConstraint.constant = -point.y
                print(topLevelViewToBottomConstraint.constant)
            }
        } else {
            moveTopViewBackToOriginalPos()
        }
    }
    
    func moveTopViewBackToOriginalPos() {
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.4, animations: { 
                self.topLevelViewToBottomConstraint.constant = 0
                self.view.layoutIfNeeded()
            })
        }
    }
    
    func headeriewPanGesture(_ sender: UIPanGestureRecognizer) {
        
        let velocity = sender.velocity(in: self.view)
        let point = sender.translation(in: self.view)
        
        if sender.state == .began {
            headerGROriginalPoint = point
            page1LeadingConstraintStart = page1LeadingConstraint.constant
        } else if sender.state == .changed {
            
            if velocity.x > 0 {
                page1LeadingConstraint.constant = page1LeadingConstraintStart! + (point.x - headerGROriginalPoint!.x)
                if page1LeadingConstraint.constant > 0 {
                   page1LeadingConstraint.constant = 0
                } else {
                    let fraction = (-page1LeadingConstraint.constant / self.headerView.frame.width) * 0.3
                    self.blurViewForBackdrop.alpha = fraction
                }
            } else if velocity.x < 0 {
                
                if page1LeadingConstraint.constant > -self.headerView.frame.width {
                    page1LeadingConstraint.constant = point.x
                    let fraction = (-page1LeadingConstraint.constant / self.headerView.frame.width) * 0.3
                    self.blurViewForBackdrop.alpha = fraction
                }
            }
        } else {
            if velocity.x > 0 {
                moveHeader(left: true)
            } else {
                moveHeader(left: false)
            }
        }
    }

    
    func moveHeader(left : Bool) {
        UIView.animate(withDuration: 0.4) {
            if left == true {
                self.page1LeadingConstraint.constant = 0
                self.pageControl.currentPage = 0
                self.blurViewForBackdrop.alpha = 0.0
            } else {
                self.page1LeadingConstraint.constant = -self.headerView.frame.width
                self.pageControl.currentPage = 1
                self.blurViewForBackdrop.alpha = 0.3
            }
            self.headerView.layoutIfNeeded()
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


    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    // MARK: - navigation
    
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

    @IBAction func pageControlChanged(_ sender: UIPageControl) {
        moveHeader(left: sender.currentPage == 0)
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


