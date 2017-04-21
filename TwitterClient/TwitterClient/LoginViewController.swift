//
//  ViewController.swift
//  TwitterClient
//
//  Created by Akshay Bhandary on 4/12/17.
//  Copyright © 2017 AkshayBhandary. All rights reserved.
//

import UIKit
import SafariServices



class LoginViewController: UIViewController {

    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var signInButton: UIButton!

    static let kNotificationUserLoggedIn = "kNotificationUserLoggedIn"
    let kShowUserTimeLineSegue = "showUserTimeLineSegue"
    let kTwitterSignUpURL = "https://mobile.twitter.com/signup"
    
    var addAccountVC : AddAccountViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        signUpButton.layer.cornerRadius = 5
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    @IBAction func signUpButtonPressed(_ sender: UIButton) {
        
        presentAddAccountVC(url: URL(string: kTwitterSignUpURL))
    }
    
    @IBAction func signInButtonPressed(_ sender: UIButton) {
        

        UserAccountManagement.sharedInstance.currentUserAccount.loginUser(success: { () in
            
                if let addAccountVC = self.addAccountVC {

                    addAccountVC.dismiss(animated: true, completion: {
                        // self.performSegue(withIdentifier: self.kShowUserTimeLineSegue, sender: self);
                        NotificationCenter.default.post(name: Notification.Name(rawValue: LoginViewController.kNotificationUserLoggedIn), object: self)
                    })
                } else {
                    // self.performSegue(withIdentifier: self.kShowUserTimeLineSegue, sender: self);
                    NotificationCenter.default.post(name: Notification.Name(rawValue: LoginViewController.kNotificationUserLoggedIn), object: self)
                }
            }, error: { (error) in
                self.addAccountVC?.dismiss(animated: true, completion: nil)
            }) { (requestTokenURL) in
                self.receivedRequestToken(url: requestTokenURL)
        }
    }
    
    func receivedRequestToken(url: URL?) {
        presentAddAccountVC(url: url)
    }
    
    func presentAddAccountVC(url : URL?) {
        addAccountVC = AppDelegate.storyboard.instantiateViewController(withIdentifier: AppDelegate.kAddAccountViewController)  as? AddAccountViewController
        addAccountVC?.url = url
        self.present(addAccountVC!, animated: true, completion: nil);
    }
    
    @IBAction func prepareForUnwind(segue : UIStoryboardSegue) {
        
    }
}


