//
//  Task.swift
//  
//
//  Created by Arnold Schmid on 17.04.15.
//
//

import Foundation
import SQLite
import AEXML
func ==(lhs: Task, rhs: Task) -> Bool {
    return lhs.id == rhs.id
}
class Task :ImportDataInterface, Equatable {
    
    var id : Int? = 0
    var code : String? = ""
    var work : String? = ""
    var type : String? = ""
    init () {
        
    }
    init(id : Int, code : String, work : String, type: String?){
        self.id = id
        self.code = code
        self.work = work
        self.type = type
        
    }
    let settings: Settings = Settings()
    static let db = DaoSqlLite.sharedInstance.dbConn
    
    
    var backend:Settings.BackendSoftware{
        get{
            return Settings.getBackendSoftware()
        }
    }
    
    func importAsaData(_ data: Data) {
        do {
            let xmlDoc = try AEXMLDocument(xml: data)
            if let tasks = xmlDoc.root["Arbeit"].all {
                for task in tasks {
                    id = task["ID"].int
                    code = task["Code"].value!
                    work = task["Name"].value!
                    type = task ["Art"].value
                    //insertRow(id!, taskCode: code!, taskWork: work!, taskType: type)
                    TaskDataHelper.insert(Task(id: id!, code: code!, work : work!, type : type))
                    
                }
            }
        }catch {
            print("\(error)")
        }
        
        
        
    }
    func importExcelData(_ data: Data) {
        do {
            let xmlDoc = try AEXMLDocument(xml: data)
            if let tasks = xmlDoc.root["task"].all {
                for task in tasks {
                    type = ""
                    id = task["id"].int
                    code = ""
                    work = task["desc"].value!
                    if task["type"].count == 1 {
                        type = task["type"].value
                    }
                    
                    //insertRow(id!, taskCode: code!, taskWork: work!, taskType: type)
                    TaskDataHelper.insert(Task(id: id!, code: code!, work : work!, type : type))
                    
                }
            }
        }catch {
            Util.showImportError("ExcelImport", errorMsg: "Import Error for Task Data")
        }
    }
    
}
