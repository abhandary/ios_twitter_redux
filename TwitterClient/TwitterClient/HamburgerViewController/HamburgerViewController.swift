//
//  HamburgerViewController.swift
//  TwitterClient
//
//  Created by Akshay Bhandary on 4/17/17.
//  Copyright © 2017 AkshayBhandary. All rights reserved.
//

import UIKit

class HamburgerViewController: UIViewController {

    
    @IBOutlet weak var menuView: UIView!
    @IBOutlet weak var contentView: UIView!
    
    var menuViewController : UIViewController?
    var contentViewController : UIViewController?

    
    @IBOutlet weak var contentViewLeadingConstraint: NSLayoutConstraint!
    
    var originalLeftMargin : CGFloat!
    
    let kRevealViewEndYOffset : CGFloat = 50.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.performSegue(withIdentifier: HamburgerMenuSegue.kHamburgerMenuSegue, sender: self)
        self.performSegue(withIdentifier: HamburgerContentSegue.kHamburgerContentSegue, sender: self)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
 
    @IBAction func panGesture(_ sender: UIPanGestureRecognizer) {
        let translation = sender.translation(in: view)
        let velocity = sender.velocity(in: view)
        
        if sender.state == UIGestureRecognizerState.began {
            originalLeftMargin = contentViewLeadingConstraint.constant
        } else if sender.state == UIGestureRecognizerState.changed {
            if translation.x >= 0 {
                contentViewLeadingConstraint.constant = originalLeftMargin + translation.x
            } else {
                contentViewLeadingConstraint.constant = 0
            }
        } else {
            if velocity.x > 0 { 
                UIView.animate(withDuration: 2, animations: {
                    self.contentViewLeadingConstraint.constant = self.view.frame.size.width - self.kRevealViewEndYOffset
                })
            } else {
                UIView.animate(withDuration: 2, animations: {
                    self.contentViewLeadingConstraint.constant = 0
                })

            }
        }
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
