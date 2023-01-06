//
//  WorkCell.swift
//  MoFa
//
//  Created by Arnold Schmid on 06.01.16.
//  Copyright © 2016 Arnold Schmid. All rights reserved.
//

import UIKit

class WorkCell: UITableViewCell {

    @IBOutlet weak var detailsHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var lblWorkDesc: UILabel!
    @IBOutlet weak var lblWorkInfo: UILabel!
    var showDetails : Bool = false {
        didSet {
            if (showDetails) {
               self.detailsHeightConstraint.priority = UILayoutPriority(rawValue: 250)
            } else {
               self.detailsHeightConstraint.priority = UILayoutPriority(rawValue: 999)
            }
        }
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        self.showDetails = false
        self.detailsHeightConstraint.constant = 0
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
