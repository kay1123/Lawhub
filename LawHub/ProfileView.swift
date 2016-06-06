//
//  ProfileView.swift
//  LawHub
//
//  Created by Dylan Aird on 6/04/2016.
//  Copyright © 2016 Dylan Aird. All rights reserved.
//

import UIKit

class ProfileView: UIViewController {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet var baseView: UIView!
    var Height: CGFloat?
    var Width: CGFloat?
    var profileId:String! = ""
    var model:LawyerModel!
    
    @IBOutlet weak var viewWidth: NSLayoutConstraint!
    @IBOutlet weak var viewHeight: NSLayoutConstraint!
    
    //Ui Elements
    @IBOutlet weak var UIImageProfileImage: UIImageView!
    @IBOutlet weak var UILabelName: UILabel!
    @IBOutlet weak var UILabelLanguages: UILabel!
    @IBOutlet weak var UITextViewSpecialties: UITextView!
    
    @IBOutlet weak var UITextViewAwards: UITextView!
    
    @IBOutlet weak var UITextViewBio: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //set UI Constraints
        self.navigationItem.setHidesBackButton(true, animated: false)
        let scrollSize = CGSizeMake(Width!, scrollView.contentSize.height)
        scrollView.contentSize = scrollSize
        
        //load the lawyer from the memory model
        model = SingletonModel.sharedManager.getLawyerWithId(profileId)
        
        UILabelName.text = model.getName()
        UIImageProfileImage.image = self.resizeImage(model.getImage(), newHeight: 150.0)
        UIImageProfileImage.layer.cornerRadius = UIImageProfileImage.frame.size.width / 3
        UIImageProfileImage.clipsToBounds = true
        //UIImageProfileImage.image = model.getImage() as! UIImage
        UILabelLanguages.text = model.getLanguages()
        UITextViewSpecialties.text = model.getSpecialties()
        UITextViewAwards.text = model.getAwards()
        UITextViewBio.text = model.getBio()
        

        //load the ui elements of the lawyers profile
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func resizeImage(image: UIImage, newHeight: CGFloat) -> UIImage {
        
        let scale = newHeight / image.size.height
        let newWidth = image.size.width * scale
        UIGraphicsBeginImageContext(CGSizeMake(newWidth, newHeight))
        image.drawInRect(CGRectMake(0, 0, newWidth, newHeight))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage
    }

}

