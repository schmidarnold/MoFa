//
//  UIElements.swift
//  MoFa
//
//  Created by Arnold Schmid on 29.01.18.
//  Copyright © 2018 Arnold Schmid. All rights reserved.
//


import Foundation
import UIKit
//extension for MyPickerView for selecting wirkung in InputDoseAmountViewController for ASA16
extension UITextField {
    func loadDropdownData(data: [Wirkung]) {
        self.inputView = MyPickerView(pickerData: data, dropdownField: self)
    }
    func loadDropDownData(data: [Wirkung], onSelect selectionHandler: @escaping (_ selectedWirkung: Wirkung) -> Void, indexPosition: Int){
        self.inputView = MyPickerView(pickerData: data, dropdownField: self, onSelect: selectionHandler, indexPosition: indexPosition)
    }
}
