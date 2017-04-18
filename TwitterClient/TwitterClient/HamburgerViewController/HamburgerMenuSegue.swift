//
//  HamburgerMenuSegue.swift
//  TwitterClient
//
//  Created by Akshay Bhandary on 4/17/17.
//  Copyright © 2017 AkshayBhandary. All rights reserved.
//

import UIKit

class HamburgerMenuSegue: UIStoryboardSegue {
    
    
    static let kHamburgerMenuSegue = "HamburgerMenuSegue"
    
    override var identifier: String? {
        get {
            return HamburgerMenuSegue.kHamburgerMenuSegue
        }
    }
    
    override func perform() {
        
        if let hamburgerVC = self.source as? HamburgerViewController {
            self.destination.view.frame = hamburgerVC.menuView.frame
            hamburgerVC.menuView.addSubview(self.destination.view)
            hamburgerVC.addChildViewController(self.destination)
            self.destination.didMove(toParentViewController: hamburgerVC)
        }
    }
}
