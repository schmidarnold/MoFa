//
//  CustomButton.swift
//  MoFa
//
//  Created by Arnold Schmid on 24.04.15.
//  Copyright (c) 2015 Arnold Schmid. All rights reserved.
//

import UIKit

class CustomButton : UIButton {
    
    var myAlternateButton:Array<CustomButton>?
    var activeBackGroundColor:UIColor? = UIColor.green{
        didSet{
            
                self.backgroundColor = activeBackGroundColor
            
            
        }
    }
    var downStateImage:String? = "radiobutton_down"{
    
        didSet{
            
            if downStateImage != nil {
                
                self.setImage(UIImage(named: downStateImage!), for: UIControl.State.selected)
            }
        }
    }
    
    func unselectAlternateButtons(){
        
        if myAlternateButton != nil {
            
            self.isSelected = true
            
            for aButton:CustomButton in myAlternateButton! {
                aButton.backgroundColor = UIColor.white
                aButton.isSelected = false
            }
            
        }else{
            
            toggleButton()
        }
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.backgroundColor = activeBackGroundColor
        unselectAlternateButtons()
        super.touchesBegan(touches , with:event)
    }
    
    func toggleButton(){
        
        if self.isSelected==false{
            
            self.isSelected = true
        }else {
            
            self.isSelected = false
        }
    }
}
