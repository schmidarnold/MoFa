//
//  SprayProductCell.swift
//  MoFa
//
//  Created by Arnold Schmid on 07.09.15.
//  Copyright (c) 2015 Arnold Schmid. All rights reserved.
//

import UIKit

class SprayProductCell: UITableViewCell {

    @IBOutlet weak var productLabel: UILabel!
    
    @IBOutlet weak var amountLabel: UILabel!
    
    @IBOutlet weak var doseLabel: UILabel!
   
    
    @IBOutlet weak var trashButton: UIButton!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
