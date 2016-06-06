
//
//  RecentArticlesViewController.swift
//  LawHub
//
//  Created by Dylan Aird on 1/04/2016.
//  Copyright © 2016 Dylan Aird. All rights reserved.
//

import UIKit

class SubInfo: UIViewController {
    

    @IBOutlet weak var UIWebViewInfo: UIWebView!
    
    var subInfoName:String = ""
    var subInfoText: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = subInfoName;
        UIWebViewInfo.loadHTMLString(subInfoText, baseURL: nil)
        
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
