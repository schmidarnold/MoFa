//
//  SoilFertilizerDataHelper.swift
//  MoFa
//
//  Created by Arnold Schmid on 20.11.15.
//  Copyright © 2015 Arnold Schmid. All rights reserved.
//

import Foundation
import SQLite
class SoilFertilizerDataHelper{
    static let db = DaoSqlLite.sharedInstance.dbConn
    static let TABLE_NAME = "soilfertilizer"
    static let db_id = Expression<Int>("id")
    static let db_code = Expression<String?>("code")
    static let db_prodName = Expression<String>("productName")
    
    
    
    
    static let table = Table(TABLE_NAME)
    
    
    typealias T = SoilFertilizer
    
    static func find(_ id: Int) -> T? {
        let query = table.filter(db_id == id)
        var results: T?
        if let item = try! db.pluck (query) {
            results = SoilFertilizer(id: item[db_id], code: item[db_code], productName: item[db_prodName])
        }
        return results
    }
    
    
    static func insert(_ item: T) {
        
        let curItem = table.filter(db_id == item.id)
        
        if try! db.scalar(curItem.count) == 1 {
            _ = try! db.run (curItem.update(db_code <- item.code, db_prodName <- item.productName))
        }else {
           _ = try! db.run (table.insert(db_id <- item.id, db_code <- item.code,  db_prodName <- item.productName))
        }
        
    }
    
    static func findCodeForId(_ id: Int) -> String {
        let query = table.filter(db_id == id)
        var code: String = ""
        if let item = try! db.pluck (query) {
            code = item[db_code]!
            
        }
        return code
    }
    
    static func findAll() -> [T]? {
        var retArray = [T]()
        for item in try! db.prepare(table) {
            retArray.append(SoilFertilizer(id: item[db_id], code: item[db_code], productName: item[db_prodName]))
        }
        return retArray
    }
    static func findAllSorted() -> [T]? {
        var retArray = [T]()
        let tableS = try! db.prepare (table.order(db_prodName))
        for item in tableS {
            retArray.append(SoilFertilizer(id: item[db_id], code: item[db_code], productName: item[db_prodName]))
        }
        return retArray
    }
    static func deleteAll() {
        _ = try! db.run (table.delete())
    }
    
}
