//
//  infoCollectionViewCell.swift
//  LawHub
//
//  Created by Dylan Aird on 2/04/2016.
//  Copyright © 2016 Dylan Aird. All rights reserved.
//

import UIKit

class infoCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var randomHeader: UILabel!
    @IBOutlet weak var randomTextField: UITextView!
    
    @IBInspectable var cornerRadius: CGFloat = 2
    
    @IBInspectable var shadowOffsetWidth: Int = 0
    @IBInspectable var shadowOffsetHeight: Int = 3
    @IBInspectable var shadowColor: UIColor? = UIColor.blackColor()
    @IBInspectable var shadowOpacity: Float = 0.5
    
    override func layoutSubviews() {
        layer.cornerRadius = cornerRadius
        let shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: cornerRadius)
        
        layer.masksToBounds = false
        layer.shadowColor = shadowColor?.CGColor
        layer.shadowOffset = CGSize(width: shadowOffsetWidth, height: shadowOffsetHeight);
        layer.shadowOpacity = shadowOpacity
        layer.shadowPath = shadowPath.CGPath
        
        //this resizes all the sub views to the cell size

        self.contentView.frame = self.bounds;
    }
    
}
