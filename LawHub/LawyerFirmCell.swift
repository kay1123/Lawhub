//
//  LawyerFirmCell.swift
//  LawHub
//
//  Created by Dylan Aird on 3/04/2016.
//  Copyright © 2016 Dylan Aird. All rights reserved.
//

import UIKit

class LawyerFirmCell: UITableViewCell {
    
    @IBOutlet weak var firmNameLabel: UILabel!
    
    @IBOutlet weak var firmPhoneNumber: UILabel!
    @IBOutlet weak var UIButtonMap: UIButton!
    
    @IBOutlet weak var UIButtonLawyer: UIButton!

    @IBOutlet weak var UIButtonWeb: UIButton!
    
    @IBOutlet weak var UIButtonPhone: UIButton!
    @IBOutlet weak var firmDistance: UILabel!
    @IBOutlet weak var firmWebsite: UILabel!
    @IBOutlet weak var firmSpecialties: UITextView!
    @IBOutlet weak var firmHours: UILabel!
    var id:String = ""
    var isObserving = false;
    class var expandedHeight: CGFloat { get { return 250 } }
    class var defaultHeight: CGFloat  { get { return 50  } }
    
    func checkHeight() {
        //datePicker.hidden = (frame.size.height < LawyerFirmCell.expandedHeight)
    }
    
    func watchFrameChanges() {
        if !isObserving {
            addObserver(self, forKeyPath: "frame", options: [NSKeyValueObservingOptions.New, NSKeyValueObservingOptions.Initial], context: nil)
            isObserving = true;
        }
    }
    
    func ignoreFrameChanges() {
        if isObserving {
            removeObserver(self, forKeyPath: "frame")
            isObserving = false;
        }
    }
    
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        if keyPath == "frame" {
            checkHeight()
        }
    }
}


