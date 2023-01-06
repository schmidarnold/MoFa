//
//  BlossomVquarterCell.swift
//  MoFa
//
//  Created by Arnold Schmid on 30.11.16.
//  Copyright © 2016 Arnold Schmid. All rights reserved.
//

import UIKit
enum Moment{
    case blossomStart
    case blossomEnd
    case harvestStart
    case crospAmount
}
protocol BlossCellProtocol{
    func didEditingCell(vqid:Int,timePoint:Moment, sender: UITextField)
}
class BlossomVquarterCell: UITableViewCell {

    @IBOutlet weak var vquarterLabel: UILabel!
    @IBOutlet weak var blossomStartText: UITextField!
    @IBOutlet weak var blossomEndText: UITextField!
   
    @IBOutlet weak var harvestStartText: UITextField!
    
    @IBOutlet weak var crospAmountText: UITextField!
    
    
    var cellDelegate : BlossCellProtocol?
    var activeMoment = Moment.blossomStart //variable to determin if blossStartText or blossEndText
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    @IBAction func blossStartEditing(_ sender: UITextField) {
        activeMoment = Moment.blossomStart
        cellDelegate?.didEditingCell(vqid: blossomStartText.tag, timePoint: activeMoment, sender:sender)
    }
    
    
    @IBAction func blossEndEditing(_ sender: UITextField) {
        activeMoment = Moment.blossomEnd
        cellDelegate?.didEditingCell(vqid: blossomStartText.tag, timePoint: activeMoment, sender: sender)
        

    }
    
    @IBAction func harvestStartEditing(_ sender: UITextField) {
        activeMoment = Moment.harvestStart
        cellDelegate?.didEditingCell(vqid: blossomStartText.tag, timePoint: activeMoment, sender: sender)
    }
    
   
    @IBAction func crospAmountEditing(_ sender: UITextField) {
        activeMoment = Moment.crospAmount
        cellDelegate?.didEditingCell(vqid: blossomStartText.tag, timePoint: activeMoment, sender: sender)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
