//
//  MenuViewController.swift
//  TwitterClient
//
//  Created by Akshay Bhandary on 4/17/17.
//  Copyright © 2017 AkshayBhandary. All rights reserved.
//

import UIKit

class MenuViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    let kHamburgerMenuTableViewCell = "HamburgerMenuTableViewCell"
    
    let menuItems = ["Profile", "Timeline", "Mentions", "Accounts", "Logout"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let count = CGFloat(self.menuItems.count)
        self.tableView.rowHeight = self.view.frame.height / count
        self.tableView.delegate = self
        self.tableView.dataSource = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension MenuViewController : UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.menuItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: kHamburgerMenuTableViewCell)!
        cell.textLabel?.text = menuItems[indexPath.row]
        return cell
    }
    
}


