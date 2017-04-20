//
//  AddAccountViewController.swift
//  TwitterClient
//
//  Created by Akshay Bhandary on 4/20/17.
//  Copyright © 2017 AkshayBhandary. All rights reserved.
//

import UIKit

class AddAccountViewController: UIViewController {

    @IBOutlet weak var webView: UIWebView!
    
    var url : URL?
    
    override func viewDidLoad() {
        super.viewDidLoad()

       // URLCache.shared.removeAllCachedResponses()
       // URLCache.shared.diskCapacity = 0
       // URLCache.shared.memoryCapacity = 0
        
        if let url = url {
            webView.loadRequest(URLRequest(url: url))
        }
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
