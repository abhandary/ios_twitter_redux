//
//  MenuViewController.swift
//  TwitterClient
//
//  Created by Akshay Bhandary on 4/17/17.
//  Copyright © 2017 AkshayBhandary. All rights reserved.
//

import UIKit

class MenuViewController: UITableViewController {

    let kSectionTimelines = 0
    let kSectionApplication = 1
    let kSectionSettings = 2
    
    let kHomeTimeline = 0
    let kMentions     = 1
    
    let kSettingsAccounts = 0
    let kSettingsAbout    = 1
    let kSettingsLogout   = 2
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func getTabBarController() -> UITabBarController? {
        
        if let hamburgerVC = self.view.window?.rootViewController as? HamburgerViewController {
            for controller in hamburgerVC.childViewControllers {
                if controller.isKind(of: UITabBarController.self) {
                    return controller as? UITabBarController
                }
            }
        }
        return nil;
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch  indexPath.section {
        case kSectionTimelines:
            if indexPath.row == 0 {
                getTabBarController()?.selectedIndex = AppDelegate.kHomeTab
            } else {
                getTabBarController()?.selectedIndex = AppDelegate.kMentionsTab
            }
        case kSectionApplication:
            getTabBarController()?.selectedIndex = AppDelegate.kMeTab
        default:
            if indexPath.row == kSettingsAccounts {
                
            } else if indexPath.row == kSettingsAbout {
                
            } else if indexPath.row == kSettingsLogout {
                logout()
            }

        }
        
        self.tableView.deselectRow(at: indexPath, animated: true)
        if let hamburgerVC = self.view.window?.rootViewController as? HamburgerViewController {
            hamburgerVC.toggleLeft()
        }

    }
    
    func logout() {
        let userAccount = UserAccountManagement.sharedInstance.currentUserAccount
        userAccount?.logOutUser()
        UserAccountManagement.sharedInstance.currentUserAccount = nil
        NotificationCenter.default.post(name: Notification.Name(rawValue: TimeLineViewController.kNotificationUserLoggedOut), object: self)
    }
    
}



