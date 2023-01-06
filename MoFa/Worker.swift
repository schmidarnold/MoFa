//
//  Worker.swift
//  MoFa
//
//  Created by Arnold Schmid on 20.05.15.
//  Copyright (c) 2015 Arnold Schmid. All rights reserved.
//

import Foundation
import SQLite
import AEXML
class Worker: ImportDataInterface{
    var id : Int = 0
    var code : String? = ""
    var lastName : String = ""
    var firstName : String?
    
    init() {
        
    }
    init(id : Int, code : String?, lastName : String, firstName : String?){
        self.id = id
        self.code = code
        self.lastName = lastName
        self.firstName = firstName
    }
    
   

    func importAsaData(_ data: Data) {
       
        do {
            let xmlDoc = try AEXMLDocument(xml: data)
                if let workers = xmlDoc.root["Arbeitskraft"].all {
                    for worker in workers {
                        id = worker["ID"].int!
                        code = worker["Code"].value!
                        lastName = worker["Name1"].value!
                        if worker["Name2"].count > 0 { //check if firstName is set
                            self.firstName = worker["Name2"].value
                        } else {
                            self.firstName = ""
                        }
                        WorkerDataHelper.insert(Worker(id: id, code: code, lastName: lastName, firstName: firstName))
                    }
            
            }
            
        }catch {
            print("\(error)")
        }
                    
    }
    func importExcelData(_ data: Data) {
        do {
            let xmlDoc = try AEXMLDocument(xml: data)
            if let workers = xmlDoc.root["worker"].all {
                for worker in workers {
                    id = worker["id"].int!
                    code = ""
                    lastName = worker["lastname"].value!
                    if worker["firstname"].count > 0 { //check if firstName is set
                        self.firstName = worker["firstname"].value
                    } else {
                        self.firstName = ""
                    }
                    WorkerDataHelper.insert(Worker(id: id, code: code, lastName: lastName, firstName: firstName))
                }
                
            }
            
        }catch {
            Util.showImportError("ExcelImport", errorMsg: "Import Error for Worker Data")
        }
    }
    

}
