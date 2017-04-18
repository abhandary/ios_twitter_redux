//
//  HamburgerContentSegue.swift
//  TwitterClient
//
//  Created by Akshay Bhandary on 4/17/17.
//  Copyright © 2017 AkshayBhandary. All rights reserved.
//

import UIKit



class HamburgerContentSegue: UIStoryboardSegue {

    static let kHamburgerContentSegue = "HamburgerContentSegue"
    
    override var identifier: String? {
        get {
            return HamburgerContentSegue.kHamburgerContentSegue
        }
    }

    override func perform() {
        if let hamburgerVC = self.source as? HamburgerViewController {
            self.destination.view.frame = hamburgerVC.contentView.frame
            hamburgerVC.contentView.addSubview(self.destination.view)
            hamburgerVC.addChildViewController(self.destination)
            self.destination.didMove(toParentViewController: hamburgerVC)
        }
    }
}
