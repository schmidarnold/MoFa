//
//  AnlagenCell.swift
//  ExpandTableView
//
//  Created by Arnold Schmid on 12.06.15.
//  Copyright (c) 2015 Arnold Schmid. All rights reserved.
//

import UIKit

class AnlagenCell: UITableViewCell {

    @IBOutlet weak var chkAnlage: CheckBox!
    @IBOutlet weak var lblAnlagenNamen: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
