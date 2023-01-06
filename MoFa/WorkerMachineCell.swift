//
//  WorkerMachineCell.swift
//  MoFa
//
//  Created by Arnold Schmid on 28.07.15.
//  Copyright (c) 2015 Arnold Schmid. All rights reserved.
//

import UIKit

class WorkerMachineCell: UITableViewCell {

    @IBOutlet weak var chkWorkerMachine: CheckBox!
    
    @IBOutlet weak var lblName: UILabel!
    
    @IBOutlet weak var lblhours: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    }
