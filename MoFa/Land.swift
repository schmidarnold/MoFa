//
//  Land.swift
//  MoFa
//
//  Created by Arnold Schmid on 31.05.15.
//  Copyright (c) 2015 Arnold Schmid. All rights reserved.
//

import Foundation
import SQLite
import AEXML
class Land : ImportDataInterface {
    var id : Int? = 0
    var code : String? = ""
    var name : String? = ""
    init () {
        
    }
    init(id : Int, code : String?, name : String){
        self.id = id
        self.code = code
        self.name = name
    }
    
    
    func importAsaData(_ data: Data) {
        do {
        let xmlDoc = try AEXMLDocument(xml: data)
            if let lands = xmlDoc.root["Anlage"].all {
                for land in lands {
                    id = land["ID"].int
                    code = land["Code"].value!
                    name = land["Name"].value!
                    LandDataHelper.insert(Land(id: id!, code: code, name: name!))
                    
                }
            }
        }catch {
                print ("\(error)")
        }
        
    }
    
    func importExcelData(_ data: Data) {
        do {
            let xmlDoc = try AEXMLDocument(xml: data)
            if let lands = xmlDoc.root["land"].all {
                for land in lands {
                    id = land["id"].int
                    code = "" //not needed for excel
                    name = land["name"].value!
                    LandDataHelper.insert(Land(id: id!, code: code, name: name!))
                    
                }
            }
        }catch {
            Util.showImportError("ExcelImport", errorMsg: "Import Error for Land Data")
        }
    }
    
}
