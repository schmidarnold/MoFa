//
//  Fertilizer.swift
//  MoFa
//
//  Created by Arnold Schmid on 31.05.15.
//  Copyright (c) 2015 Arnold Schmid. All rights reserved.
//

import Foundation
import AEXML
class Fertilizer : ImportDataInterface, Product {
    @objc var id : Int = 0
    var code : String? = ""
    @objc var productName : String = ""
    var defaultDose : Double?
    
    init () {
        
    }
    init(id : Int, code : String?, productName : String, defaultDose: Double? ){
        self.id = id
        self.code = code
        self.productName = productName
        self.defaultDose = defaultDose
    }
    func importAsaData(_ data: Data) {
        
        
        do {
            let xmlDoc = try AEXMLDocument(xml: data)
            if let fertilizers = xmlDoc.root["Duengemittel"].all {
                for fertilizer in fertilizers {
                    id = fertilizer["ID"].int!
                    code = fertilizer["Code"].value!
                    productName = fertilizer["Name"].value!
                    defaultDose = fertilizer["DosierungProHl"].double
                    FertilizerDataHelper.insert(Fertilizer(id: id, code: code, productName: productName, defaultDose: defaultDose))
                }
            }
        }catch{
            print ("\(error)")
        }
        
        
        
    }
    func importExcelData(_ data: Data) {
        do {
            let xmlDoc = try AEXMLDocument(xml: data)
            if let fertilizers = xmlDoc.root["fertilizer"].all {
                for fertilizer in fertilizers {
                    id = fertilizer["id"].int!
                    code = ""
                    productName = fertilizer["product"].value!
                    defaultDose = fertilizer["dose"].double
                    FertilizerDataHelper.insert(Fertilizer(id: id, code: code, productName: productName, defaultDose: defaultDose))
                }
            }
        }catch{
           Util.showImportError("ExcelImport", errorMsg: "Import Error for Fertilizer Data")
        }
    }
}


