//
//  SoilFertCell.swift
//  MoFa
//
//  Created by Arnold Schmid on 24.11.15.
//  Copyright © 2015 Arnold Schmid. All rights reserved.
//

import UIKit

class SoilFertCell: UITableViewCell {

    @IBOutlet weak var productLabel: UILabel!
    
    @IBOutlet weak var amountLabel: UILabel!
    
    @IBOutlet weak var amountHaLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
