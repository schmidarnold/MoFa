//
//  WaterViewController.swift
//  MoFa
//
//  Created by Arnold Schmid on 09.08.16.
//  Copyright © 2016 Arnold Schmid. All rights reserved.
//

import UIKit

class WaterViewController: UIViewController {
    
    @IBOutlet weak var waterAmountLabel: UILabel!
    @IBOutlet weak var waterDurationLabel: UILabel!
    @IBOutlet weak var waterTotaleLabel: UILabel!
    @IBOutlet weak var waterAmountSlider: UISlider!
    @IBOutlet weak var waterDurationSlider: UISlider!
    @IBOutlet weak var waterTypeSegControl: UISegmentedControl!
    var tbvc = WorkTabBarController()
    var amount : Double  {
        get{
            if Double (waterAmountLabel.text!) != nil {
                return Double(waterAmountLabel.text!)!
            }else{
                return 0.00
            }
            
        }
        set{
            waterAmountLabel.text = String (newValue)
            tbvc.waterData.amount = newValue
            updateTotale()
        }
    }
    var duration: Double  {
        get {
            if Double (waterDurationLabel.text!) != nil {
                return Double(waterDurationLabel.text!)!
            }else{
                return 0.00
            }
            
        }
        set{
            waterDurationLabel.text = String(newValue)
            tbvc.waterData.duration = newValue
            updateTotale()
        }
    }
    var waterType : Constants.Water = Constants.Water.irrigation
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tbvc = self.tabBarController  as! WorkTabBarController
        waterAmountSlider.minimumValue = 0.00
        waterAmountSlider.maximumValue = 4.00
        waterDurationSlider.minimumValue=0.00
        waterDurationSlider.maximumValue=16.00
        loadValues()
        
    }
    fileprivate func loadValues() {
        amount = 0.00
        duration = 0.00
        if tbvc.newEntry == false{
            if tbvc.globalData != nil { //existing waterenty
                //tbvc.globalData?.workId = tbvc.curWork.workId!
                let values = GlobalDataHelper.getWaterData((tbvc.globalData?.id!)!)
                
                tbvc.waterData.amount = values.irrAmount!
                tbvc.waterData.duration = values.irrDuration!
                tbvc.waterData.type = (values.irrType!)
                amount = tbvc.waterData.amount
                duration = tbvc.waterData.duration
                waterTypeSegControl.selectedSegmentIndex = (tbvc.waterData.type - 1)
                waterAmountSlider.value =  Float (amount)
                waterDurationSlider.value = Float (duration)
            }else{
                tbvc.globalData = GlobalData() //existing work, but not water entry
                tbvc.globalData?.workId = tbvc.curWork.workId!
                tbvc.globalData?.typeInfo = Constants.GlobalDataType.Irrigation.rawValue
            }
            
            
        
        } else { // new work
            tbvc.globalData = GlobalData()
            tbvc.globalData?.typeInfo = Constants.GlobalDataType.Irrigation.rawValue
            
        }
    }
    fileprivate func updateTotale() {
            waterTotaleLabel.text = String (amount * duration)
        
    }
    @IBAction func amountSliderChanged(_ sender: UISlider) {
        let roundedValue = round(Double(sender.value)/0.1) * 0.1
        amount = roundedValue
        
        
    }
    
    @IBAction func durationSliderChanged(_ sender: UISlider) {
        let roundedValue = round(Double(sender.value)/0.5)*0.5
        duration = roundedValue
        
    }
    
    @IBAction func waterTypeSegChanged(_ sender: UISegmentedControl) {
        
        switch waterTypeSegControl.selectedSegmentIndex {
            case 0:
                waterType = Constants.Water.irrigation
            case 1:
                waterType = Constants.Water.frost
            case 2:
                waterType = Constants.Water.drip
            default:
                waterType = Constants.Water.irrigation
            
        }
        tbvc.waterData.type = waterType.rawValue
       
    }
    
}
