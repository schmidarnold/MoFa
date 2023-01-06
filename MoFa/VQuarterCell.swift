//
//  VQuarterCell.swift
//  ExpandTableView
//
//  Created by Arnold Schmid on 15.06.15.
//  Copyright (c) 2015 Arnold Schmid. All rights reserved.
//

import UIKit

class VQuarterCell: UITableViewCell {

    
    
    @IBOutlet weak var chkSelected: CheckBox!
    @IBOutlet weak var lblVQuarterName: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
