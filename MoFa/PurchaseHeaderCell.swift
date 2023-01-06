//
//  PurchaseHeaderCell.swift
//  MoFa
//
//  Created by Arnold Schmid on 12.12.15.
//  Copyright © 2015 Arnold Schmid. All rights reserved.
//

import UIKit

class PurchaseHeaderCell: UITableViewCell {

    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var addItemButton: UIButton!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
