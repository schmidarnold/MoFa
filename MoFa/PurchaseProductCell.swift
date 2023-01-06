//
//  PurchasePruductCell.swift
//  MoFa
//
//  Created by Arnold Schmid on 12.12.15.
//  Copyright © 2015 Arnold Schmid. All rights reserved.
//

import UIKit

class PurchaseProductCell: UITableViewCell {

    @IBOutlet weak var productLabel: UILabel!
    
    @IBOutlet weak var amountLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
