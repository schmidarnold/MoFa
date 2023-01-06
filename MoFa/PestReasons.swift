//
//  PestReasons.swift
//  MoFa
//
//  Created by Arnold Schmid on 05.02.18.
//  Copyright © 2018 Arnold Schmid. All rights reserved.
//

import Foundation
import AEXML
struct Einsatzgruende: Codable{
    let einsatzGruende:[Einsatzgrund]
}
//import function for Einsatzgrund
struct Einsatzgrund: Codable, ImportDataInterface{
    let code : String
    let name : String
    func importAsaData(_ data: Data) {
        var reasonArray = [Einsatzgrund]()
        do {
            let xmlDoc = try AEXMLDocument(xml: data)
            if let reasons = xmlDoc.root["Einsatzgrund"].all {
                for reason in reasons {
                    let pestReason = Einsatzgrund(code: reason["Code"].value!,name: reason["Name"].value!)
                    reasonArray.append(pestReason)
                    
                }
                
            }
            
        }catch {
            print("\(error)")
        }
        let encoder = JSONEncoder()
        //encoder.outputFormatting = .prettyPrinted
        if let jsondata = try? encoder.encode(reasonArray),
            let jsonstr = String(data: jsondata,encoding: .utf8){
            saveDataToGlobal(jsonData: jsonstr)
            
        }
        
    }
    
    func importExcelData(_ data: Data) {
        //not needed for the moment
    }
    func saveDataToGlobal(jsonData:String){
        let entry = GlobalData()
        entry.typeInfo = Constants.GlobalDataType.PestReasons.rawValue
        entry.data = jsonData
        GlobalDataHelper.savePestReasons(item: entry)
        
    }
    
}
