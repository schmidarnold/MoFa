//
//  MyPickerView.swift
//  MoFa
//
//  Created by Arnold Schmid on 29.01.18.
//  Copyright © 2018 Arnold Schmid. All rights reserved.
//
// PickerView for selecting the Einsatzgrund for ASA16 and Zeitraum
// used in inputDoseAmountViewController

import Foundation
//customized PickerView
class MyPickerView : UIPickerView, UIPickerViewDataSource, UIPickerViewDelegate {
    
    
    var pickerData : [Wirkung]!
    var pickerTextField : UITextField!
    var indexPosition = 0
    var selectionHandler : ((_ selectedWirkung: Wirkung) -> Void)?
    
    init(pickerData: [Wirkung], dropdownField: UITextField) {
        super.init(frame: CGRect.zero)
        
        self.pickerData = pickerData
        self.pickerTextField = dropdownField
        
        self.delegate = self
        self.dataSource = self
        
        DispatchQueue.main.async(execute: {
            if pickerData.count > 0 {
                self.pickerTextField.text = self.pickerData[self.indexPosition].description
                self.pickerTextField.isEnabled = true
            } else {
                self.pickerTextField.text = nil
                self.pickerTextField.isEnabled = false
            }
        })
        
        
    }
    convenience init(pickerData: [Wirkung], dropdownField: UITextField, onSelect selectionHandler: @escaping (_ selectedWirkung: Wirkung)->Void, indexPosition: Int){
        self.init(pickerData: pickerData,dropdownField: dropdownField)
        self.selectionHandler = selectionHandler
        self.indexPosition = indexPosition
        
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // Sets number of columns in picker view
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
    return 1
    }
    
    // Sets the number of rows in the picker view
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
    return pickerData.count
    }
    
    // This function sets the text of the picker view to the content of the "salutations" array
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
    return pickerData[row].description
    }
    
    // When user selects an option, this function will set the text of the text field to reflect
    // the selected option.
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        pickerTextField.text = pickerData[row].description
        if self.pickerTextField.text != nil && self.selectionHandler != nil {
            selectionHandler!(pickerData[row])
        }
        pickerTextField.resignFirstResponder()
    }
    // function to formatting the picker elements
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 400, height: 44))
        label.lineBreakMode = .byWordWrapping
        label.numberOfLines = 2
        label.textAlignment = NSTextAlignment.center
        label.font = label.font.withSize(12)
        label.text = pickerData[row].description + "\n" + "Zeitraum: " + pickerData[row].period
        label.sizeToFit()
        return label
    }
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 50.0
    }
    
}
