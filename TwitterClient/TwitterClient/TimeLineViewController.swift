//
//  TimeLineViewController.swift
//  TwitterClient
//
//  Created by Akshay Bhandary on 4/13/17.
//  Copyright © 2017 AkshayBhandary. All rights reserved.
//

import UIKit
import MBProgressHUD


class TimeLineViewController: UIViewController  {

    
    static let kNotificationUserLoggedOut = "kNotificationUserLoggedOut"
    let kTweetDetailSegue = "tweetDetailSegue"
    let kTweetDetailSegueFromReplyToCell = "tweetDetailSegueFromReplyToCell"
    let kTweetDetailSegueFromRetweetCell = "tweetDetailSegueFromRetweet"
    let kTweetComposeSegue = "tweetComposeSegue"
    let kTweetReplySegue = "tweetReplySegue"
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var networkErrorView: UIView!
    var tweets : [Tweet]?
    var refreshControl : UIRefreshControl!

 
    // for table view infiite scrolling
    var isMoreDataLoading = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.refreshControl = UIRefreshControl();
        refreshControl.addTarget(self, action: #selector(reloadTable), for: UIControlEvents.allEvents)
        
        self.tableView.addSubview(refreshControl)
        
        self.tableView.dataSource = self
        self.tableView.delegate = self
        
        self.tableView.estimatedRowHeight = 200
        self.tableView.rowHeight = UITableViewAutomaticDimension
        
        self.networkErrorView.isHidden = true
        reloadTable()
        
    }


    func reloadTable() {
        let hud = MBProgressHUD.showAdded(to: self.view, animated: true);

        UserAccount.currentUserAccount?.fetchTweets(success: { (tweets) in
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
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func logOutButtonPressed(_ sender: AnyObject) {
        User.currentUser = nil
        UserAccount.currentUserAccount = nil
        
        // currently only the AppDelegate listens to this notification, this is required because the current
        // implementation swaps root view controllers. The use of delegates is not straightforward in this implementation
        NotificationCenter.default.post(name: Notification.Name(rawValue: TimeLineViewController.kNotificationUserLoggedOut), object: self)
    }

    // MARK: - Navigation
    @IBAction func prepareForUnwind(segue: UIStoryboardSegue) {
        if segue.identifier! == TweetComposeViewController.kUnwindToTimeLineViewSegue {
            if let composeVC = segue.source as? TweetComposeViewController,
                let postedTweet = composeVC.postedTweet {
                self.tweets?.insert(postedTweet, at: 0)
                self.tableView.reloadData()
            }
        }
    }
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == kTweetDetailSegue ||
           segue.identifier == kTweetDetailSegueFromReplyToCell ||
            segue.identifier == kTweetDetailSegueFromRetweetCell,
            let cell = sender as? TweetCell,
            let detailVC = segue.destination as? TweetDetailViewController,
            let indexPath = self.tableView.indexPath(for: cell) {
            self.tableView.deselectRow(at: indexPath, animated: true)
            detailVC.tweet = self.tweets![indexPath.row]
            detailVC.tweetCell = cell
        }
        
        else if segue.identifier == kTweetReplySegue,
            let cell = sender as? TweetCell,
            let navVC = segue.destination as? UINavigationController,
            let composeVC = navVC.topViewController as? TweetComposeViewController,
            let tweetID = cell.tweet.tweetID {
            
            composeVC.inReplyToID = tweetID
            composeVC.inReplyToScreenName = cell.tweet.user?.screename
        }
    }
}



extension TimeLineViewController : TweetCellDelegate {
    
    func retweetTapped(sender : TweetCell) {

        let retweetSuccessBlock : (Tweet) -> () = { (receivedTweet)  in
            sender.tweet.updateWith(tweet: receivedTweet)
            sender.updateRetweetDisplay()
            // self.tweets?.insert(receivedTweet, at: 0)
            // self.tableView.reloadData()
        }

        let unretweetSuccessBlock : (Tweet) -> () = { (receivedTweet)  in
            sender.tweet.updateWith(tweet: receivedTweet)
            sender.updateRetweetDisplay()
        }

        
        let errorBlock : (Error)->() = { (error) in
            ViewUtils.showToast(view: self.networkErrorView)
        }

        
        if  let tweetID = sender.tweet.tweetID {
            if sender.tweet.retweeted == false {
                UserAccount.currentUserAccount?.post(retweetID: tweetID, success: retweetSuccessBlock, error: errorBlock)
            } else {
                if let originalTweetIDStr = sender.tweet.originalTweetID,
                    let originalID = Int(originalTweetIDStr) {
                    UserAccount.currentUserAccount?.post(unretweetID: originalID, success: unretweetSuccessBlock, error: errorBlock)
                } else {
                    errorBlock(NSError(domain: "No original ID in retweet", code: 0, userInfo: nil))
                }
            }
        }
    }
    
    func favoriteTapped(sender: TweetCell) {
        
        if  let tweetID = sender.tweet.tweetID {
            
            let successBlock : (Tweet) -> () = { (receivedTweet)  in
                sender.tweet.updateWith(tweet: receivedTweet)
                sender.updateFavoritesDisplay()
            }
            
            let errorBlock : (Error)->() = { (error) in
                ViewUtils.showToast(view: self.networkErrorView)
            }

            if sender.tweet.favorited! == true {
                UserAccount.currentUserAccount?.post(unfavoriteTweetID: tweetID, success:successBlock, error: errorBlock)
            } else {
                UserAccount.currentUserAccount?.post(favoriteTweetID: tweetID, success: successBlock, error:errorBlock)
            }
        }
    }
    
    func replyTapped(sender: TweetCell) {
        self.performSegue(withIdentifier: kTweetReplySegue, sender: sender)
    }
}

extension TimeLineViewController : UITableViewDelegate, UITableViewDataSource {
    

    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.tweets?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let tweet = self.tweets![indexPath.row]
        
        if tweet.retweeted! == true {
            let cell = self.tableView.dequeueReusableCell(withIdentifier: "RetweetCell") as! RetweetCell
            cell.tweet = self.tweets![indexPath.row]
            cell.delegate = self
            return cell
        } else if let _ = tweet.inReplyToScreenname,
            let userID = tweet.user!.userID,
            userID == User.currentUser!.userID! {
            let cell = self.tableView.dequeueReusableCell(withIdentifier: "ReplyTweetCell") as! ReplyTweetCell
            cell.tweet = self.tweets![indexPath.row]
            cell.delegate = self
            return cell
        }
        else {
            let cell = self.tableView.dequeueReusableCell(withIdentifier: "TweetCell") as! TweetCell
            cell.tweet = self.tweets![indexPath.row]
            cell.delegate = self
            return cell
        }
    }
    
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
 
        guard self.tweets != nil else { return; }
        guard self.tweets!.count > 0 else { return; }
    
        
        // --- infinite scrolling ----
        if (!isMoreDataLoading) {
            // Calculate the position of one screen length before the bottom of the results
            let scrollViewContentHeight = tableView.contentSize.height
            let scrollOffsetThreshold = scrollViewContentHeight - tableView.bounds.size.height
            
            // When the user has scrolled past the threshold, start requesting
            if(scrollView.contentOffset.y > scrollOffsetThreshold && tableView.isDragging) {
                isMoreDataLoading = true
                let hud = MBProgressHUD.showAdded(to: self.view, animated: true);
                UserAccount.currentUserAccount?.fetchTweetsOlderThanLastFetch(success: { (tweets) in
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
