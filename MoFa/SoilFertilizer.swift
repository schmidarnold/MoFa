//
//  SoilFertilizer.swift
//  MoFa
//
//  Created by Arnold Schmid on 20.11.15.
//  Copyright © 2015 Arnold Schmid. All rights reserved.
//

import Foundation
import AEXML
class SoilFertilizer:ImportDataInterface{
    var id : Int = 0
    var code : String? = ""
    var productName : String = ""
   
    
    init () {
        
    }
    init(id : Int, code : String?, productName : String ){
        self.id = id
        self.code = code
        self.productName = productName
        
    }
    func importAsaData(_ data: Data) {
        
        
        do {
            let xmlDoc = try AEXMLDocument(xml: data)
            if let soilFertilizers = xmlDoc.root["Duengemittel"].all {
                for soilFertilizer in soilFertilizers {
                    id = soilFertilizer["ID"].int!
                    code = soilFertilizer["Code"].value!
                    productName = soilFertilizer["Name"].value!
                    SoilFertilizerDataHelper.insert(SoilFertilizer(id: id, code: code, productName: productName))
                }
            }
        }catch{
            print ("\(error)")
        }
        
        
        
    }
    func importExcelData(_ data: Data) {
        do {
            let xmlDoc = try AEXMLDocument(xml: data)
            if let soilFertilizers = xmlDoc.root["soilfertilizer"].all {
                for soilFertilizer in soilFertilizers {
                    id = soilFertilizer["id"].int!
                    code = ""
                    productName = soilFertilizer["product"].value!
                    SoilFertilizerDataHelper.insert(SoilFertilizer(id: id, code: code, productName: productName))
                }
            }
        }catch{
            Util.showImportError("ExcelImport", errorMsg: "Import Error for Soilfertilizer Data")
        }
    }
}
