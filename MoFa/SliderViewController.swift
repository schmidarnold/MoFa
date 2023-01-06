//
//  SliderViewContreller.swift
//  MoFa
//
//  Created by Arnold Schmid on 29.07.15.
//  Copyright (c) 2015 Arnold Schmid. All rights reserved.
//

import UIKit
protocol returnDataSlider {
    func getHours(_ value: Float)
}
class SliderViewController: UIViewController {
    var defaultValue : Float = 8.0
    
    
    var delegate:returnDataSlider?
    @IBOutlet weak var valueSlider: UISlider!
    @IBOutlet weak var lblValue: UILabel!
    
    @IBAction func okButtonClicked(_ sender: UIButton) {
        delegate?.getHours(defaultValue)
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func cancelButtonClicked(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func sliderValueChanged(_ sender: UISlider) {
        defaultValue = sender.value
        let roundedValue = roundf(defaultValue / 0.25) * 0.25
        lblValue.text = "\(roundedValue)"
        defaultValue = roundedValue
    }
    override func viewDidLoad() {
        
        lblValue.text = "\(defaultValue)"
        valueSlider.minimumValue = 0.0
        valueSlider.maximumValue = 14.0
        valueSlider.value = defaultValue
    }
}
