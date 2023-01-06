//
//  Machine.swift
//  MoFa
//
//  Created by Arnold Schmid on 20.05.15.
//  Copyright (c) 2015 Arnold Schmid. All rights reserved.
//

import Foundation
import SQLite
import AEXML
class Machine: ImportDataInterface{
    var id : Int = 0
    var code : String? = ""
    var name : String = ""
    
    
    
    init() {
        
    }
    init(id : Int, code : String?, name : String){
        self.id = id
        self.code = code
        self.name = name
        
    }
    
    
    func importAsaData(_ data: Data) {
        do{
            let xmlDoc = try AEXMLDocument(xml: data)
            if let machines = xmlDoc.root["Maschine"].all {
                for machine in machines{
                    id = machine["ID"].int!
                    code = machine["Code"].value!
                    name = machine["Name"].value!
                    MachineDataHelper.insert(Machine(id: id, code: code, name: name))
                    // insertRow(id, machineCode: code, machineName: name)
                    
                }
            }
            
        }catch {
            print("\(error)")
        }
        
        
        
    }
    func importExcelData(_ data: Data) {
        do{
            let xmlDoc = try AEXMLDocument(xml: data)
            if let machines = xmlDoc.root["machine"].all {
                for machine in machines{
                    id = machine["id"].int!
                    code = ""
                    name = machine["name"].value!
                    MachineDataHelper.insert(Machine(id: id, code: code, name: name))
                    // insertRow(id, machineCode: code, machineName: name)
                    
                }
            }
            
        }catch {
            Util.showImportError("ExcelImport", errorMsg: "Import Error for Machine Data")
        }
    }
    
        
        
}

