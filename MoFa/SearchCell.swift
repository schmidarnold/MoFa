//
//  SearchCell.swift
//  MoFa
//
//  Created by Arnold Schmid on 14.01.16.
//  Copyright © 2016 Arnold Schmid. All rights reserved.
//

import UIKit

class SearchCell: UITableViewCell {

    @IBOutlet weak var searchLabel: UILabel!
    
    @IBOutlet weak var startButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
