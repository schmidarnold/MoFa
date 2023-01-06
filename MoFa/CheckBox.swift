//
//  CheckBox.swift
//  ExpandTableView
//
//  Created by Arnold Schmid on 15.06.15.
//  Copyright (c) 2015 Arnold Schmid. All rights reserved.
//

import UIKit

class CheckBox: UIButton {
    var cellIndexPath :IndexPath?
    //images
    let checkedImage = UIImage(named: "checked_checkbox")
    let unCheckedImage = UIImage(named: "unchecked_checkbox")
    
    //bool propety
    var isChecked:Bool = false{
        didSet{
            if isChecked == true{
                self.setImage(checkedImage, for: UIControl.State())
            }else{
                self.setImage(unCheckedImage, for: UIControl.State())
            }
        }
    }
    
    
    override func awakeFromNib() {
        self.addTarget(self, action: #selector(CheckBox.buttonClicked(_:)), for: UIControl.Event.touchUpInside)
        self.isChecked = false
    }
    
    
    
    @objc func buttonClicked(_ sender:UIButton) {
        if(sender == self){
            if isChecked == true{
                isChecked = false
            }else{
                isChecked = true
            }
        }
    }
}
