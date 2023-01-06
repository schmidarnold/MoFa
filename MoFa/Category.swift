//
//  Category.swift
//  MoFa
//
//  Created by Arnold Schmid on 31.05.15.
//  Copyright (c) 2015 Arnold Schmid. All rights reserved.
//

import Foundation
import SQLite
import AEXML
class Category : ImportDataInterface {
    var id : Int = 0
    var code : String = ""
    var quality : String = ""
    init() {
        
    }
    init(id : Int,  name : String){
        self.id = id
        self.quality = name
        
    }
    
    
    var backend:Settings.BackendSoftware{
        get{
            return Settings.getBackendSoftware()
        }
    }
    func importAsaData(_ data: Data) {
        
        do{
            let xmlDoc = try AEXMLDocument(xml: data)
            if let categories = xmlDoc.root["Kategorie"].all {
                for category in categories {
                    id = category["ID"].int!
                    code = category["Code"].value!
                    quality = category["Name"].value!
                    insertRow(id, catCode : code, catQuality : quality)
                    
                }
            }
            

        }catch{
            print ("\(error)")
        }
        
    }
    func importExcelData(_ data: Data) {
        do{
            let xmlDoc = try AEXMLDocument(xml: data)
            if let categories = xmlDoc.root["quality"].all {
                for category in categories {
                    id = category["id"].int!
                    code = ""
                    quality = category["desc"].value!
                    insertRow(id, catCode : code, catQuality : quality)
                    
                }
            }
            
            
        }catch{
            Util.showImportError("ExcelImport", errorMsg: "Import Error for Category Data")
        }
    }
    
    
    
    func insertRow (_ catId : Int, catCode : String, catQuality : String) {
        let db = DaoSqlLite.sharedInstance.dbConn
        let categories = Table("fruitquality")
        let db_id = Expression<Int>("id")
        let db_code = Expression<String>("code")
        let db_quality = Expression<String>("quality")
        let exists = categories.filter(db_id == catId)
        if try! db.scalar(exists.count) == 1 {
            _ = try! db.run (exists.update(db_quality <- catQuality, db_code <- catCode))
        }else{
            _ = try! db.run (categories.insert(db_id <- catId,db_quality <- catQuality, db_code <- catCode))
        }
    
    }
    

}
