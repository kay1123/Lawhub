//
//  RecentArticlesViewController.swift
//  LawHub
//
//  Created by Dylan Aird on 1/04/2016.
//  Copyright © 2016 Dylan Aird. All rights reserved.
//

import UIKit

class RecentArticlesViewController: UIViewController {
    

    @IBOutlet weak var UIWebViewContents: UIWebView!
    
    var articleName:String = ""
    var articleContents: String = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        UIWebViewContents.loadHTMLString(articleContents, baseURL: nil)

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
