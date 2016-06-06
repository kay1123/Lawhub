//
//  TodayTableViewCell.swift
//  LawHub
//
//  Created by Dylan Aird on 19/05/2016.
//  Copyright © 2016 Dylan Aird. All rights reserved.
//

import UIKit

class TodayTableViewCell: UITableViewCell {

    @IBOutlet weak var UILabelName: UILabel!
    @IBOutlet weak var UILabelDate: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
