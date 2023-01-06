//
//  VQuarter.swift
//  MoFa
//
//  Created by Arnold Schmid on 31.05.15.
//  Copyright (c) 2015 Arnold Schmid. All rights reserved.
//

import Foundation
import AEXML
class VQuarter : ImportDataInterface {
    var id : Int? = 0
    var code : String? = ""
    var name : String? = ""
    var landId : Int? = 0
    var plantYear : Int?
    var clone : String?
    var waterAmount : Double? = 0.00
    var size : Int?
    init () {
        
    }
    init(id : Int, code : String?, name: String, landId : Int, plantYear : Int?, clone : String?, waterAmount: Double?, size: Int? ){
        self.id = id
        self.code = code
        self.name = name
        self.landId = landId
        self.plantYear = plantYear
        self.clone = clone
        self.waterAmount = waterAmount
        self.size = size
        
    }
    func importAsaData(_ data: Data) {
        do {
            let xmlDoc = try AEXMLDocument(xml: data)
            if let vquarters = xmlDoc.root["Sortenquartier"].all {
                for vquarter in vquarters {
                    id = vquarter["ID"].int
                    name = modifyString (vquarter["Name"].value!)
                    landId = (vquarter["Anlage"]["ID"].int)
                    waterAmount = vquarter["Spritzvorgabe"].double
                    plantYear = vquarter["GueltigSeitEJ"].int
                    code = vquarter["Code"].value
                    size = vquarter["Nettoflaeche"].int
                    
                    VQuarterDataHelper.insert(VQuarter(id: id!, code: code!, name: name!, landId: landId!, plantYear: plantYear, clone: clone, waterAmount: waterAmount, size: size))
                }
            }
        }catch {
            print("\(error)")
        }
        
        
    }
    func importExcelData(_ data: Data) {
        do {
            let xmlDoc = try AEXMLDocument(xml: data)
            if let vquarters = xmlDoc.root["vquarter"].all {
                for vquarter in vquarters {
                    id = vquarter["id"].int
                    name = vquarter["variety"].value!
                    landId = (vquarter["land"]["id"].int)
                    if let water = vquarter["wateramount"].value {
                       // let fmt = NSNumberFormatter()
                       // fmt.numberStyle = NSNumberFormatterStyle.DecimalStyle
                        let w = water.replacingOccurrences(of: ",", with: ".")
                        
                        let amountw = Double(w) // convert it to a Double
                        waterAmount =  (amountw!/100 * 100) //rounding
                        }
                    //waterAmount = vquarter["wateramount"].doubleValue
                    
                    plantYear = vquarter["year"].int
                    code = ""
                    size = vquarter["size"].int
                    clone = vquarter["clone"].value
                    VQuarterDataHelper.insert(VQuarter(id: id!, code: code!, name: name!, landId: landId!, plantYear: plantYear, clone: clone, waterAmount: waterAmount, size: size))
                }
            }
        }catch {
            Util.showImportError("ExcelImport", errorMsg: "Import Error for VQuarter Data")
        }
    }
    
    func modifyString (_ input : String) -> String {
        var myStringArr = input.components(separatedBy: " ")
        var newString = myStringArr[1]
        if myStringArr.count >= 3 {
            newString += " " + myStringArr[2]
        }
        return newString
    }
    
}
